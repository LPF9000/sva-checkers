`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "clock_timing_check.svh"
`SVA_DECLARE_CLOCK_TIMING_CHECK(test_checker, 8ns, 12ns, 2ns, 8ns, 2ns, 8ns, 25.0, 75.0)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam realtime MIN_PERIOD = 8ns;
    localparam realtime MAX_PERIOD = 12ns;
    localparam realtime MIN_HIGH = 2ns;
    localparam realtime MAX_HIGH = 8ns;
    localparam realtime MIN_LOW = 2ns;
    localparam realtime MAX_LOW = 8ns;
    localparam real MIN_DUTY = 25.0;
    localparam real MAX_DUTY = 75.0;
    logic  clk;
    logic  reset_n;
    logic  enable;
    logic  signal_clock;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        signal_clock
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
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            signal_clock = 0;
            #2;
            signal_clock = 1;
            #5;
            signal_clock = 0;
            #5;
            signal_clock = 1;
            #5;
            signal_clock = 0;
        end else begin
            signal_clock = 0;
            #2;
            signal_clock = 1;
            #1;
            signal_clock = 0;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
