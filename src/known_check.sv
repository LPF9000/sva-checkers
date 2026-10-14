// SPDX-License-Identifier: MIT
`include "known_check.svh"
module known_check #(
    parameter int WIDTH = 8
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic [WIDTH-1:0] value,
    input logic [WIDTH-1:0] valid_mask
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_KNOWN_CHECK(known_check_checker, WIDTH)
    known_check_checker assertions (
        clk,
        reset_n,
        enable,
        value,
        valid_mask
    );
endmodule
