// SPDX-License-Identifier: MIT
`include "credit_check.svh"
module credit_check #(
    parameter int CAPACITY = 4,
    parameter int INITIAL_CREDITS = 4,
    parameter int SAME_CYCLE_RETURN = 0,
    parameter int ALLOW_ZERO_LATENCY_RETURN = 0
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input int unsigned consumed,
    input int unsigned returned
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_CREDIT_CHECK(credit_check_checker, CAPACITY, INITIAL_CREDITS, SAME_CYCLE_RETURN, ALLOW_ZERO_LATENCY_RETURN)
    credit_check_checker assertions (
        clk,
        reset_n,
        enable,
        consumed,
        returned
    );
endmodule
