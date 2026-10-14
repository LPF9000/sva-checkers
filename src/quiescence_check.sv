// SPDX-License-Identifier: MIT
`include "quiescence_check.svh"
module quiescence_check #(
    parameter int MAX_LATENCY = 3,
    parameter int ALLOW_NEW_DURING_DRAIN = 0
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic shutdown,
    input logic acknowledge,
    input logic wake,
    input logic new_work,
    input logic forbidden_activity,
    input int unsigned outstanding
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_QUIESCENCE_CHECK(quiescence_check_checker, MAX_LATENCY, ALLOW_NEW_DURING_DRAIN)
    quiescence_check_checker assertions (
        clk,
        reset_n,
        enable,
        shutdown,
        acknowledge,
        wake,
        new_work,
        forbidden_activity,
        outstanding
    );
endmodule
