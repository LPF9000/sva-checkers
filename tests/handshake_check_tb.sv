`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "handshake_check.svh"
`SVA_DECLARE_HANDSHAKE_CHECK(test_checker, 4, 8, 0, 1)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int CAPACITY = 4;
    localparam int MAX_LATENCY = 8;
    localparam int ALLOW_BYPASS = 0;
    localparam int REQUIRE_DRAIN = 1;
    logic  clk;
    logic  reset_n;
    logic  enable;
    logic  accepted;
    logic  completed;
    logic  canceled;
    logic  drain;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        accepted,
        completed,
        canceled,
        drain
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
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            accepted = 1;
            tick();
            accepted  = 0;
            completed = 1;
            tick();
            completed = 0;
            drain = 1;
        end else if (testcase == "capacity") begin
            accepted = 1;
            repeat (5) tick();
        end else if (testcase == "deadline") begin
            accepted = 1;
            tick();
            accepted = 0;
            repeat (9) tick();
        end else if (testcase == "latency_boundary") begin
            accepted = 1;
            tick();
            accepted = 0;
            repeat (7) tick();
            completed = 1;
            tick();
            completed = 0;
            drain = 1;
        end else if (testcase == "reset_pending") begin
            accepted = 1;
            tick();
            accepted = 0;
            reset_n  = 0;
            tick();
            reset_n = 1;
            repeat (9) tick();
            drain = 1;
        end else if (testcase == "disable_pending") begin
            accepted = 1;
            tick();
            accepted = 0;
            enable   = 0;
            tick();
            enable = 1;
            repeat (9) tick();
            drain = 1;
        end else if (testcase == "full_exchange") begin
            accepted = 1;
            repeat (4) tick();
            completed = 1;
            tick();
            accepted = 0;
            repeat (4) tick();
            completed = 0;
            drain = 1;
        end else begin
            completed = 1;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
