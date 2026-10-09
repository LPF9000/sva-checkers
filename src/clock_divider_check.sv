// SPDX-License-Identifier: MIT
`include "clock_divider_check.svh"
module clock_divider_check #(
    parameter int DIVISOR = 2,
    parameter int STARTUP_EDGES = 4
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic source_clock,
    input logic divided_clock
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_CLOCK_DIVIDER_CHECK(clock_divider_check_checker, DIVISOR, STARTUP_EDGES)
    clock_divider_check_checker assertions (
        clk,
        reset_n,
        enable,
        source_clock,
        divided_clock
    );
endmodule
