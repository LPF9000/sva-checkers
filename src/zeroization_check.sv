// SPDX-License-Identifier: MIT
`include "zeroization_check.svh"
module zeroization_check #(
    parameter int LOCATIONS = 4,
    parameter int DATA_WIDTH = 8,
    parameter logic [DATA_WIDTH-1:0] CLEARED_VALUE = 0,
    parameter int MAX_LATENCY = 3
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic request,
    input logic acknowledge,
    input logic sensitive_operation,
    input logic stale_result,
    input logic [LOCATIONS-1:0] visible,
    input logic [LOCATIONS*DATA_WIDTH-1:0] storage
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_ZEROIZATION_CHECK(zeroization_check_checker, LOCATIONS, DATA_WIDTH, CLEARED_VALUE,
                                   MAX_LATENCY)
    zeroization_check_checker assertions (
        clk,
        reset_n,
        enable,
        request,
        acknowledge,
        sensitive_operation,
        stale_result,
        visible,
        storage
    );
endmodule
