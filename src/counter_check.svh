// SPDX-License-Identifier: MIT
`ifndef SVA_COUNTER_CHECK_SVH
`define SVA_COUNTER_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_COUNTER_CHECK(NAME, WIDTH, MIN_VALUE, MAX_VALUE, STEP, SATURATE, WRAP) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic increment, \
    input logic decrement, \
    input logic load, \
    input logic [WIDTH-1:0] load_value, \
    input logic [WIDTH-1:0] value \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    typedef logic [63:0] arithmetic_t; \
    typedef logic signed [64:0] bounds_t; \
    function automatic bit in_bounds(input bounds_t candidate); \
        return candidate >= bounds_t'(MIN_VALUE) && candidate <= bounds_t'(MAX_VALUE); \
    endfunction \
    arithmetic_t next_value; \
    arithmetic_t expected_value; \
    bit sampled; \
    always_comb begin \
        next_value = arithmetic_t'(value); \
        if (load) next_value = arithmetic_t'(load_value); \
        else if (increment) begin \
            if (arithmetic_t'(value) + arithmetic_t'(STEP) > arithmetic_t'(MAX_VALUE)) \
                next_value = SATURATE ? arithmetic_t'(MAX_VALUE) : \
                    (WRAP ? arithmetic_t'(MIN_VALUE) + arithmetic_t'(value) + \
                        arithmetic_t'(STEP) - arithmetic_t'(MAX_VALUE) - 64'd1 : '0); \
            else next_value = arithmetic_t'(value) + arithmetic_t'(STEP); \
        end else if (decrement) begin \
            if (bounds_t'(value) < bounds_t'(MIN_VALUE) + bounds_t'(STEP)) \
                next_value = SATURATE ? arithmetic_t'(MIN_VALUE) : \
                    (WRAP ? arithmetic_t'(MAX_VALUE) - (arithmetic_t'(MIN_VALUE) + \
                        arithmetic_t'(STEP) - arithmetic_t'(value) - 64'd1) : '0); \
            else next_value = arithmetic_t'(value) - arithmetic_t'(STEP); \
        end \
    end \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            sampled <= 0; \
            expected_value <= '0; \
        end else begin \
            sampled <= 1; \
            expected_value <= next_value; \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (WIDTH > 0 && WIDTH <= 32 && \
        arithmetic_t'(MIN_VALUE) <= arithmetic_t'(MAX_VALUE) && \
        arithmetic_t'(MAX_VALUE) < (64'd1 << WIDTH) && STEP > 0 && \
        arithmetic_t'(STEP) <= arithmetic_t'(MAX_VALUE) - arithmetic_t'(MIN_VALUE) + 64'd1 && \
        !(SATURATE && WRAP)) \
        else $error("COUNTER_CFG"); \
    end \
    a_control : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {increment, decrement, load, value} \
    ) && !(increment && decrement) && (!load || !$isunknown( \
        load_value \
    ))) \
    else $error("COUNTER_CONTROL"); \
    a_bounds : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) in_bounds( \
        bounds_t'(value) \
    ) && (!load || in_bounds( \
        bounds_t'(load_value) \
    )) && (SATURATE || WRAP || \
           ((!increment || load || arithmetic_t'(value) + arithmetic_t'(STEP) <= \
             arithmetic_t'(MAX_VALUE)) && (!decrement || load || bounds_t'(value) >= \
                                           bounds_t'(MIN_VALUE) + bounds_t'(STEP))))) \
    else $error("COUNTER_BOUNDS"); \
    a_update : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !sampled || arithmetic_t'(value) == expected_value) \
    else $error("COUNTER_UPDATE"); \
endchecker : NAME

`endif
