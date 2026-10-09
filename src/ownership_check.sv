// SPDX-License-Identifier: MIT
`include "ownership_check.svh"
module ownership_check #(
    parameter int USERS = 4
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic [USERS-1:0] grant,
    input logic [USERS-1:0] release_owner,
    input logic [USERS-1:0] access
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_OWNERSHIP_CHECK(ownership_check_checker, USERS)
    ownership_check_checker assertions (
        clk,
        reset_n,
        enable,
        grant,
        release_owner,
        access
    );
endmodule
