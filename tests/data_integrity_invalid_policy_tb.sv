`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "data_integrity_check.svh"
`SVA_DECLARE_DATA_INTEGRITY_CHECK(test_checker, 4, 8, 4, 8, 1, 0, 0, 1)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int ID_WIDTH = 4;
    localparam int DATA_WIDTH = 8;
    localparam int CAPACITY = 4;
    localparam int MAX_LATENCY = 8;
    localparam int IN_ORDER = 1;
    localparam int ALLOW_ID_REUSE = 0;
    localparam int CHECK_DATA = 1;
    localparam int REQUIRE_DRAIN = 1;
    logic clk;
    logic reset_n;
    logic enable;
    logic accepted;
    logic completed;
    logic canceled;
    logic drain;
    logic [ID_WIDTH-1:0] request_id;
    logic [ID_WIDTH-1:0] response_id;
    logic [ID_WIDTH-1:0] cancel_id;
    logic [DATA_WIDTH-1:0] expected_data;
    logic [DATA_WIDTH-1:0] actual_data;
    logic [DATA_WIDTH-1:0] valid_mask;
    string testcase;
    test_checker dut (
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
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        accepted = '0;
        completed = '0;
        canceled = '0;
        drain = '0;
        request_id = '0;
        response_id = '0;
        cancel_id = '0;
        expected_data = '0;
        actual_data = '0;
        valid_mask = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            accepted = 1;
            request_id = 1;
            expected_data = 8'h5a;
            valid_mask = '1;
            tick();
            accepted = 0;
            completed = 1;
            response_id = 1;
            actual_data = 8'h5a;
            tick();
            completed = 0;
            drain = 1;
        end else if (testcase == "duplicate") begin
            accepted   = 1;
            request_id = 1;
            tick();
        end else if (testcase == "capacity") begin
            accepted = 1;
            for (int id = 0; id < 5; id++) begin
                request_id = $unsigned(4'(id));
                tick();
            end
        end else if (testcase == "deadline") begin
            accepted   = 1;
            request_id = 1;
            tick();
            accepted = 0;
            repeat (9) tick();
        end else if (testcase == "reset_pending") begin
            accepted   = 1;
            request_id = 1;
            tick();
            accepted = 0;
            reset_n  = 0;
            tick();
            reset_n = 1;
            repeat (9) tick();
            drain = 1;
        end else if (testcase == "disable_pending") begin
            accepted   = 1;
            request_id = 1;
            tick();
            accepted = 0;
            enable   = 0;
            tick();
            enable = 1;
            repeat (9) tick();
            drain = 1;
        end else if (testcase == "same_id_reuse") begin
            accepted   = 1;
            request_id = 1;
            tick();
            completed   = 1;
            response_id = 1;
            tick();
            accepted = 0;
            tick();
            completed = 0;
            drain = 1;
        end else if (testcase == "cancel_then_complete") begin
            accepted   = 1;
            request_id = 1;
            tick();
            request_id = 2;
            tick();
            accepted = 0;
            canceled = 1;
            cancel_id = 2;
            completed = 1;
            response_id = 1;
            tick();
            canceled = 0;
            completed = 0;
            drain = 1;
        end else if (testcase == "latency_boundary") begin
            accepted   = 1;
            request_id = 1;
            tick();
            accepted = 0;
            repeat (7) tick();
            completed   = 1;
            response_id = 1;
            tick();
            completed = 0;
            drain = 1;
        end else begin
            accepted = 1;
            request_id = 1;
            expected_data = 8'h5a;
            valid_mask = '1;
            tick();
            accepted = 0;
            completed = 1;
            response_id = 1;
            actual_data = 8'h5b;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
