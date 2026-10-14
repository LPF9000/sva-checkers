// SPDX-License-Identifier: MIT
`ifndef SVA_ENCODING_CHECK_SVH
`define SVA_ENCODING_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_ENCODING_CHECK(NAME, WIDTH, MODE, LEGAL_VALUES, TRANSITIONS) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic [WIDTH-1:0] value \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    const logic [15:0] legal_bits = LEGAL_VALUES; \
    const logic [255:0] transition_bits = TRANSITIONS; \
    logic [WIDTH-1:0] previous; \
    bit past_valid; \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            previous   <= '0; \
            past_valid <= 0; \
        end else begin \
            previous   <= value; \
            past_valid <= 1; \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (WIDTH > 0 && (MODE != 2 || WIDTH <= 4) && MODE >= 0 && MODE <= 2) \
        else $error("ENCODING_CFG"); \
    end \
    a_encoding : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        value \
    ) && ((MODE == 0 && $onehot( \
        value \
    )) || (MODE == 1 && $onehot0( \
        value \
    )) || (MODE == 2 && legal_bits[int'(value)]))) \
    else $error("ENCODING_VALUE"); \
    a_transition : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        (MODE != 2 || !past_valid || transition_bits[(int'(previous) * 16) + int'(value)])) \
    else $error("ENCODING_TRANSITION"); \
endchecker : NAME

`endif
