`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "counter_check.svh"
`SVA_DECLARE_COUNTER_CHECK(test_checker, 8, 0, 255, 1, 1, 1)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int WIDTH = 8;
    localparam longint unsigned MIN_VALUE = 0;
    localparam longint unsigned MAX_VALUE = 255;
    localparam int STEP = 1;
    localparam int SATURATE = 0;
    localparam int WRAP = 0;
    logic clk;
    logic reset_n;
    logic enable;
    logic increment;
    logic decrement;
    logic load;
    logic [WIDTH-1:0] load_value;
    logic [WIDTH-1:0] value;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        increment,
        decrement,
        load,
        load_value,
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
        increment = '0;
        decrement = '0;
        load = '0;
        load_value = '0;
        value = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            value = 0;
            increment = 0;
            decrement = 0;
            load = 0;
            load_value = 0;
            tick();
            increment = 1;
            tick();
            increment = 0;
            value = 1;
        end else begin
            tick();
            value = 3;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
