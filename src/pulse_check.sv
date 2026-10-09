// SPDX-License-Identifier: MIT
`include "pulse_check.svh"
module pulse_check #(
    parameter int MIN_CYCLES = 1,
    parameter int MAX_CYCLES = 3,
    parameter int MIN_GAP = 2
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic pulse
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_PULSE_CHECK(pulse_check_checker, MIN_CYCLES, MAX_CYCLES, MIN_GAP)
    pulse_check_checker assertions (
        clk,
        reset_n,
        enable,
        pulse
    );
endmodule
