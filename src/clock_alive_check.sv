// SPDX-License-Identifier: MIT
`include "clock_alive_check.svh"
module clock_alive_check #(
    parameter realtime START_DEADLINE = 20ns,
    parameter realtime MAX_GAP = 20ns
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic signal_clock,
    input logic expected_running
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_CLOCK_ALIVE_CHECK(clock_alive_check_checker, START_DEADLINE, MAX_GAP)
    clock_alive_check_checker assertions (
        clk,
        reset_n,
        enable,
        signal_clock,
        expected_running
    );
endmodule
