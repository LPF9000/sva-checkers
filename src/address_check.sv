// SPDX-License-Identifier: MIT
`include "address_check.svh"
module address_check #(
    parameter int ADDR_WIDTH = 32,
    parameter int SIZE_WIDTH = 8,
    parameter longint unsigned BASE_ADDR = 0,
    parameter longint unsigned LAST_ADDR = 4095,
    parameter int ALIGNMENT = 4
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic accepted,
    input logic write,
    input logic read_allowed,
    input logic write_allowed,
    input logic [ADDR_WIDTH-1:0] address,
    input logic [SIZE_WIDTH-1:0] bytes
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_ADDRESS_CHECK(address_check_checker, ADDR_WIDTH, SIZE_WIDTH, BASE_ADDR, LAST_ADDR,
                               ALIGNMENT)
    address_check_checker assertions (
        clk,
        reset_n,
        enable,
        accepted,
        write,
        read_allowed,
        write_allowed,
        address,
        bytes
    );
endmodule
