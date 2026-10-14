`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "clock_divider_check.svh"
`SVA_DECLARE_CLOCK_DIVIDER_CHECK(test_checker, 2, 4)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int DIVISOR = 2;
    localparam int STARTUP_EDGES = 4;
    logic  clk;
    logic  reset_n;
    logic  enable;
    logic  source_clock;
    logic  divided_clock;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        source_clock,
        divided_clock
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        source_clock = '0;
        divided_clock = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            source_clock  = 1;
            divided_clock = 1;
            tick();
            source_clock  = 0;
            divided_clock = 0;
            tick();
            source_clock = 1;
            tick();
            source_clock = 0;
            tick();
            source_clock  = 1;
            divided_clock = 1;
            tick();
            source_clock  = 0;
            divided_clock = 0;
        end else begin
            source_clock  = 0;
            divided_clock = 0;
            tick();
            divided_clock = 1;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
