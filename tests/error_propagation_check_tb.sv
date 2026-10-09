`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "error_propagation_check.svh"
`SVA_DECLARE_ERROR_PROPAGATION_CHECK(test_checker, 4, 2, 1, 3)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int ID_WIDTH = 4;
    localparam int CODE_WIDTH = 2;
    localparam int ERROR_CODE = 1;
    localparam int MAX_LATENCY = 3;
    logic clk;
    logic reset_n;
    logic enable;
    logic error_trigger;
    logic [ID_WIDTH-1:0] error_id;
    logic terminal;
    logic [ID_WIDTH-1:0] terminal_id;
    logic [CODE_WIDTH-1:0] terminal_code;
    logic forbidden_effect;
    logic recover;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        error_trigger,
        error_id,
        terminal,
        terminal_id,
        terminal_code,
        forbidden_effect,
        recover
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        error_trigger = '0;
        error_id = '0;
        terminal = '0;
        terminal_id = '0;
        terminal_code = '0;
        forbidden_effect = '0;
        recover = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            error_trigger = 1;
            error_id = 1;
            tick();
            error_trigger = 0;
            terminal = 1;
            terminal_id = 1;
            terminal_code = 1;
            tick();
            terminal = 0;
            recover  = 1;
        end else begin
            error_trigger = 1;
            error_id = 1;
            tick();
            error_trigger = 0;
            terminal = 1;
            terminal_id = 1;
            terminal_code = 0;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
