// SPDX-License-Identifier: MIT
`ifndef SVA_CLOCK_DIVIDER_CHECK_SVH
`define SVA_CLOCK_DIVIDER_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_CLOCK_DIVIDER_CHECK(NAME, DIVISOR, STARTUP_EDGES) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic source_clock, \
    input logic divided_clock \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    bit previous_source; \
    bit previous_output; \
    bit seen_output; \
    bit seen_sample; \
    int source_edges; \
    int startup_edges; \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            previous_source <= 0; \
            previous_output <= 0; \
            seen_output <= 0; \
            seen_sample <= 0; \
            source_edges <= 0; \
            startup_edges <= 0; \
        end else begin \
            previous_source <= source_clock; \
            previous_output <= divided_clock; \
            seen_sample <= 1; \
            if (!previous_source && source_clock) begin \
                source_edges <= source_edges < DIVISOR + 1 ? source_edges + 1 : source_edges; \
                startup_edges<=startup_edges<STARTUP_EDGES+1 ? startup_edges+1 : startup_edges; \
            end \
            if (!previous_output && divided_clock) begin \
                seen_output   <= 1; \
                source_edges  <= 0; \
                startup_edges <= 0; \
            end \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (DIVISOR>0 && DIVISOR<2147483646 && STARTUP_EDGES>=DIVISOR && STARTUP_EDGES<2147483646) \
        else $error("CLOCK_DIVIDER_CFG"); \
    end \
    a_known : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {source_clock, divided_clock} \
    )) \
    else $error("CLOCK_DIVIDER_KNOWN"); \
    a_alignment : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !seen_sample || previous_output || !divided_clock || (!previous_source && source_clock)) \
    else $error("CLOCK_DIVIDER_ALIGNMENT"); \
    a_ratio : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !seen_output || previous_output || !divided_clock || source_edges+int'(!previous_source && source_clock)==DIVISOR) \
    else $error("CLOCK_DIVIDER_RATIO"); \
    a_alive : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        (seen_output ? source_edges<=DIVISOR : startup_edges<=STARTUP_EDGES)) \
    else $error("CLOCK_DIVIDER_DEADLINE"); \
endchecker : NAME

`endif
