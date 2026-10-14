// SPDX-License-Identifier: MIT
`ifndef SVA_RESET_CHECK_SVH
`define SVA_RESET_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_RESET_CHECK(NAME, WIDTH, MIN_CYCLES, RESET_VALUE, RELEASE_ON_RISE) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic observed_reset_n, \
    input logic [WIDTH-1:0] value, \
    input logic [WIDTH-1:0] valid_mask \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    const logic [WIDTH-1:0] reset_bits = RESET_VALUE; \
    realtime last_rise_time; \
    bit previous_clock; \
    bit previous_reset; \
    always_ff @(posedge clk or negedge clk or posedge observed_reset_n or negedge observed_reset_n or negedge reset_n or negedge enable) begin \
        if (!reset_n || !enable) begin \
            previous_clock <= clk; \
            previous_reset <= observed_reset_n; \
            last_rise_time <= -1.0; \
        end else begin \
            if (clk && !previous_clock) last_rise_time <= $realtime; \
            if (observed_reset_n && !previous_reset) begin \
                a_alignment : \
                assert (!RELEASE_ON_RISE || \
                    (clk && (!previous_clock || $realtime == last_rise_time))) \
                else $error("RESET_ALIGNMENT"); \
            end \
            previous_clock <= clk; \
            previous_reset <= observed_reset_n; \
        end \
    end \
    int asserted_cycles; \
    bit was_reset; \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            asserted_cycles <= 0; \
            was_reset <= 0; \
        end else if (!observed_reset_n) begin \
            asserted_cycles <= asserted_cycles < MIN_CYCLES ? asserted_cycles + 1 : asserted_cycles; \
            was_reset <= 1; \
        end else begin \
            asserted_cycles <= 0; \
            was_reset <= 0; \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (WIDTH > 0 && MIN_CYCLES > 0) \
        else $error("RESET_CFG"); \
    end \
    a_values : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        observed_reset_n \
    ) && (observed_reset_n || (!$isunknown( \
        value & valid_mask \
    ) && ((value & valid_mask) == (reset_bits & valid_mask))))) \
    else $error("RESET_VALUES"); \
    a_duration : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !observed_reset_n || !was_reset || asserted_cycles >= MIN_CYCLES) \
    else $error("RESET_DURATION"); \
endchecker : NAME

`endif
