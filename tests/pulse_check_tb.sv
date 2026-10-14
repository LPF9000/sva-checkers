`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "pulse_check.svh"
`SVA_DECLARE_PULSE_CHECK(test_checker, 1, 3, 2)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int MIN_CYCLES = 1;
    localparam int MAX_CYCLES = 3;
    localparam int MIN_GAP = 2;
    logic  clk;
    logic  reset_n;
    logic  enable;
    logic  pulse;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        pulse
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        pulse = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            pulse = 1;
            tick();
            pulse = 0;
            tick();
            tick();
            pulse = 1;
            tick();
            pulse = 0;
        end else begin
            pulse = 1;
            repeat (4) tick();
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
