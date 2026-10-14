// SPDX-License-Identifier: MIT
`include "clock_timing_check.svh"
module clock_timing_check #(
    parameter realtime MIN_PERIOD = 8ns,
    parameter realtime MAX_PERIOD = 12ns,
    parameter realtime MIN_HIGH = 2ns,
    parameter realtime MAX_HIGH = 8ns,
    parameter realtime MIN_LOW = 2ns,
    parameter realtime MAX_LOW = 8ns,
    parameter real MIN_DUTY = 25.0,
    parameter real MAX_DUTY = 75.0
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic signal_clock
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_CLOCK_TIMING_CHECK(clock_timing_check_checker, MIN_PERIOD, MAX_PERIOD, MIN_HIGH,
                                    MAX_HIGH, MIN_LOW, MAX_LOW, MIN_DUTY, MAX_DUTY)
    clock_timing_check_checker assertions (
        clk,
        reset_n,
        enable,
        signal_clock
    );
endmodule
