// SPDX-License-Identifier: MIT
`include "reset_check.svh"
module reset_check #(
    parameter int WIDTH = 8,
    parameter int MIN_CYCLES = 2,
    parameter logic [WIDTH-1:0] RESET_VALUE = 0,
    parameter int RELEASE_ON_RISE = 1
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic observed_reset_n,
    input logic [WIDTH-1:0] value,
    input logic [WIDTH-1:0] valid_mask
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_RESET_CHECK(reset_check_checker, WIDTH, MIN_CYCLES, RESET_VALUE, RELEASE_ON_RISE)
    reset_check_checker assertions (
        clk,
        reset_n,
        enable,
        observed_reset_n,
        value,
        valid_mask
    );
endmodule
