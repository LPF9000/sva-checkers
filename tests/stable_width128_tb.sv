`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "stable_check.svh"
`SVA_DECLARE_STABLE_CHECK(test_checker, 128)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int WIDTH = 128;
    logic clk;
    logic reset_n;
    logic enable;
    logic hold;
    logic [WIDTH-1:0] value;
    logic [WIDTH-1:0] valid_mask;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        hold,
        value,
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
        hold = '0;
        value = '0;
        valid_mask = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            hold = 1;
            valid_mask = 128'h80000000000000000000000000000000;
            value = valid_mask;
            tick();
            value ^= 128'd1;
            tick();
            hold = 0;
        end else begin
            hold = 1;
            valid_mask = 128'h80000000000000000000000000000000;
            value = valid_mask;
            tick();
            value = '0;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
