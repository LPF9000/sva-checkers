// SPDX-License-Identifier: MIT
`include "interrupt_check.svh"
module interrupt_check #(
    parameter int WIDTH = 4,
    parameter int RESET_PENDING = 0,
    parameter int SET_WINS = 1,
    parameter int MASK_CAPTURE = 0,
    parameter int MAX_LATENCY = 2,
    parameter int PULSE_MODE = 0
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic [WIDTH-1:0] cause,
    input logic [WIDTH-1:0] clear,
    input logic [WIDTH-1:0] mask,
    input logic [WIDTH-1:0] pending_value,
    input logic global_enable,
    input logic interrupt
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_INTERRUPT_CHECK(interrupt_check_checker, WIDTH, RESET_PENDING, SET_WINS,
                                 MASK_CAPTURE, MAX_LATENCY, PULSE_MODE)
    interrupt_check_checker assertions (
        clk,
        reset_n,
        enable,
        cause,
        clear,
        mask,
        pending_value,
        global_enable,
        interrupt
    );
endmodule
