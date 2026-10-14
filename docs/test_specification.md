# Checker validation contract

Every family has an isolated pin/event fixture. Stimulus comes from the fixture;
checker state never supplies expected stimulus or verdicts. Legal scenarios must
exit normally with `CHECKER_TEST_PASS` and no assertion diagnostics. Negative
scenarios must fail with exactly the intended diagnostic identifier. A build
failure, timeout, unavailable executable or interruption cannot pass a negative
case. Seeds are explicit and retained in the report.

`tests/cases.json` is the case inventory. Each family's base cases exercise
legal operation and one prohibited operation. `extra_cases` names additional
legal cases with a null diagnostic or negative cases with an expected diagnostic.
The known-value X/Z negative is not qualified by Verilator's two-state
simulation and is not counted as demonstrated activation.

Additional accounting fixtures test capacity, duplicate IDs, simultaneous
completion/cancellation, freed-ID reuse, the inclusive latency boundary,
timeouts, reset and disable with pending work. Address fixtures test the last
legal byte, an overflowing end address, unaligned and denied access, and ignored
unaccepted traffic. Length fixtures test exact boundaries, boundary crossing,
overflow, partial accepted beats and cancellation. Access-control fixtures test
unauthorized effects after an error response and a permitted state update.
Fairness fixtures cover an eligibility bubble with the default preserve-history
policy and the explicit `CLEAR_ON_INELIGIBLE` policy. Clock-gate fixtures check
source and gated edges, including an update in the NBA region. Shared lifecycle
checks include assertions for known reset and enable controls. They have not
been exercised with X/Z values and do not establish four-state behavior.

Reset fixtures distinguish an aligned release from a release later in the high
phase and an insufficient assertion duration.

The runner retains build commands, compiler/runtime logs, tool version, input
hashes before and after execution, individual case results and interruption
status. Modified inputs invalidate the run. Builds are bounded by worker count
and timeout; each fixture has a private build directory. Process groups are
terminated on SIGINT or SIGTERM and the partial report remains available. The
runner records the signal and returns 130 or 143 respectively. Runtime compiler
warnings are fatal; strict language warnings also fail.

The coherent 53-fixture gate covers base activation, configured policy variants,
and invalid-policy diagnostics for the current test matrix. Follow-up fairness
and gate-edge cases cover eligibility pause/clear behavior and active/NBA edge
observation. Nondefault host elaboration covers 128-bit known/stable checkers
and interrupts with bit 127 set in the reset mask, and a FIFO depth of 17.
Three configuration fixtures reject a negative counter minimum, a negative
address base and a region beyond the address width. They keep the clock stopped
and checking disabled, so only the unconditional configuration diagnostic can
make them pass. A 128-bit interrupt fixture independently checks that the high
reset bit survives reset, clears correctly and fails when missing. The wide
module host elaborates under slang; runtime uses the native declaration factory.
Remaining work includes uncovered family-specific
boundaries and simultaneous-event combinations, coverage/vacuity review,
four-state simulation, formal proof, and alternate simulator qualification.
The host modules are slang-elaborated but are not
runtime-tested in Verilator because it does not support nested checker
declarations.
