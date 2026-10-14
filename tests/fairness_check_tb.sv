`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "fairness_check.svh"
`SVA_DECLARE_FAIRNESS_CHECK(test_checker, 4, 3, 0, 0)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int REQUESTERS = 4;
    localparam int MAX_WAIT = 3;
    localparam int COUNT_ELAPSED = 0;
    logic clk;
    logic reset_n;
    logic enable;
    logic [REQUESTERS-1:0] request;
    logic [REQUESTERS-1:0] eligible;
    logic [REQUESTERS-1:0] grant;
    logic opportunity;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        request,
        eligible,
        grant,
        opportunity
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
        eligible = '0;
        grant = '0;
        opportunity = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            request = 1;
            eligible = 1;
            opportunity = 1;
            tick();
            grant = 1;
            tick();
            request = 0;
            eligible = 0;
            grant = 0;
        end else if (testcase == "eligibility_grant" || testcase == "eligibility_deadline") begin
            request = 1;
            eligible = 1;
            opportunity = 1;
            repeat (2) tick();
            eligible = 0;
            repeat (3) tick();
            eligible = 1;
            if (testcase == "eligibility_grant") grant = 1;
            tick();
            request = 0;
            eligible = 0;
            grant = 0;
        end else begin
            request = 1;
            eligible = 1;
            opportunity = 1;
            repeat (3) tick();
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
