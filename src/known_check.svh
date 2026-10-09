// SPDX-License-Identifier: MIT
`ifndef SVA_KNOWN_CHECK_SVH
`define SVA_KNOWN_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_KNOWN_CHECK(NAME, WIDTH) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic [WIDTH-1:0] value, \
    input logic [WIDTH-1:0] valid_mask \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    initial begin \
        a_cfg : \
        assert (WIDTH > 0) \
        else $error("KNOWN_CFG"); \
    end \
    a_known : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        value & valid_mask \
    ) && !$isunknown( \
        valid_mask \
    )) \
    else $error("KNOWN_VALUE"); \
endchecker : NAME

`endif
