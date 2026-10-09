`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "known_check.svh"
`SVA_DECLARE_KNOWN_CHECK(test_checker, 8)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int WIDTH = 8;
    logic clk;
    logic reset_n;
    logic enable;
    logic [WIDTH-1:0] value;
    logic [WIDTH-1:0] valid_mask;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
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
        value = '0;
        valid_mask = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            value = 8'h5a;
            valid_mask = 8'hff;
        end else begin
            value = 'x;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
