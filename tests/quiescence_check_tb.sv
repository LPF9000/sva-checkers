`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "quiescence_check.svh"
`SVA_DECLARE_QUIESCENCE_CHECK(test_checker, 3, 0)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int MAX_LATENCY = 3;
    localparam int ALLOW_NEW_DURING_DRAIN = 0;
    logic clk;
    logic reset_n;
    logic enable;
    logic shutdown;
    logic acknowledge;
    logic wake;
    logic new_work;
    logic forbidden_activity;
    int unsigned outstanding;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        shutdown,
        acknowledge,
        wake,
        new_work,
        forbidden_activity,
        outstanding
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        shutdown = '0;
        acknowledge = '0;
        wake = '0;
        new_work = '0;
        forbidden_activity = '0;
        outstanding = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            shutdown = 1;
            outstanding = 1;
            tick();
            shutdown = 0;
            outstanding = 0;
            acknowledge = 1;
            tick();
            acknowledge = 0;
            tick();
            wake = 1;
            tick();
            wake = 0;
        end else begin
            acknowledge = 1;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
