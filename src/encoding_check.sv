// SPDX-License-Identifier: MIT
`include "encoding_check.svh"
module encoding_check #(
    parameter int WIDTH = 4,
    parameter int MODE = 0,
    parameter logic [15:0] LEGAL_VALUES = 16'hffff,
    parameter logic [255:0] TRANSITIONS = 256'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic [WIDTH-1:0] value
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_ENCODING_CHECK(encoding_check_checker, WIDTH, MODE, LEGAL_VALUES, TRANSITIONS)
    encoding_check_checker assertions (
        clk,
        reset_n,
        enable,
        value
    );
endmodule
