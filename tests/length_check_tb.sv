`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "length_check.svh"
`SVA_DECLARE_LENGTH_CHECK(test_checker, 16, 1024, 32)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int MAX_LENGTH = 16;
    localparam int BOUNDARY_BYTES = 1024;
    localparam int ADDR_WIDTH = 32;
    logic clk;
    logic reset_n;
    logic enable;
    logic start;
    logic beat;
    logic last;
    logic cancel;
    int unsigned command_length;
    int unsigned valid_bytes;
    logic [ADDR_WIDTH-1:0] address;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        start,
        beat,
        last,
        cancel,
        command_length,
        valid_bytes,
        address
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        start = '0;
        beat = '0;
        last = '0;
        cancel = '0;
        command_length = '0;
        valid_bytes = '0;
        address = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            start = 1;
            command_length = 4;
            address = 16;
            tick();
            start = 0;
            beat = 1;
            valid_bytes = 4;
            last = 1;
            tick();
            beat = 0;
            last = 0;
        end else if (testcase == "boundary") begin
            start = 1;
            command_length = 8;
            address = 1020;
            tick();
            start = 0;
            beat = 1;
            valid_bytes = 8;
            last = 1;
        end else if (testcase == "overflow") begin
            start = 1;
            command_length = 8;
            address = 32'hfffffffc;
            tick();
            start = 0;
            beat = 1;
            valid_bytes = 8;
            last = 1;
        end else if (testcase == "exact_boundary") begin
            start = 1;
            command_length = 4;
            address = 1020;
            tick();
            start = 0;
            beat = 1;
            valid_bytes = 4;
            last = 1;
            tick();
            beat = 0;
            last = 0;
        end else if (testcase == "partial_beats") begin
            start = 1;
            command_length = 6;
            address = 16;
            tick();
            start = 0;
            beat = 1;
            valid_bytes = 4;
            tick();
            address = 20;
            valid_bytes = 2;
            last = 1;
            tick();
            beat = 0;
            last = 0;
        end else if (testcase == "cancel_pending") begin
            start = 1;
            command_length = 8;
            address = 16;
            tick();
            start  = 0;
            cancel = 1;
            tick();
            cancel = 0;
        end else begin
            start = 1;
            command_length = 4;
            address = 16;
            tick();
            start = 0;
            beat = 1;
            valid_bytes = 2;
            last = 1;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
