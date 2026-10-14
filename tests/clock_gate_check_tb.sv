`timescale 1ns / 1ps
// SPDX-License-Identifier: MIT
`include "clock_gate_check.svh"
`SVA_DECLARE_CLOCK_GATE_CHECK(test_checker, 0, 2, 2)
module checker_tb;
    timeunit 1ns; timeprecision 1ps;
    localparam int PARK_LEVEL = 0;
    localparam int STOP_SAMPLES = 2;
    localparam int MIN_PULSE_SAMPLES = 2;
    logic  clk;
    logic  reset_n;
    logic  enable;
    logic  source_clock;
    logic  gated_clock;
    logic  gate_enable;
    string testcase;
    test_checker dut (
        clk,
        reset_n,
        enable,
        source_clock,
        gated_clock,
        gate_enable
    );
    always #5 clk = ~clk;
    task automatic tick();
        @(negedge clk);
    endtask
    initial begin
        clk = '0;
        reset_n = '0;
        enable = '0;
        source_clock = '0;
        gated_clock = '0;
        gate_enable = '0;
        if (!$value$plusargs("CASE=%s", testcase)) testcase = "legal";
        repeat (2) tick();
        reset_n = 1;
        enable  = 1;
        if (testcase == "legal") begin
            source_clock = 0;
            gated_clock  = 0;
            gate_enable  = 1;
            repeat (2) tick();
            source_clock = 1;
            gated_clock  = 1;
            repeat (2) tick();
            source_clock = 0;
            gated_clock  = 0;
            gate_enable  = 0;
        end else if (testcase == "between_samples") begin
            gate_enable = 1;
            repeat (2) tick();
            #1 gated_clock = 1;
            #1 gated_clock = 0;
        end else if (testcase == "nba_edges") begin
            gate_enable = 1;
            repeat (2) tick();
            source_clock = 1;
            gated_clock <= 1;
            repeat (2) tick();
            source_clock = 0;
            gated_clock <= 0;
            repeat (2) tick();
            gate_enable = 0;
        end else begin
            source_clock = 1;
            gated_clock  = 1;
            repeat (2) tick();
            gated_clock = 0;
        end
        repeat (2) tick();
        $display("CHECKER_TEST_PASS");
        $finish;
    end
endmodule
