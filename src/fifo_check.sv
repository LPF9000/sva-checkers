// SPDX-License-Identifier: MIT
`include "fifo_check.svh"
module fifo_check #(
    parameter int DEPTH = 4,
    parameter int ALLOW_EMPTY_BYPASS = 0,
    parameter int ALLOW_FULL_EXCHANGE = 1
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic push,
    input logic pop,
    input logic empty,
    input logic full,
    input int unsigned occupancy
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_FIFO_CHECK(fifo_check_checker, DEPTH, ALLOW_EMPTY_BYPASS, ALLOW_FULL_EXCHANGE)
    fifo_check_checker assertions (
        clk,
        reset_n,
        enable,
        push,
        pop,
        empty,
        full,
        occupancy
    );
endmodule
