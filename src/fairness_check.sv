// SPDX-License-Identifier: MIT
`include "fairness_check.svh"
module fairness_check #(
    parameter int REQUESTERS = 4,
    parameter int MAX_WAIT = 3,
    parameter bit CLEAR_ON_INELIGIBLE = 0,
    parameter int COUNT_ELAPSED = 0
) (
    input logic clk,
    input logic reset_n,
    input logic enable,
    input logic [REQUESTERS-1:0] request,
    input logic [REQUESTERS-1:0] eligible,
    input logic [REQUESTERS-1:0] grant,
    input logic opportunity
);
    timeunit 1ns; timeprecision 1ps;
    `SVA_DECLARE_FAIRNESS_CHECK(fairness_check_checker, REQUESTERS, MAX_WAIT, COUNT_ELAPSED, CLEAR_ON_INELIGIBLE)
    fairness_check_checker assertions (
        clk,
        reset_n,
        enable,
        request,
        eligible,
        grant,
        opportunity
    );
endmodule
