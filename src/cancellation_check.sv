// SPDX-License-Identifier: MIT
`include "cancellation_check.svh"
module cancellation_check #(
    parameter int ID_WIDTH = 4,
    parameter int GEN_WIDTH = 4,
    parameter int CAPACITY = 4,
    parameter int MAX_LATENCY = 3,
    parameter int REQUIRE_CANCEL_RESPONSE = 0,
    parameter int REQUIRE_DRAIN = 1
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic accepted,
    input logic [ID_WIDTH-1:0] request_id,
    input logic [GEN_WIDTH-1:0] generation,
    input logic commit,
    input logic [ID_WIDTH-1:0] commit_id,
    input logic flush,
    input logic cancel,
    input logic [ID_WIDTH-1:0] cancel_id,
    input logic response,
    input logic [ID_WIDTH-1:0] response_id,
    input logic [GEN_WIDTH-1:0] response_generation,
    input logic response_canceled,
    input logic flush_ack
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_CANCELLATION_CHECK(cancellation_check_checker, ID_WIDTH, GEN_WIDTH, CAPACITY,
                                    MAX_LATENCY, REQUIRE_CANCEL_RESPONSE, REQUIRE_DRAIN)
    cancellation_check_checker assertions (
        clk,
        reset_n,
        enable,
        accepted,
        request_id,
        generation,
        commit,
        commit_id,
        flush,
        cancel,
        cancel_id,
        response,
        response_id,
        response_generation,
        response_canceled,
        flush_ack
    );
endmodule
