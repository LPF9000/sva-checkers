// SPDX-License-Identifier: MIT
`include "register_check.svh"
module register_check #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] RESET_VALUE = 0,
    parameter logic [WIDTH-1:0] RW_MASK = 8'h0f,
    parameter logic [WIDTH-1:0] W1C_MASK = 8'hf0,
    parameter logic [WIDTH-1:0] W1S_MASK = 0,
    parameter logic [WIDTH-1:0] READ_CLEAR_MASK = 0,
    parameter int SET_WINS = 1,
    parameter int HW_AFTER_SW = 1
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic write_accepted,
    input logic read_accepted,
    input logic [WIDTH-1:0] write_data,
    input logic [WIDTH-1:0] write_mask,
    input logic [WIDTH-1:0] read_data,
    input logic [WIDTH-1:0] hardware_set,
    input logic [WIDTH-1:0] hardware_clear,
    input logic [WIDTH-1:0] value
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_REGISTER_CHECK(register_check_checker, WIDTH, RESET_VALUE, RW_MASK, W1C_MASK,
                                W1S_MASK, READ_CLEAR_MASK, SET_WINS, HW_AFTER_SW)
    register_check_checker assertions (
        clk,
        reset_n,
        enable,
        write_accepted,
        read_accepted,
        write_data,
        write_mask,
        read_data,
        hardware_set,
        hardware_clear,
        value
    );
endmodule
