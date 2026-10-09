// SPDX-License-Identifier: MIT
`ifndef SVA_STABLE_CHECK_SVH
`define SVA_STABLE_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_STABLE_CHECK_DIAGNOSTIC(NAME, WIDTH, DIAGNOSTIC) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic hold, \
    input logic [WIDTH-1:0] value, \
    input logic [WIDTH-1:0] valid_mask \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    initial begin \
        a_cfg : \
        assert (WIDTH > 0) \
        else $error("STABLE_CFG"); \
    end \
    a_known_hold : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {hold, valid_mask} \
    )) \
    else $error("STABLE_CONTROL"); \
    a_stable : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) hold |=> !$isunknown( \
        (value ^ $past(value)) & $past(valid_mask) \
    ) && (((value ^ $past( \
        value \
    )) & $past( \
        valid_mask \
    )) == '0)) \
    else $error(DIAGNOSTIC); \
endchecker : NAME

`define SVA_DECLARE_STABLE_CHECK(NAME, WIDTH) \
    `SVA_DECLARE_STABLE_CHECK_DIAGNOSTIC(NAME, WIDTH, "STABLE_VALUE")

`endif
