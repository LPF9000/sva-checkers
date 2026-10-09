`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "configuration_check.svh"
`SVA_DECLARE_CONFIGURATION_CHECK(test_checker, 8, 0, 3, 0)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int WIDTH = 8;
    localparam longint unsigned RESET_VALUE = 0;
    localparam int MAX_LATENCY = 3;
    localparam int REPLACE_PENDING = 0;
    logic clk;
    logic reset_n;
    logic enable;
    logic update_accepted;
    logic [WIDTH-1:0] update_value;
    logic commit;
    logic legal_boundary;
    logic [WIDTH-1:0] active_value;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        update_accepted,
        update_value,
        commit,
        legal_boundary,
        active_value
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        update_accepted = '0;
        update_value = '0;
        commit = '0;
        legal_boundary = '0;
        active_value = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            active_value = 0;
            update_accepted = 1;
            update_value = 8'h12;
            tick();
            update_accepted = 0;
            commit = 1;
            legal_boundary = 1;
            tick();
            commit = 0;
            active_value = 8'h12;
        end else begin
            commit = 1;
            legal_boundary = 1;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
