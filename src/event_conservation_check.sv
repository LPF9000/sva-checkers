// SPDX-License-Identifier: MIT
`include "event_conservation_check.svh"
module event_conservation_check #(
    parameter int CAPACITY = 4,
    parameter int MAX_BUSY_CYCLES = 8,
    parameter int ALLOW_BYPASS = 0,
    parameter int REQUIRE_DRAIN = 1
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic accepted,
    input logic completed,
    input logic canceled,
    input logic drain
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_EVENT_CONSERVATION_CHECK(event_conservation_check_checker, CAPACITY,
                                          MAX_BUSY_CYCLES, ALLOW_BYPASS, REQUIRE_DRAIN)
    event_conservation_check_checker assertions (
        clk,
        reset_n,
        enable,
        accepted,
        completed,
        canceled,
        drain
    );
endmodule
