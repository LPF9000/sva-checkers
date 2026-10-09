`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "access_control_check.svh"
`SVA_DECLARE_ACCESS_CONTROL_CHECK(test_checker, 8, 3, 0)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int WIDTH = 8;
    localparam int MAX_LATENCY = 3;
    localparam longint unsigned DENIED_READ_VALUE = 0;
    logic clk;
    logic reset_n;
    logic enable;
    logic accepted;
    logic authorized;
    logic write;
    logic response;
    logic response_error;
    logic [WIDTH-1:0] read_data;
    logic [WIDTH-1:0] protected_value;
    logic forbidden_effect;
    logic protected_update_allowed;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        accepted,
        authorized,
        write,
        response,
        response_error,
        read_data,
        protected_value,
        forbidden_effect,
        protected_update_allowed
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
        authorized = '0;
        write = '0;
        response = '0;
        response_error = '0;
        read_data = '0;
        protected_value = '0;
        forbidden_effect = '0;
        protected_update_allowed = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            protected_value = 8'h5a;
            accepted = 1;
            authorized = 0;
            write = 1;
            tick();
            accepted = 0;
            response = 1;
            response_error = 1;
            tick();
            response = 0;
        end else if (testcase == "delayed_effect") begin
            accepted = 1;
            authorized = 0;
            write = 1;
            protected_value = 8'h5a;
            tick();
            accepted = 0;
            response = 1;
            response_error = 1;
            tick();
            response = 0;
            protected_value = 8'h6a;
        end else if (testcase == "permitted_update") begin
            accepted = 1;
            authorized = 0;
            write = 1;
            protected_value = 8'h5a;
            tick();
            accepted = 0;
            response = 1;
            response_error = 1;
            tick();
            response = 0;
            protected_update_allowed = 1;
            protected_value = 8'h6a;
            tick();
            protected_update_allowed = 0;
        end else begin
            protected_value = 8'h5a;
            accepted = 1;
            authorized = 0;
            write = 1;
            tick();
            accepted = 0;
            protected_value = 8'h5b;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
