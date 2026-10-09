`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "fifo_check.svh"
`SVA_DECLARE_FIFO_CHECK(test_checker, 4, 0, 1)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int DEPTH = 4;
    localparam int ALLOW_EMPTY_BYPASS = 0;
    localparam int ALLOW_FULL_EXCHANGE = 1;
    logic clk;
    logic reset_n;
    logic enable;
    logic push;
    logic pop;
    logic empty;
    logic full;
    int unsigned occupancy;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        push,
        pop,
        empty,
        full,
        occupancy
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        push = '0;
        pop = '0;
        empty = '0;
        full = '0;
        occupancy = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            occupancy = 0;
            empty = 1;
            full = 0;
            push = 1;
            tick();
            push = 0;
            occupancy = 1;
            empty = 0;
            pop = 1;
            tick();
            pop = 0;
            occupancy = 0;
            empty = 1;
        end else begin
            empty = 1;
            pop   = 1;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
