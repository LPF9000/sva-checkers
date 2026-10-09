// SPDX-License-Identifier: MIT
`include "length_check.svh"
module length_check #(
    parameter int MAX_LENGTH = 16,
    parameter int BOUNDARY_BYTES = 1024,
    parameter int ADDR_WIDTH = 32
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic start,
    input logic beat,
    input logic last,
    input logic cancel,
    input int unsigned command_length,
    input int unsigned valid_bytes,
    input logic [ADDR_WIDTH-1:0] address
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_LENGTH_CHECK(length_check_checker, MAX_LENGTH, BOUNDARY_BYTES, ADDR_WIDTH)
    length_check_checker assertions (
        clk,
        reset_n,
        enable,
        start,
        beat,
        last,
        cancel,
        command_length,
        valid_bytes,
        address
    );
endmodule
