// SPDX-License-Identifier: MIT
`include "access_control_check.svh"
module access_control_check #(
    parameter int WIDTH = 8,
    parameter int MAX_LATENCY = 3,
    parameter logic [WIDTH-1:0] DENIED_READ_VALUE = 0
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic accepted,
    input logic authorized,
    input logic write,
    input logic response,
    input logic response_error,
    input logic [WIDTH-1:0] read_data,
    input logic [WIDTH-1:0] protected_value,
    input logic forbidden_effect,
    input logic protected_update_allowed
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_ACCESS_CONTROL_CHECK(access_control_check_checker, WIDTH, MAX_LATENCY,
                                      DENIED_READ_VALUE)
    access_control_check_checker assertions (
        clk,
        reset_n,
        enable,
        accepted,
        authorized,
        write,
        response,
        response_error,
        read_data,
        protected_value,
        forbidden_effect,
        protected_update_allowed
    );
endmodule
