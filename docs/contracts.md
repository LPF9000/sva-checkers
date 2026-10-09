# Checker contracts

All boolean events are sampled accepted events; a held valid signal is not implicitly an event. Unless stated otherwise, reset or disable clears reference state and cancels temporal obligations. Clock periods use the enclosing 1ns/1ps time scale. See README for declaration and tool support.

## known_check

Each enabled rising edge checks only mask-selected bits. Unknown masks are errors. Reset/disable abort checking; there is no history.

Parameters: `WIDTH=8`.

## stable_check

A sampled hold obligates the next sample to preserve the previously selected bits, including the release edge. Inactive bits may change; unknown active values fail. Reset/disable cancel obligations.

Parameters: `WIDTH=8`.

## encoding_check

MODE 0 is one-hot, 1 one-hot-or-zero, 2 legal numeric values plus a 16x16 transition bitmap. MODE 2 supports width 1..4 for this bounded numeric state-space profile; one-hot modes accept any positive width; unsupported settings fail CFG. Rows are old states, columns new states. Reset/disable clear history.

Parameters: `WIDTH=4`, `MODE=0`, `LEGAL_VALUES=16'hffff`, `TRANSITIONS=256'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff`.

## counter_check

Commands at sample N define value at N+1. Load takes precedence; simultaneous increment/decrement is prohibited. Wrap or saturation is explicit; otherwise crossing bounds fails. Width<=32; widened arithmetic precedes truncation. Reset/disable establish a new baseline.

Parameters: `WIDTH=8`, `MIN_VALUE=0`, `MAX_VALUE=255`, `STEP=1`, `SATURATE=0`, `WRAP=0`.

## event_conservation_check

Single accepted/completed/canceled events per sample. Terminal types are exclusive. Capacity uses widened next-count arithmetic. Same-cycle acceptance can fund a terminal only with ALLOW_BYPASS. Deadline bounds a nonempty batch, not individual out-of-order IDs. drain checks post-event count; final drain optional. Reset/disable discard tracked work.

Parameters: `CAPACITY=4`, `MAX_BUSY_CYCLES=8`, `ALLOW_BYPASS=0`, `REQUIRE_DRAIN=1`.

## credit_check

Counts are accepted credit consumption/returns, not valid levels. SAME_CYCLE_RETURN determines whether returned credits can fund consumption in that sample. ALLOW_ZERO_LATENCY_RETURN independently determines whether consumption can produce a return in the same sample. Without that second policy, returns may refer only to pre-existing unavailable credits. Capacity and permitted returns are checked separately. INITIAL_CREDITS can represent initial unavailable credits. Reset/disable restore initial credits.

Parameters: `CAPACITY=4`, `INITIAL_CREDITS=4`, `SAME_CYCLE_RETURN=0`, `ALLOW_ZERO_LATENCY_RETURN=0`.

## address_check

Only accepted accesses are checked. Byte count must be nonzero. The entire widened span must stay in one configured inclusive region without address overflow; alignment and read/write permission are explicit. Compose instances for multiple distinct regions through caller-selected enable.

Parameters: `ADDR_WIDTH=32`, `SIZE_WIDTH=8`, `BASE_ADDR=0`, `LAST_ADDR=4095`, `ALIGNMENT=4`.

## fifo_check

push/pop mean accepted operations. Occupancy/flags describe pre-event state at the sampling edge. Empty bypass and full exchange are independent policies. Reset/disable clear the reference occupancy; only empty-reset FIFOs fit this contract. Data ordering belongs to data_integrity_check.

Parameters: `DEPTH=4`, `ALLOW_EMPTY_BYPASS=0`, `ALLOW_FULL_EXCHANGE=1`.

## pulse_check

Pulse length counts sampled high cycles; gaps count sampled low cycles. First pulse has no prior-spacing requirement. Enabling while high starts a new pulse. Reset/disable cancel partial pulses. MAX_CYCLES also detects a pulse that never falls.

Parameters: `MIN_CYCLES=1`, `MAX_CYCLES=3`, `MIN_GAP=2`.

## reset_check

Independent checker reset_n controls model lifetime; observed_reset_n is the DUT reset under test. Assertion duration is measured in reference rising samples. When RELEASE_ON_RISE is set, release must occur at the same simulation time as a reference rising edge. Both active-region and nonblocking synchronous release are supported; a release later in the high phase fails. The event-time alignment model is a simulation check, separately from sampled duration/value assertions. Masked reset values are checked during assertion; consumers choose settled observation timing.

Parameters: `WIDTH=8`, `MIN_CYCLES=2`, `RESET_VALUE=0`, `RELEASE_ON_RISE=1`.

## ordering_check

Bounded accepted-request table tracks IDs, per-request age, insertion order, and independent cancellation. Completions match the oldest active occurrence of an ID; IN_ORDER also requires global oldest. Terminal events consume existing entries before same-cycle acceptance, permitting reuse of a just-freed ID. New same-cycle work cannot complete immediately. Completed and canceled may coexist for different entries. Duplicate IDs are optional but per-ID completion order remains FIFO. Ages enforce inclusive MAX_LATENCY cycles; 0 disables deadline. drain and final drain check completeness. Reset/disable cancel the model.

Parameters: `ID_WIDTH=4`, `DATA_WIDTH=8`, `CAPACITY=4`, `MAX_LATENCY=8`, `IN_ORDER=1`, `ALLOW_ID_REUSE=0`, `CHECK_DATA=0`, `REQUIRE_DRAIN=1`.

## data_integrity_check

Uses the accepted-request ID table contract of ordering_check and additionally captures caller-derived expected data and valid-bit mask at acceptance. Compare accepted completion only on captured valid bits. Consumers own transformation/byte-enable semantics; this checker does not mirror DUT calculations. Unknown valid expected/actual bits fail. Invalid bits may differ.

Parameters: `ID_WIDTH=4`, `DATA_WIDTH=8`, `CAPACITY=4`, `MAX_LATENCY=8`, `IN_ORDER=1`, `ALLOW_ID_REUSE=0`, `CHECK_DATA=1`, `REQUIRE_DRAIN=1`.

## handshake_check

FIFO accepted-request lifetime model with inclusive per-request latency, capacity, cancellation, drain and optional zero-latency empty bypass. One request and one terminal per sample. Backpressure acceptance is defined by the caller, normally valid&&ready. ID correlation is separate in ordering_check.

Parameters: `CAPACITY=4`, `MAX_LATENCY=8`, `ALLOW_BYPASS=0`, `REQUIRE_DRAIN=1`.

## ownership_check

Exclusive owner bitmap; release then grant determines next owner, allowing same-cycle handoff. Access uses pre-edge ownership, so new grants take effect next cycle. Release must come from an existing owner and redundant grants fail. Multiple-reader ownership is outside this exclusive profile.

Parameters: `USERS=4`.

## fairness_check

Counts consecutive eligible arbitration opportunities (or elapsed samples) with an asserted request and no grant. Grant on opportunity MAX_WAIT is allowed; absence fails on that opportunity. Request withdrawal or grant clears the obligation. Eligibility loss pauses the count and preserves wait history by default; CLEAR_ON_INELIGIBLE explicitly selects clearing instead. This is a bounded policy, not an unqualified fairness proof.

Parameters: `REQUESTERS=4`, `MAX_WAIT=3`, `COUNT_ELAPSED=0`.

## length_check

start captures commanded bytes; accepted beat consumes valid_bytes. last must coincide with exact remaining byte count, not merely a beat count. start and beat/cancel cannot coincide; cancellation discards remaining payload. Beat span must stay within the start region and address width. Address progression is a separate contract. Final incomplete transfer fails.

Parameters: `MAX_LENGTH=16`, `BOUNDARY_BYTES=1024`, `ADDR_WIDTH=32`.

## clock_timing_check

Measures actual signal-clock event times at the enclosing time precision, using realtime bounds and duty percentages. First partial cycle is ignored until a complete rise/fall interval exists. Frequency bounds are expressed by inverse period bounds. Independent clk samples X/Z and configuration; absence of edges requires clock_alive_check. Disable/reset clear edge history asynchronously.

Parameters: `MIN_PERIOD=8ns`, `MAX_PERIOD=12ns`, `MIN_HIGH=2ns`, `MAX_HIGH=8ns`, `MIN_LOW=2ns`, `MAX_LOW=8ns`, `MIN_DUTY=25.0`, `MAX_DUTY=75.0`.

## clock_alive_check

Actual rising signal-clock edges update last-edge time. An independent always-running reference clk checks startup and stoppage deadlines; failure is observed at its first sample after the bound. expected_running=0 permits stopped clocks and cancels the watchdog window. Startup begins at the first reference sample that expects running. Reference-clock liveness is an external assumption.

Parameters: `START_DEADLINE=20ns`, `MAX_GAP=20ns`.

## clock_gate_check

Every actual gated edge must match a source edge at the same simulation time and level, including NBA-delayed propagation. An edge between reference samples is still checked. Sampled pulse-width, parking and following rules additionally require a sufficiently fast independent reference clock. Compose clock_timing_check and clock_alive_check for continuous pulse bounds and missing-edge deadlines.

Sampled edge/park model: clk must oversample both clocks so every transition is seen and full pulses span MIN_PULSE_SAMPLES. Each gated transition must coincide with a sampled source transition to the same level; enabled samples follow source, disabled samples reach PARK_LEVEL by STOP_SAMPLES. This model does not claim detection of sub-reference-sample glitches; compose real-time timing checks for that requirement.

Parameters: `PARK_LEVEL=0`, `STOP_SAMPLES=2`, `MIN_PULSE_SAMPLES=2`.

## clock_divider_check

Independent reference clk oversamples both clocks. Output rising edges align with sampled source rising edges; after the first output rise exactly DIVISOR source rises occur per output-rise interval. Startup is bounded in source rises, not wall time; combine alive checks for stopped sources. This does not prescribe divider duty cycle or output falling phase.

Parameters: `DIVISOR=2`, `STARTUP_EDGES=4`.

## register_check

Reference shadow supports disjoint RW/W1C/W1S fields, read-clear mask, accepted write mask and hardware set/clear. HW_AFTER_SW defines hardware versus software priority; SET_WINS defines set/clear priority. Reads compare pre-event shadow at the same sampling edge; delayed bus responses need a separate correlation model. value is pre-event storage state, checked every enabled edge. Write masks are bit masks (caller expands byte strobes). Reset/disable require RESET_VALUE on the next enabled sample.

Parameters: `WIDTH=8`, `RESET_VALUE=0`, `RW_MASK=8'h0f`, `W1C_MASK=8'hf0`, `W1S_MASK=0`, `READ_CLEAR_MASK=0`, `SET_WINS=1`, `HW_AFTER_SW=1`.

## error_propagation_check

Single outstanding error expectation: error_trigger captures its ID; matching error terminal must occur 1..MAX_LATENCY cycles later. Normal terminals when no error is pending are outside this checker. forbidden_effect is a consumer-defined prohibited effect, blocked from trigger through explicit recover, including after the error response. Earlier committed work is not implicitly rolled back. Recover cannot discard an unreported pending error.

Parameters: `ID_WIDTH=4`, `CODE_WIDTH=2`, `ERROR_CODE=1`, `MAX_LATENCY=3`.

## configuration_check

Accepted updates create pending values; commit at a legal boundary applies the old pending value for the next sample. Simultaneous commit/update applies old and queues new. Replacing pending work is explicit; replacement starts a new deadline. No silent queue exists. Active value is checked every edge; reset/disable restore RESET_VALUE and drop pending work. Commit without pending work fails, including same-cycle first update.

Parameters: `WIDTH=8`, `RESET_VALUE=0`, `MAX_LATENCY=3`, `REPLACE_PENDING=0`.

## interrupt_check

Shadow pending bits follow cause/clear priority. Masking suppresses delivery; MASK_CAPTURE separately chooses whether masked events are captured. Eligible pending work requires a level interrupt within MAX_LATENCY samples, or one pulse per uninterrupted eligible window in PULSE_MODE. A delivered pulse discharges that window; dropping eligibility rearms. pending_value is pre-edge storage. Pulse width can be checked separately.

Parameters: `WIDTH=4`, `RESET_PENDING=0`, `SET_WINS=1`, `MASK_CAPTURE=0`, `MAX_LATENCY=2`, `PULSE_MODE=0`.

## access_control_check

`forbidden_effect` must always remain false while enabled. A denied write establishes a protected-value guard that persists after the error response. Only a caller-authorized `protected_update_allowed` event releases that guard; the caller must derive it independently from allowed software/hardware updates. Checking an error response never substitutes for checking state and effects.

Single denied access pending; caller evaluates identity/privilege/region/security permissions independently and supplies authorized at acceptance. Denied write holds observable protected_value unchanged until its error response; denied read returns DENIED_READ_VALUE. forbidden_effect identifies additional prohibited effects. There must be no competing legitimate modification of the protected observation during this interval. Delayed or ID-reordered traffic requires separate trackers.

Parameters: `WIDTH=8`, `MAX_LATENCY=3`, `DENIED_READ_VALUE=0`.

## locking_check

Explicit lock acceptance captures the protected value; while locked, writes and observed changes fail. LOCK_WINS decides whether a write on the locking edge is prohibited. permitted_unlock and clear_lock_reset are independently derived allowed lifecycle events; checker reset cancels all state, so warm resets that preserve locks must not drive checker reset_n. Lock/unlock on one sample is forbidden.

Parameters: `WIDTH=8`, `LOCK_WINS=1`.

## zeroization_check

request starts a bounded operation; acknowledge requires every configured location to be currently visible and equal CLEARED_VALUE. A prior sample of clearing is insufficient if storage becomes dirty again. Sensitive operations and stale results are prohibited from request through acknowledgment. No access to storage means no proof of clearing. Reset/disable cancel model state; physical remanence is outside this digital checker.

Parameters: `LOCATIONS=4`, `DATA_WIDTH=8`, `CLEARED_VALUE=0`, `MAX_LATENCY=3`.

## quiescence_check

Shutdown moves running to draining; acknowledgment requires zero outstanding work and no new acceptance. Quiescent prohibits selected new work/effects until a wake edge; explicitly permitted status/wake traffic is not included in forbidden_activity. Wake takes effect next sample. Drain acceptance is configurable; shutdown and acknowledge cannot shortcut the drain stage. Reset/disable return to running.

Parameters: `MAX_LATENCY=3`, `ALLOW_NEW_DURING_DRAIN=0`.

## cancellation_check

Bounded ID+generation table. Flush increments generation with explicit overflow rejection and cancels all uncommitted work; committed entries are exempt and may complete with old tags. Explicit cancel targets one uncommitted entry. Flush/cancel apply before responses on the boundary; new acceptance is prohibited on that boundary. With REQUIRE_CANCEL_RESPONSE, affected entries require tagged cancellation terminals; otherwise they are removed and any later response fails. flush_ack requires affected entries cleaned up; acknowledgment and cancellation responses have inclusive deadlines. Same ID in different generations is supported. Checker reset requires generation zero and drops all work.

Parameters: `ID_WIDTH=4`, `GEN_WIDTH=4`, `CAPACITY=4`, `MAX_LATENCY=3`, `REQUIRE_CANCEL_RESPONSE=0`, `REQUIRE_DRAIN=1`.


## Common lifecycle controls

Each checker requires known reset_n and enable at every live reference-clock sample, including while disabled or in reset. CHECKER_LIFECYCLE_KNOWN reports violations independently of functional disable conditions. Four-state activation requires a four-state simulator.
