`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "handshake_check.svh"
`SVA_DECLARE_HANDSHAKE_CHECK(test_checker, 4, 8, 1, 1)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int CAPACITY = 4;
    localparam int MAX_LATENCY = 8;
    localparam int ALLOW_BYPASS = 1;
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
            completed = 1;
            drain = 1;
            tick();
            accepted  = 0;
            completed = 0;
        end else begin
            completed = 1;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
