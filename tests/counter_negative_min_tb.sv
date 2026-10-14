// SPDX-License-Identifier: MIT
`timescale 1ns / 1ps
`include "counter_check.svh"
`SVA_DECLARE_COUNTER_CHECK(test_checker, 8, -1, 255, 1, 0, 0)
module checker_tb;
    timeunit 1ns;
    timeprecision 1ps;
    // Invalid policies must fail even with no clock and checking disabled.
    logic clk = 1'b0;
    logic [7:0] load_value = '0;
    logic [7:0] value = '0;
    test_checker dut (clk, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, load_value, value);
    initial begin
        #1;
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
