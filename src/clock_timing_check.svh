// SPDX-License-Identifier: MIT
`ifndef SVA_CLOCK_TIMING_CHECK_SVH
`define SVA_CLOCK_TIMING_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_CLOCK_TIMING_CHECK(NAME, MIN_PERIOD, MAX_PERIOD, MIN_HIGH, MAX_HIGH, MIN_LOW, MAX_LOW, MIN_DUTY, MAX_DUTY) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic signal_clock \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    realtime rise_time; \
    realtime fall_time; \
    realtime high_time; \
    bit rise_seen; \
    bit fall_seen; \
    always_ff @(posedge signal_clock or negedge reset_n or negedge enable) begin \
        if (!reset_n || !enable) begin \
            rise_time <= 0.0; \
            rise_seen <= 0; \
        end else begin \
            rise_time <= $realtime; \
            rise_seen <= 1; \
        end \
    end \
    always_ff @(negedge signal_clock or negedge reset_n or negedge enable) begin \
        if (!reset_n || !enable) begin \
            fall_time <= 0.0; \
            high_time <= 0.0; \
            fall_seen <= 0; \
        end else begin \
            fall_time <= $realtime; \
            high_time <= $realtime - rise_time; \
            fall_seen <= rise_seen; \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (MIN_PERIOD>0 && MAX_PERIOD>=MIN_PERIOD && MIN_HIGH>0 && MAX_HIGH>=MIN_HIGH && MIN_LOW>0 && MAX_LOW>=MIN_LOW && MIN_DUTY>0 && MAX_DUTY<100 && MIN_DUTY<=MAX_DUTY) \
        else $error("CLOCK_TIMING_CFG"); \
    end \
    a_known : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown(signal_clock)) \
    else $error("CLOCK_TIMING_KNOWN"); \
    a_period : \
    assert property (@(posedge signal_clock) disable iff (!reset_n || !enable) \
        !rise_seen || ($realtime-rise_time>=MIN_PERIOD && $realtime-rise_time<=MAX_PERIOD)) \
    else $error("CLOCK_PERIOD"); \
    a_high : \
    assert property (@(negedge signal_clock) disable iff (!reset_n || !enable) \
        !rise_seen || ($realtime-rise_time>=MIN_HIGH && $realtime-rise_time<=MAX_HIGH)) \
    else $error("CLOCK_HIGH_WIDTH"); \
    a_low : \
    assert property (@(posedge signal_clock) disable iff (!reset_n || !enable) \
        !fall_seen || ($realtime-fall_time>=MIN_LOW && $realtime-fall_time<=MAX_LOW)) \
    else $error("CLOCK_LOW_WIDTH"); \
    a_duty : \
    assert property (@(posedge signal_clock) disable iff (!reset_n || !enable) \
        !rise_seen || !fall_seen || ($realtime>rise_time && high_time*100.0>=MIN_DUTY*($realtime-rise_time) && high_time*100.0<=MAX_DUTY*($realtime-rise_time))) \
    else $error("CLOCK_DUTY"); \
endchecker : NAME

`endif
