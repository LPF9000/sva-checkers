#!/usr/bin/env python3
"""Check IEEE language legality with slang, including native checker restrictions."""
from __future__ import annotations
import argparse
from pathlib import Path
from pyslang import Bag, DiagnosticEngine, SourceManager, TextDiagnosticClient
from pyslang.ast import Compilation
from pyslang.parsing import PreprocessorOptions
from pyslang.syntax import SyntaxTree


def compile_files(files: list[Path], include: Path) -> bool:
    manager = SourceManager()
    options = PreprocessorOptions()
    options.additionalIncludePaths = [str(include)]
    bag = Bag()
    bag.preprocessorOptions = options
    compilation = Compilation()
    for path in files:
        compilation.addSyntaxTree(SyntaxTree.fromFile(str(path), manager, bag))
    engine = DiagnosticEngine(manager)
    client = TextDiagnosticClient()
    engine.addClient(client)
    for diagnostic in compilation.getAllDiagnostics():
        engine.issue(diagnostic)
    if client.getString():
        print(client.getString(), end="")
    return engine.numErrors == 0 and engine.numWarnings == 0


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="*", type=Path)
    args = parser.parse_args()
    if args.files:
        return 0 if compile_files(args.files, root / "src") else 1
    passed = compile_files(sorted((root / "src").glob("*.sv")) + [root / "tests/host_elaboration.sv"], root / "src")
    for path in sorted((root / "tests").glob("*_tb.sv")):
        passed = compile_files([path], root / "src") and passed
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
