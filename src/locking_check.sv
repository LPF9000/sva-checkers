// SPDX-License-Identifier: MIT
`include "locking_check.svh"
module locking_check #(
    parameter int WIDTH = 8,
    parameter int LOCK_WINS = 1
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic lock_accepted,
    input logic permitted_unlock,
    input logic clear_lock_reset,
    input logic protected_write,
    input logic [WIDTH-1:0] protected_value,
    input logic lock_value
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_LOCKING_CHECK(locking_check_checker, WIDTH, LOCK_WINS)
    locking_check_checker assertions (
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
endmodule
