// SPDX-License-Identifier: MIT
`ifndef SVA_PULSE_CHECK_SVH
`define SVA_PULSE_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_PULSE_CHECK(NAME, MIN_CYCLES, MAX_CYCLES, MIN_GAP) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic pulse \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    int high_cycles; \
    int low_cycles; \
    bit seen_pulse; \
    bit previous; \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            high_cycles <= 0; \
            low_cycles <= 0; \
            seen_pulse <= 0; \
            previous <= 0; \
        end else begin \
            previous <= pulse; \
            if (pulse) begin \
                high_cycles <= previous ? high_cycles + 1 : 1; \
                low_cycles  <= 0; \
                seen_pulse  <= 1; \
            end else begin \
                low_cycles  <= previous ? 1 : (low_cycles < MIN_GAP ? low_cycles + 1 : low_cycles); \
                high_cycles <= 0; \
            end \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (MIN_CYCLES > 0 && MAX_CYCLES >= MIN_CYCLES && MIN_GAP >= 0) \
        else $error("PULSE_CFG"); \
    end \
    a_known : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown(pulse)) \
    else $error("PULSE_KNOWN"); \
    a_width : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        (pulse ? (!previous || high_cycles < MAX_CYCLES) : (!previous || high_cycles >= MIN_CYCLES))) \
    else $error("PULSE_WIDTH"); \
    a_spacing : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !pulse || previous || !seen_pulse || low_cycles >= MIN_GAP) \
    else $error("PULSE_SPACING"); \
endchecker : NAME

`endif
