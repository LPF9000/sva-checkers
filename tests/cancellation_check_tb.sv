`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "cancellation_check.svh"
`SVA_DECLARE_CANCELLATION_CHECK(test_checker, 4, 4, 4, 3, 0, 1)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int ID_WIDTH = 4;
    localparam int GEN_WIDTH = 4;
    localparam int CAPACITY = 4;
    localparam int MAX_LATENCY = 3;
    localparam int REQUIRE_CANCEL_RESPONSE = 0;
    localparam int REQUIRE_DRAIN = 1;
    logic clk;
    logic reset_n;
    logic enable;
    logic accepted;
    logic [ID_WIDTH-1:0] request_id;
    logic [GEN_WIDTH-1:0] generation;
    logic commit;
    logic [ID_WIDTH-1:0] commit_id;
    logic flush;
    logic cancel;
    logic [ID_WIDTH-1:0] cancel_id;
    logic response;
    logic [ID_WIDTH-1:0] response_id;
    logic [GEN_WIDTH-1:0] response_generation;
    logic response_canceled;
    logic flush_ack;
    string testcase;
    test_checker dut (
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
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        accepted = '0;
        request_id = '0;
        generation = '0;
        commit = '0;
        commit_id = '0;
        flush = '0;
        cancel = '0;
        cancel_id = '0;
        response = '0;
        response_id = '0;
        response_generation = '0;
        response_canceled = '0;
        flush_ack = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            accepted   = 1;
            request_id = 1;
            generation = 0;
            tick();
            accepted = 0;
            flush = 1;
            tick();
            flush = 0;
            generation = 1;
            flush_ack = 1;
            tick();
            flush_ack = 0;
        end else begin
            accepted   = 1;
            request_id = 1;
            generation = 0;
            tick();
            accepted = 0;
            flush = 1;
            tick();
            flush = 0;
            generation = 1;
            response = 1;
            response_id = 1;
            response_generation = 0;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
