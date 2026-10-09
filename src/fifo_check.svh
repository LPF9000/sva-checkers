// SPDX-License-Identifier: MIT
`ifndef SVA_FIFO_CHECK_SVH
`define SVA_FIFO_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_FIFO_CHECK(NAME, DEPTH, ALLOW_EMPTY_BYPASS, ALLOW_FULL_EXCHANGE) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic push, \
    input logic pop, \
    input logic empty, \
    input logic full, \
    input int unsigned occupancy \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    int expected_count; \
    longint signed next_count; \
    always_comb next_count = longint'(expected_count) + longint'(push) - longint'(pop); \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) expected_count <= 0; \
        else if (next_count >= 0 && next_count <= DEPTH) expected_count <= int'(next_count); \
    end \
    initial begin \
        a_cfg : \
        assert (DEPTH > 0) \
        else $error("FIFO_CFG"); \
    end \
    a_state : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {push, pop, empty, full, occupancy} \
    ) && longint'(occupancy) == longint'(expected_count) && empty == (expected_count == 0) && \
        full == (expected_count == DEPTH)) \
    else $error("FIFO_STATE"); \
    a_events : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        next_count >= 0 && next_count <= DEPTH && \
        (!pop || expected_count != 0 || (ALLOW_EMPTY_BYPASS && push)) && \
        (!push || expected_count != DEPTH || (ALLOW_FULL_EXCHANGE && pop))) \
    else $error("FIFO_EVENTS"); \
endchecker : NAME

`endif
