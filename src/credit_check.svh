// SPDX-License-Identifier: MIT
`ifndef SVA_CREDIT_CHECK_SVH
`define SVA_CREDIT_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_CREDIT_CHECK(NAME, CAPACITY, INITIAL_CREDITS, SAME_CYCLE_RETURN, ALLOW_ZERO_LATENCY_RETURN) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input int unsigned consumed, \
    input int unsigned returned \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    longint signed credits; \
    longint signed next_credits; \
    always_comb next_credits = credits + longint'(returned) - longint'(consumed); \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) credits <= INITIAL_CREDITS; \
        else if (next_credits >= 0 && next_credits <= CAPACITY) credits <= next_credits; \
    end \
    initial begin \
        a_cfg : \
        assert (CAPACITY > 0 && INITIAL_CREDITS >= 0 && INITIAL_CREDITS <= CAPACITY) \
        else $error("CREDIT_CFG"); \
    end \
    a_known : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {consumed, returned} \
    )) \
    else $error("CREDIT_CONTROL"); \
    a_credit : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        next_credits >= 0 && next_credits <= CAPACITY && \
        longint'(consumed) <= credits + (SAME_CYCLE_RETURN ? longint'(returned) : 0) && \
        longint'(returned) <= CAPACITY - credits + (ALLOW_ZERO_LATENCY_RETURN ? longint'(consumed) : 0)) \
    else $error("CREDIT_ACCOUNTING"); \
endchecker : NAME

`endif
