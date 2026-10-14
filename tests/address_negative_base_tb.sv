// SPDX-License-Identifier: MIT
`timescale 1ns / 1ps
`include "address_check.svh"
`SVA_DECLARE_ADDRESS_CHECK(test_checker, 8, 4, -1, 255, 1)
module checker_tb;
    timeunit 1ns;
    timeprecision 1ps;
    // Invalid policies must fail even with no clock and checking disabled.
    logic clk = 1'b0;
    logic [7:0] address = '0;
    logic [3:0] bytes = '0;
    test_checker dut (clk, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, address, bytes);
    initial begin
        #1;
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
