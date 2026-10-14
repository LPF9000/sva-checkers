// SPDX-License-Identifier: MIT
`timescale 1ns / 1ps
`include "interrupt_check.svh"
`SVA_DECLARE_INTERRUPT_CHECK(test_checker, 128, 128'h80000000000000000000000000000000, 1, 0, 2, 0)
module checker_tb;
    timeunit 1ns;
    timeprecision 1ps;
    localparam int WIDTH = 128;
    localparam logic [WIDTH-1:0] RESET_PENDING = 128'h80000000000000000000000000000000;
    localparam int SET_WINS = 1;
    localparam int MASK_CAPTURE = 0;
    localparam int MAX_LATENCY = 2;
    localparam int PULSE_MODE = 0;
    logic clk;
    logic reset_n;
    logic enable;
    logic [WIDTH-1:0] cause;
    logic [WIDTH-1:0] clear;
    logic [WIDTH-1:0] mask;
    logic [WIDTH-1:0] pending_value;
    logic global_enable;
    logic interrupt;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        cause,
        clear,
        mask,
        pending_value,
        global_enable,
        interrupt
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        cause = '0;
        clear = '0;
        mask = '0;
        pending_value = '0;
        global_enable = '0;
        interrupt = '0;
        if (!$value$plusargs("CASE=%s", testcase))
            testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        pending_value = RESET_PENDING;
        if (testcase == "legal") begin
            tick();
            clear = RESET_PENDING;
            tick();
            clear = '0;
            pending_value = '0;
        end else begin
            pending_value = '0;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
