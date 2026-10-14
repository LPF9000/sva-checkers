// SPDX-License-Identifier: MIT
`ifndef SVA_INTERRUPT_CHECK_SVH
`define SVA_INTERRUPT_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_INTERRUPT_CHECK(NAME, WIDTH, RESET_PENDING, SET_WINS, MASK_CAPTURE, MAX_LATENCY, PULSE_MODE) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic [WIDTH-1:0] cause, \
    input logic [WIDTH-1:0] clear, \
    input logic [WIDTH-1:0] mask, \
    input logic [WIDTH-1:0] pending_value, \
    input logic global_enable, \
    input logic interrupt \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    const logic [WIDTH-1:0] reset_pending_value = RESET_PENDING; \
    logic [WIDTH-1:0] expected_pending; \
    logic [WIDTH-1:0] captured; \
    bit eligible; \
    bit delivered; \
    int wait_cycles; \
    always_comb begin \
        captured = MASK_CAPTURE ? (cause & ~mask) : cause; \
        eligible = global_enable && ((expected_pending & ~mask) != '0); \
    end \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            expected_pending <= reset_pending_value; \
            wait_cycles <= 0; \
            delivered <= 0; \
        end else begin \
            expected_pending<=SET_WINS ? ((expected_pending & ~clear) | captured) : ((expected_pending | captured) & ~clear); \
            if (!eligible) begin \
                wait_cycles <= 0; \
                delivered   <= 0; \
            end else if (interrupt) begin \
                wait_cycles <= 0; \
                delivered   <= 1; \
            end else if (wait_cycles < MAX_LATENCY) wait_cycles <= wait_cycles + 1; \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (WIDTH > 0 && MAX_LATENCY > 0 && MAX_LATENCY < 2147483647) \
        else $error("INTERRUPT_CFG"); \
    end \
    a_pending : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {cause, clear, mask, global_enable, interrupt, pending_value} \
    ) && pending_value == expected_pending) \
    else $error("INTERRUPT_PENDING"); \
    a_delivery : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !interrupt || (eligible && (!PULSE_MODE || !delivered))) \
    else $error("INTERRUPT_SPURIOUS"); \
    a_latency : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !eligible || (PULSE_MODE && delivered) || interrupt || wait_cycles<MAX_LATENCY-1) \
    else $error("INTERRUPT_LATENCY"); \
endchecker : NAME

`endif
