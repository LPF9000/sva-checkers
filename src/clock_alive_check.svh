// SPDX-License-Identifier: MIT
`ifndef SVA_CLOCK_ALIVE_CHECK_SVH
`define SVA_CLOCK_ALIVE_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_CLOCK_ALIVE_CHECK(NAME, START_DEADLINE, MAX_GAP) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic signal_clock, \
    input logic expected_running \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    realtime last_edge; \
    realtime start_time; \
    bit edge_seen; \
    bit window_seen; \
    always_ff @(posedge signal_clock or negedge reset_n or negedge enable or negedge expected_running) begin \
        if (!reset_n || !enable || !expected_running) begin \
            last_edge <= 0.0; \
            edge_seen <= 0; \
        end else begin \
            last_edge <= $realtime; \
            edge_seen <= 1; \
        end \
    end \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable || !expected_running) begin \
            window_seen <= 0; \
            start_time  <= 0.0; \
        end else begin \
            if (!window_seen) begin \
                start_time  <= $realtime; \
                window_seen <= 1; \
            end \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (START_DEADLINE > 0 && MAX_GAP > 0) \
        else $error("CLOCK_ALIVE_CFG"); \
    end \
    a_control : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {expected_running, signal_clock} \
    )) \
    else $error("CLOCK_ALIVE_KNOWN"); \
    a_alive : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !expected_running || !window_seen || (edge_seen ? $realtime-last_edge<=MAX_GAP : $realtime-start_time<=START_DEADLINE)) \
    else $error("CLOCK_ALIVE_DEADLINE"); \
endchecker : NAME

`endif
