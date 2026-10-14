// SPDX-License-Identifier: MIT
`ifndef SVA_LIFECYCLE_CHECK_SVH
`define SVA_LIFECYCLE_CHECK_SVH
`define SVA_ASSERT_LIFECYCLE(CLOCK, RESET, ENABLE) \
    a_lifecycle_known: assert property (@(posedge CLOCK) !$isunknown({RESET, ENABLE})) \
        else $error("CHECKER_LIFECYCLE_KNOWN");
`endif
