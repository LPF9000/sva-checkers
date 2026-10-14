`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "register_check.svh"
`SVA_DECLARE_REGISTER_CHECK(test_checker, 8, 0, 8'h0f, 8'hf0, 0, 0, 1, 1)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int WIDTH = 8;
    localparam longint unsigned RESET_VALUE = 0;
    localparam logic [WIDTH-1:0] RW_MASK = 8'h0f;
    localparam logic [WIDTH-1:0] W1C_MASK = 8'hf0;
    localparam logic [WIDTH-1:0] W1S_MASK = 0;
    localparam logic [WIDTH-1:0] READ_CLEAR_MASK = 0;
    localparam int SET_WINS = 1;
    localparam int HW_AFTER_SW = 1;
    logic clk;
    logic reset_n;
    logic enable;
    logic write_accepted;
    logic read_accepted;
    logic [WIDTH-1:0] write_data;
    logic [WIDTH-1:0] write_mask;
    logic [WIDTH-1:0] read_data;
    logic [WIDTH-1:0] hardware_set;
    logic [WIDTH-1:0] hardware_clear;
    logic [WIDTH-1:0] value;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        write_accepted,
        read_accepted,
        write_data,
        write_mask,
        read_data,
        hardware_set,
        hardware_clear,
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
        write_accepted = '0;
        read_accepted = '0;
        write_data = '0;
        write_mask = '0;
        read_data = '0;
        hardware_set = '0;
        hardware_clear = '0;
        value = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            value = 0;
            hardware_set = 8'h80;
            tick();
            hardware_set = 0;
            value = 8'h80;
            write_accepted = 1;
            write_data = 8'h80;
            write_mask = '1;
            tick();
            write_accepted = 0;
            value = 0;
            read_accepted = 1;
            read_data = 0;
        end else begin
            value = 1;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
