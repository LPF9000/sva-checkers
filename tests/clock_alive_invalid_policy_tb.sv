`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "clock_alive_check.svh"
`SVA_DECLARE_CLOCK_ALIVE_CHECK(test_checker, 20, 0)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam realtime START_DEADLINE = 20ns;
    localparam realtime MAX_GAP = 20ns;
    logic  clk;
    logic  reset_n;
    logic  enable;
    logic  signal_clock;
    logic  expected_running;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        signal_clock,
        expected_running
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        signal_clock = '0;
        expected_running = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            expected_running = 1;
            signal_clock = 0;
            repeat (5) begin
                #5;
                signal_clock = ~signal_clock;
            end
        end else begin
            expected_running = 1;
            signal_clock = 0;
            repeat (5) tick();
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
