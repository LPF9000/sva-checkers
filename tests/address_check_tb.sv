`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "address_check.svh"
`SVA_DECLARE_ADDRESS_CHECK(test_checker, 32, 8, 0, 4095, 4)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int ADDR_WIDTH = 32;
    localparam int SIZE_WIDTH = 8;
    localparam longint unsigned BASE_ADDR = 0;
    localparam longint unsigned LAST_ADDR = 4095;
    localparam int ALIGNMENT = 4;
    logic clk;
    logic reset_n;
    logic enable;
    logic accepted;
    logic write;
    logic read_allowed;
    logic write_allowed;
    logic [ADDR_WIDTH-1:0] address;
    logic [SIZE_WIDTH-1:0] bytes;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        accepted,
        write,
        read_allowed,
        write_allowed,
        address,
        bytes
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        accepted = '0;
        write = '0;
        read_allowed = '0;
        write_allowed = '0;
        address = '0;
        bytes = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            accepted = 1;
            address = 16;
            bytes = 4;
            read_allowed = 1;
            write_allowed = 1;
            write = 0;
        end else if (testcase == "last_byte") begin
            accepted = 1;
            address = 4092;
            bytes = 4;
            read_allowed = 1;
        end else if (testcase == "overflow") begin
            accepted = 1;
            address = 32'hfffffffc;
            bytes = 8;
            read_allowed = 1;
        end else if (testcase == "unaligned") begin
            accepted = 1;
            address = 3;
            bytes = 4;
            read_allowed = 1;
        end else if (testcase == "denied") begin
            accepted = 1;
            address = 16;
            bytes = 4;
            read_allowed = 0;
        end else if (testcase == "unaccepted") begin
            accepted = 0;
            address = 32'hffffffff;
            bytes = 0;
            read_allowed = 0;
        end else begin
            accepted = 1;
            read_allowed = 1;
            write_allowed = 1;
            address = 4092;
            bytes = 8;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
