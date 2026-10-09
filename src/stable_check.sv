// SPDX-License-Identifier: MIT
`include "stable_check.svh"
module stable_check #(
    parameter int WIDTH = 8
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic hold,
    input logic [WIDTH-1:0] value,
    input logic [WIDTH-1:0] valid_mask
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_STABLE_CHECK(stable_check_checker, WIDTH)
    stable_check_checker assertions (
        clk,
        reset_n,
        enable,
        hold,
        value,
        valid_mask
    );
endmodule
