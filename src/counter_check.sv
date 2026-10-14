// SPDX-License-Identifier: MIT
`include "counter_check.svh"
module counter_check #(
    parameter int WIDTH = 8,
    parameter longint unsigned MIN_VALUE = 0,
    parameter longint unsigned MAX_VALUE = 255,
    parameter int STEP = 1,
    parameter int SATURATE = 0,
    parameter int WRAP = 0
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic increment,
    input logic decrement,
    input logic load,
    input logic [WIDTH-1:0] load_value,
    input logic [WIDTH-1:0] value
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_COUNTER_CHECK(counter_check_checker, WIDTH, MIN_VALUE, MAX_VALUE, STEP, SATURATE,
                               WRAP)
    counter_check_checker assertions (
        clk,
        reset_n,
        enable,
        increment,
        decrement,
        load,
        load_value,
        value
    );
endmodule
