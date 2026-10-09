// SPDX-License-Identifier: MIT
`include "configuration_check.svh"
module configuration_check #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] RESET_VALUE = 0,
    parameter int MAX_LATENCY = 3,
    parameter int REPLACE_PENDING = 0
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic update_accepted,
    input logic [WIDTH-1:0] update_value,
    input logic commit,
    input logic legal_boundary,
    input logic [WIDTH-1:0] active_value
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_CONFIGURATION_CHECK(configuration_check_checker, WIDTH, RESET_VALUE, MAX_LATENCY,
                                     REPLACE_PENDING)
    configuration_check_checker assertions (
        clk,
        reset_n,
        enable,
        update_accepted,
        update_value,
        commit,
        legal_boundary,
        active_value
    );
endmodule
