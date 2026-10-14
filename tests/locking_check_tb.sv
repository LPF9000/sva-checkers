`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "locking_check.svh"
`SVA_DECLARE_LOCKING_CHECK(test_checker, 8, 1)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int WIDTH = 8;
    localparam int LOCK_WINS = 1;
    logic clk;
    logic reset_n;
    logic enable;
    logic lock_accepted;
    logic permitted_unlock;
    logic clear_lock_reset;
    logic protected_write;
    logic [WIDTH-1:0] protected_value;
    logic lock_value;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        lock_accepted,
        permitted_unlock,
        clear_lock_reset,
        protected_write,
        protected_value,
        lock_value
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        lock_accepted = '0;
        permitted_unlock = '0;
        clear_lock_reset = '0;
        protected_write = '0;
        protected_value = '0;
        lock_value = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            protected_value = 8'h5a;
            lock_value = 0;
            lock_accepted = 1;
            tick();
            lock_accepted = 0;
            lock_value = 1;
            tick();
            permitted_unlock = 1;
            tick();
            permitted_unlock = 0;
            lock_value = 0;
        end else begin
            lock_accepted   = 1;
            protected_write = 1;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
