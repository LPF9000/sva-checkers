#!/usr/bin/env python3
"""Run isolated checker activation fixtures and retain exact diagnostic evidence."""
from __future__ import annotations
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import signal
import subprocess
import threading
import time

ROOT = Path(__file__).resolve().parents[1]
ACTIVE: set[subprocess.Popen] = set()
LOCK = threading.Lock()
STOP = threading.Event()


def run(command: list[str], log: Path, timeout: float) -> int:
    environment = os.environ.copy()
    environment["CCACHE_DISABLE"] = "1"
    with log.open("w") as output:
        with LOCK:
            if STOP.is_set():
                output.write("Interrupted before process start.\n")
                return 130
            try:
                process = subprocess.Popen(command, cwd=ROOT, env=environment, stdout=output,
                                           stderr=subprocess.STDOUT, start_new_session=True)
            except FileNotFoundError as error:
                output.write(f"Unable to start command: {error}\n")
                return 127
            except OSError as error:
                output.write(f"Unable to start command: {error}\n")
                return 126
            ACTIVE.add(process)
        try:
            return process.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            process.wait()
            return 124
        finally:
            with LOCK:
                ACTIVE.discard(process)


def validate(name: str, specification: dict, output: Path, tool: str) -> dict:
    folder = output / name
    folder.mkdir()
    binary = folder / "obj" / "Vchecker_tb"
    command = [tool, "--binary", "--timing", "--assert", "--timescale", "1ns/1ps",
               "-Wno-fatal", "--top-module", "checker_tb", "-I" + str(ROOT / "src"),
               "--Mdir", str(folder / "obj"), "--build-jobs", "1",
               str(ROOT / "tests" / (name + "_tb.sv"))]
    build_rc = run(command, folder / "build.log", 180)
    result = {"checker": name, "build_command": command, "build_returncode": build_rc,
              "cases": [], "pass": build_rc == 0}
    if build_rc:
        return result
    cases = specification.get("cases", {"legal": None, "violation": specification.get("negative")})
    cases.update(specification.get("extra_cases", {}))
    for case, expected in cases.items():
        if case == "violation" and specification.get("four_state"):
            result["cases"].append({"case": case, "status": "unqualified", "reason": "Verilator is two-state; X/Z negative activation requires a four-state simulator"})
            continue
        log = folder / (case + ".log")
        rc = run([str(binary), "+verilator+seed+1", "+CASE=" + case], log, 15)
        text = log.read_text()
        diagnostics = re.findall(r'Assertion failed[^\n]*?: ([A-Z][A-Z0-9_]+)(?:\s|$)', text)
        passed = (rc == 0 and "CHECKER_TEST_PASS" in text and not diagnostics) if expected is None else (rc not in (0, 124, 130, 126, 127) and diagnostics == [expected])
        result["cases"].append({"case": case, "returncode": rc, "diagnostics": diagnostics,
                                "status": "pass" if passed else "fail", "log": str(log)})
        result["pass"] = result["pass"] and passed
    print(("PASS " if result["pass"] else "FAIL ") + name, flush=True)
    return result


def input_hashes() -> dict[str, str]:
    files = sorted((ROOT / "src").rglob("*")) + sorted((ROOT / "tests").rglob("*"))
    return {
        str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in files
        if path.is_file()
    }


def stop_processes() -> None:
    STOP.set()
    with LOCK:
        for process in tuple(ACTIVE):
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass


def tool_version(tool: str) -> str:
    try:
        completed = subprocess.run([tool, "--version"], cwd=ROOT, text=True,
                                   stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                   check=False, timeout=10)
    except (OSError, subprocess.TimeoutExpired) as error:
        return f"unavailable: {error}"
    value = completed.stdout.strip()
    if completed.returncode:
        return f"unavailable (exit {completed.returncode}): {value}"
    return value


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", default=os.environ.get("VERILATOR", "verilator"))
    parser.add_argument("--output", type=Path, default=ROOT / "sim" / ("validation-" + time.strftime("%Y%m%dT%H%M%S") + "-" + str(os.getpid())))
    parser.add_argument("--workers", type=int, default=2)
    parser.add_argument("--checkers", nargs="+")
    args = parser.parse_args()
    if not 1 <= args.workers <= 8:
        parser.error("workers must be between 1 and 8")
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    specifications = json.loads((ROOT / "tests/cases.json").read_text())
    selected = args.checkers or list(specifications)
    if any(name not in specifications for name in selected) or len(set(selected)) != len(selected):
        parser.error("checker selection must contain unique known checker names")
    output = args.output.resolve()
    try:
        output.mkdir(parents=True, exist_ok=False)
    except OSError as error:
        parser.error(f"Cannot create a new evidence directory {output}: {error}")
    tool = str(Path(args.verilator).resolve()) if "/" in args.verilator else args.verilator
    before_hashes = input_hashes()
    results = []
    interrupted = False
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        futures = {}
        try:
            futures = {
                pool.submit(validate, name, specifications[name], output, tool): name
                for name in selected
            }
            for future in as_completed(futures):
                name = futures[future]
                try:
                    results.append(future.result())
                except Exception as error:
                    results.append({"checker": name, "pass": False, "cases": [],
                                    "worker_error": f"{type(error).__name__}: {error}"})
        except KeyboardInterrupt:
            interrupted = True
            stop_processes()
            for future, name in futures.items():
                if future.cancel():
                    results.append({"checker": name, "pass": False, "cases": [],
                                    "status": "interrupted before worker start"})
    results_by_name = {result["checker"]: result for result in results}
    for name in selected:
        if name not in results_by_name:
            results.append({"checker": name, "pass": False, "cases": [],
                            "status": "interrupted before result was collected"})
    results.sort(key=lambda result: selected.index(result["checker"]))
    after_hashes = input_hashes()
    changed_inputs = sorted(
        path for path in set(before_hashes) | set(after_hashes)
        if before_hashes.get(path) != after_hashes.get(path)
    )
    if changed_inputs:
        for result in results:
            result["pass"] = False
    report = {"seed": 1, "verilator": tool_version(tool),
              "source_hashes_before": before_hashes,
              "source_hashes_after": after_hashes,
              "changed_inputs": changed_inputs,
              "interrupted": interrupted,
              "tests": results, "passed": sum(bool(r.get("pass")) for r in results), "total": len(results),
              "limits": ["Nested parameterized hosts are slang-elaborated; runtime tests use the identical checker declaration factory at compilation-unit scope", "Four-state X/Z runtime qualification is not established", "No formal proof or alternate-simulator runtime qualification"]}
    (output / "summary.json").write_text(json.dumps(report, indent=4) + "\n")
    print(f"Result {report['passed']}/{report['total']}; evidence: {output}", flush=True)
    if interrupted:
        return 130
    return 0 if report["passed"] == report["total"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
