// SPDX-License-Identifier: MIT
`ifndef SVA_ZEROIZATION_CHECK_SVH
`define SVA_ZEROIZATION_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_ZEROIZATION_CHECK(NAME, LOCATIONS, DATA_WIDTH, CLEARED_VALUE, MAX_LATENCY) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic request, \
    input logic acknowledge, \
    input logic sensitive_operation, \
    input logic stale_result, \
    input logic [LOCATIONS-1:0] visible, \
    input logic [LOCATIONS*DATA_WIDTH-1:0] storage \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    const logic [DATA_WIDTH-1:0] cleared_bits = CLEARED_VALUE; \
    bit active; \
    int age; \
    bit cleared; \
    function automatic bit is_cleared(); \
        bit result; \
        result = &visible; \
        for (int i = 0; i < LOCATIONS; i++) begin \
            if (storage[i*DATA_WIDTH+:DATA_WIDTH] !== cleared_bits) result = 0; \
        end \
        return result; \
    endfunction \
    always_comb cleared = is_cleared(); \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            active <= 0; \
            age <= 0; \
        end else if (request) begin \
            active <= 1; \
            age <= 0; \
        end else if (active && acknowledge) begin \
            active <= 0; \
            age <= 0; \
        end else if (active && age < MAX_LATENCY) age <= age + 1; \
    end \
    initial begin \
        a_cfg : \
        assert (LOCATIONS > 0 && DATA_WIDTH > 0 && MAX_LATENCY > 0 && MAX_LATENCY < 2147483647) \
        else $error("ZEROIZATION_CFG"); \
    end \
    a_events : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {request, acknowledge, sensitive_operation, stale_result, visible} \
    ) && (!request || (!active && !acknowledge)) && (!acknowledge || (active && cleared))) \
    else $error("ZEROIZATION_COMPLETION"); \
    a_block : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !stale_result && (!(active || request) || !sensitive_operation)) \
    else $error("ZEROIZATION_BLOCK"); \
    a_deadline : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !active || age < MAX_LATENCY) \
    else $error("ZEROIZATION_DEADLINE"); \
    final if (active) $error("ZEROIZATION_FINAL_DRAIN"); \
endchecker : NAME

`endif
