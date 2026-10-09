`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "zeroization_check.svh"
`SVA_DECLARE_ZEROIZATION_CHECK(test_checker, 4, 8, 0, 3)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int LOCATIONS = 4;
    localparam int DATA_WIDTH = 8;
    localparam longint unsigned CLEARED_VALUE = 0;
    localparam int MAX_LATENCY = 3;
    logic clk;
    logic reset_n;
    logic enable;
    logic request;
    logic acknowledge;
    logic sensitive_operation;
    logic stale_result;
    logic [LOCATIONS-1:0] visible;
    logic [LOCATIONS*DATA_WIDTH-1:0] storage;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        request,
        acknowledge,
        sensitive_operation,
        stale_result,
        visible,
        storage
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        request = '0;
        acknowledge = '0;
        sensitive_operation = '0;
        stale_result = '0;
        visible = '0;
        storage = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            request = 1;
            storage = '1;
            tick();
            request = 0;
            storage = 0;
            visible = '1;
            acknowledge = 1;
            tick();
            acknowledge = 0;
        end else begin
            request = 1;
            tick();
            request = 0;
            storage = '1;
            visible = '1;
            acknowledge = 1;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
