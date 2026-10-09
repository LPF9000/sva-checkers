# Tool support and qualification

## Declaration model

Each family uses a real SystemVerilog `checker` / `endchecker` declaration.
Typed declaration macros provide compile-time widths, capacities, and policy
values because checker declarations do not support module-style parameter
overrides. Parameterized `.sv` module hosts provide typed reusable ports and
instantiate the corresponding checker declaration internally.

Strict slang elaboration of the library and fixtures completes with zero
warnings and zero errors. Nondefault hosts for 128-bit `known_check` and
`stable_check`, and a FIFO host with depth 17, also elaborate cleanly. This
validates the language structure, including parameterized module hosts.
Verilator does not support the nested checker
declaration form at runtime. Runtime fixtures therefore emit the same checker
declarations at compilation-unit scope and instantiate those checker types in
test modules. The parameterized hosts have not been runtime-qualified.

## Commands

Run these commands from the `checkers/` directory:

```sh
uv sync --locked
uv run python scripts/lint.py
uv run python scripts/check.py --verilator /path/to/verilator
```

`uv sync --locked` installs the dependency versions recorded in `uv.lock`.
The lint command elaborates library hosts and testbench source with slang. It
returns failure for language errors or warnings. The check command builds the
fixtures with Verilator using timing and assertions enabled, runs legal and
violation scenarios, and checks expected diagnostic identifiers. The runner
records tool version, commands, source hashes, diagnostics, and logs under
`sim/` by default. Use `--checkers name ...` to select fixtures,
`--workers N` to bound parallel builds, and `--output PATH` to select the
evidence directory.

## Current evidence

The coherent Verilator 5.052 library gate passes 49/49 fixtures, with unchanged
inputs. It includes the base family activation cases, parameter and policy
variants, and invalid-policy diagnostics.

Subsequent changes preserve fairness history across temporary ineligibility by
default, with an explicit `CLEAR_ON_INELIGIBLE` policy option. The clock-gate
checker observes actual gated and source edges, including NBA updates. Shared
lifecycle controls assert known reset and enable values; those controls have not
been tested with X/Z values. Strict slang elaboration passes without warnings
or errors, and focused fairness-bubble and gate-edge fixtures pass 2/2.

## Limits and remaining qualification

Verilator runs a two-state simulation model. One known-value negative case has
not been qualified on a four-state simulator; X/Z behavior is therefore not
claimed. Formal proof and alternate-simulator compile/run qualification have
not been performed. The parameterized module hosts are elaborated by slang but
not runtime-tested because Verilator does not support their nested checker
declarations. Remaining per-family behavioral boundaries require further
recorded evidence.

The fixture suite is a useful implementation gate, not a complete qualification
of every use environment. Consumers remain responsible for defining event
acceptance, clocks, resets, expected values, and timing policy consistently
with each checker's contract. No production-readiness claim is made.
