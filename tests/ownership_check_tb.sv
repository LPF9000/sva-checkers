`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "ownership_check.svh"
`SVA_DECLARE_OWNERSHIP_CHECK(test_checker, 4)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int USERS = 4;
    logic clk;
    logic reset_n;
    logic enable;
    logic [USERS-1:0] grant;
    logic [USERS-1:0] release_owner;
    logic [USERS-1:0] access;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        grant,
        release_owner,
        access
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        grant = '0;
        release_owner = '0;
        access = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            grant = 1;
            tick();
            grant  = 0;
            access = 1;
            tick();
            access = 0;
            release_owner = 1;
            tick();
            release_owner = 0;
        end else begin
            access = 1;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
