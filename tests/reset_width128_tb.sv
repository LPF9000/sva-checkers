`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "reset_check.svh"
`SVA_DECLARE_RESET_CHECK(test_checker, 128, 2, 128'h80000000000000000000000000000000, 1)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int WIDTH = 128;
    localparam int MIN_CYCLES = 2;
    localparam longint unsigned RESET_VALUE = 0;
    localparam int RELEASE_ON_RISE = 1;
    logic clk;
    logic reset_n;
    logic enable;
    logic observed_reset_n;
    logic [WIDTH-1:0] value;
    logic [WIDTH-1:0] valid_mask;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        observed_reset_n,
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
        observed_reset_n = '0;
        value = '0;
        valid_mask = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            observed_reset_n = 0;
            valid_mask = '1;
            value = 128'h80000000000000000000000000000000;
            repeat (2) tick();
            @(posedge clk);
            observed_reset_n <= 1;
        end else begin
            observed_reset_n = 0;
            valid_mask = '1;
            value = '0;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
