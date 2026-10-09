`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "encoding_check.svh"
`SVA_DECLARE_ENCODING_CHECK(test_checker, 4, 0, 16'hffff,
                            256'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int WIDTH = 4;
    localparam int MODE = 0;
    localparam logic [15:0] LEGAL_VALUES = 16'hffff;
    localparam logic [255:0] TRANSITIONS = 256'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    logic clk;
    logic reset_n;
    logic enable;
    logic [WIDTH-1:0] value;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        value
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
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            value = 4'b0001;
            tick();
            value = 4'b0100;
        end else begin
            value = 4'b0011;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
