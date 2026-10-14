// SPDX-License-Identifier: MIT
`ifndef SVA_CLOCK_GATE_CHECK_SVH
`define SVA_CLOCK_GATE_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_CLOCK_GATE_CHECK(NAME, PARK_LEVEL, STOP_SAMPLES, MIN_PULSE_SAMPLES) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic source_clock, \
    input logic gated_clock, \
    input logic gate_enable \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    const logic park_bit = PARK_LEVEL; \
    bit previous_source; \
    bit previous_gated; \
    bit seen; \
    int disabled_samples; \
    int pulse_samples; \
    bit actual_seen; \
    bit actual_source; \
    bit actual_gated; \
    realtime source_edge_time; \
    always_ff @(posedge source_clock or negedge source_clock or \
            posedge gated_clock or negedge gated_clock or \
            posedge enable or negedge enable or negedge reset_n) begin \
        if (!reset_n || !enable) begin \
            actual_seen <= 0; \
            actual_source <= source_clock; \
            actual_gated <= gated_clock; \
            source_edge_time <= -1.0; \
        end else begin \
            if (actual_seen && gated_clock != actual_gated) begin \
                a_actual_edge : \
                assert (gated_clock == source_clock && \
                    (source_clock != actual_source || $realtime == source_edge_time)) \
                else $error("CLOCK_GATE_EDGE"); \
            end \
            if (source_clock != actual_source) source_edge_time <= $realtime; \
            actual_source <= source_clock; \
            actual_gated  <= gated_clock; \
            actual_seen   <= 1; \
        end \
    end \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            previous_source <= 0; \
            previous_gated <= park_bit; \
            seen <= 0; \
            disabled_samples <= 0; \
            pulse_samples <= 0; \
        end else begin \
            previous_source <= source_clock; \
            previous_gated <= gated_clock; \
            seen <= 1; \
            disabled_samples<=gate_enable ? 0 : (disabled_samples<STOP_SAMPLES ? disabled_samples+1 : disabled_samples); \
            pulse_samples<=gated_clock!=previous_gated ? 1 : (pulse_samples<MIN_PULSE_SAMPLES ? pulse_samples+1 : pulse_samples); \
        end \
    end \
    initial begin \
        a_cfg : \
        assert ((PARK_LEVEL == 0 || PARK_LEVEL == 1) && STOP_SAMPLES > 0 && MIN_PULSE_SAMPLES > 0) \
        else $error("CLOCK_GATE_CFG"); \
    end \
    a_known : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {source_clock, gated_clock, gate_enable} \
    )) \
    else $error("CLOCK_GATE_KNOWN"); \
    a_edge : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !seen || gated_clock==previous_gated || (source_clock!=previous_source && gated_clock==source_clock)) \
    else $error("CLOCK_GATE_EDGE"); \
    a_width : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !seen || gated_clock==previous_gated || pulse_samples==0 || pulse_samples>=MIN_PULSE_SAMPLES) \
    else $error("CLOCK_GATE_WIDTH"); \
    a_park : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        gate_enable || disabled_samples<STOP_SAMPLES || gated_clock==park_bit) \
    else $error("CLOCK_GATE_PARK"); \
    a_follow : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !gate_enable || !seen || gated_clock==source_clock) \
    else $error("CLOCK_GATE_FOLLOW"); \
endchecker : NAME

`endif
