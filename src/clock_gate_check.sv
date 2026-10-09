// SPDX-License-Identifier: MIT
`include "clock_gate_check.svh"
module clock_gate_check #(
    parameter int PARK_LEVEL = 0,
    parameter int STOP_SAMPLES = 2,
    parameter int MIN_PULSE_SAMPLES = 2
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic source_clock,
    input logic gated_clock,
    input logic gate_enable
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_CLOCK_GATE_CHECK(clock_gate_check_checker, PARK_LEVEL, STOP_SAMPLES,
                                  MIN_PULSE_SAMPLES)
    clock_gate_check_checker assertions (
        clk,
        reset_n,
        enable,
        source_clock,
        gated_clock,
        gate_enable
    );
endmodule
