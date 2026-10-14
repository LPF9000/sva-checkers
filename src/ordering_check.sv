// SPDX-License-Identifier: MIT
`include "ordering_check.svh"
module ordering_check #(
    parameter int ID_WIDTH = 4,
    parameter int DATA_WIDTH = 8,
    parameter int CAPACITY = 4,
    parameter int MAX_LATENCY = 8,
    parameter int IN_ORDER = 1,
    parameter int ALLOW_ID_REUSE = 0,
    parameter int CHECK_DATA = 0,
    parameter int REQUIRE_DRAIN = 1
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic accepted,
    input logic completed,
    input logic canceled,
    input logic drain,
    input logic [ID_WIDTH-1:0] request_id,
    input logic [ID_WIDTH-1:0] response_id,
    input logic [ID_WIDTH-1:0] cancel_id,
    input logic [DATA_WIDTH-1:0] expected_data,
    input logic [DATA_WIDTH-1:0] actual_data,
    input logic [DATA_WIDTH-1:0] valid_mask
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_ORDERING_CHECK(ordering_check_checker, ID_WIDTH, DATA_WIDTH, CAPACITY,
                                MAX_LATENCY, IN_ORDER, ALLOW_ID_REUSE, CHECK_DATA, REQUIRE_DRAIN)
    ordering_check_checker assertions (
        clk,
        reset_n,
        enable,
        accepted,
        completed,
        canceled,
        drain,
        request_id,
        response_id,
        cancel_id,
        expected_data,
        actual_data,
        valid_mask
    );
endmodule
