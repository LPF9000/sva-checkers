// SPDX-License-Identifier: MIT
`ifndef SVA_EVENT_CONSERVATION_CHECK_SVH
`define SVA_EVENT_CONSERVATION_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_EVENT_CONSERVATION_CHECK(NAME, CAPACITY, MAX_BUSY_CYCLES, ALLOW_BYPASS, REQUIRE_DRAIN) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic accepted, \
    input logic completed, \
    input logic canceled, \
    input logic drain \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    int outstanding; \
    int busy_cycles; \
    longint signed next_count; \
    always_comb \
        next_count = longint'(outstanding) + longint'(accepted) - longint'(completed) - longint'(canceled); \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            outstanding <= 0; \
            busy_cycles <= 0; \
        end else if (next_count >= 0 && next_count <= CAPACITY) begin \
            outstanding <= int'(next_count); \
            busy_cycles <= next_count == 0 ? 0 : (outstanding == 0 ? 1 : busy_cycles + 1); \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (CAPACITY > 0 && MAX_BUSY_CYCLES >= 0) \
        else $error("CONSERVATION_CFG"); \
    end \
    a_events : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {accepted, completed, canceled, drain} \
    ) && !(completed && canceled)) \
    else $error("CONSERVATION_EVENTS"); \
    a_count : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        next_count >= 0 && next_count <= CAPACITY && \
        (!(completed || canceled) || outstanding > 0 || (ALLOW_BYPASS && accepted))) \
    else $error("CONSERVATION_COUNT"); \
    a_deadline : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        MAX_BUSY_CYCLES == 0 || outstanding == 0 || busy_cycles <= MAX_BUSY_CYCLES) \
    else $error("CONSERVATION_DEADLINE"); \
    a_drain : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !drain || next_count == 0) \
    else $error("CONSERVATION_DRAIN"); \
    final if (REQUIRE_DRAIN && outstanding != 0) $error("CONSERVATION_FINAL_DRAIN"); \
endchecker : NAME

`endif
