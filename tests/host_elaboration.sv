// SPDX-License-Identifier: MIT
module host_elaboration (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic hold,
    input logic [127:0] value,
    input logic [127:0] valid_mask,
    input logic push,
    input logic pop,
    input logic empty,
    input logic full,
    input int unsigned occupancy
);
    timeunit 1ns;
    timeprecision 1ps;
    known_check #(.WIDTH(128)) known_wide (.*);
    stable_check #(.WIDTH(128)) stable_wide (.*);
    interrupt_check #(
        .WIDTH(128),
        .RESET_PENDING(128'h80000000000000000000000000000000)
    ) interrupt_wide (
        .clk(clk), .reset_n(reset_n), .enable(enable),
        .cause(value), .clear(value), .mask(valid_mask), .pending_value(value),
        .global_enable(enable), .interrupt(hold)
    );
    fifo_check #(.DEPTH(17), .ALLOW_EMPTY_BYPASS(1)) fifo_large (.*);
endmodule
