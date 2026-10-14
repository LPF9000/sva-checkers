`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "credit_check.svh"
`SVA_DECLARE_CREDIT_CHECK(test_checker, 4, 4, 0, 0)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int CAPACITY = 4;
    localparam int INITIAL_CREDITS = 4;
    localparam int SAME_CYCLE_RETURN = 0;
    logic clk;
    logic reset_n;
    logic enable;
    int unsigned consumed;
    int unsigned returned;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        consumed,
        returned
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        consumed = '0;
        returned = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            consumed = 1;
            returned = 0;
            tick();
            consumed = 0;
            returned = 1;
            tick();
            returned = 0;
        end else begin
            consumed = 5;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
