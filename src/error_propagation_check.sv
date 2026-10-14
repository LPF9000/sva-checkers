// SPDX-License-Identifier: MIT
`include "error_propagation_check.svh"
module error_propagation_check #(
    parameter int ID_WIDTH = 4,
    parameter int CODE_WIDTH = 2,
    parameter logic [CODE_WIDTH-1:0] ERROR_CODE = 1,
    parameter int MAX_LATENCY = 3
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic error_trigger,
    input logic [ID_WIDTH-1:0] error_id,
    input logic terminal,
    input logic [ID_WIDTH-1:0] terminal_id,
    input logic [CODE_WIDTH-1:0] terminal_code,
    input logic forbidden_effect,
    input logic recover
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_ERROR_PROPAGATION_CHECK(error_propagation_check_checker, ID_WIDTH, CODE_WIDTH,
                                         ERROR_CODE, MAX_LATENCY)
    error_propagation_check_checker assertions (
        clk,
        reset_n,
        enable,
        error_trigger,
        error_id,
        terminal,
        terminal_id,
        terminal_code,
        forbidden_effect,
        recover
    );
endmodule
