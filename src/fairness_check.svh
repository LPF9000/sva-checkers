// SPDX-License-Identifier: MIT
`ifndef SVA_FAIRNESS_CHECK_SVH
`define SVA_FAIRNESS_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_FAIRNESS_CHECK(NAME, REQUESTERS, MAX_WAIT, COUNT_ELAPSED, CLEAR_ON_INELIGIBLE) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic [REQUESTERS-1:0] request, \
    input logic [REQUESTERS-1:0] eligible, \
    input logic [REQUESTERS-1:0] grant, \
    input logic opportunity \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    int waits[REQUESTERS]; \
    for (genvar i = 0; i < REQUESTERS; i++) begin : g_wait \
        always_ff @(posedge clk) begin \
            if (!reset_n || !enable || !request[i] || (CLEAR_ON_INELIGIBLE && !eligible[i]) || grant[i]) \
                waits[i] <= 0; \
            else if (eligible[i] && (COUNT_ELAPSED || opportunity) && waits[i] < MAX_WAIT) \
                waits[i] <= waits[i] + 1; \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (REQUESTERS > 0 && MAX_WAIT > 0) \
        else $error("FAIRNESS_CFG"); \
    end \
    a_known : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {request, eligible, grant, opportunity} \
    )) \
    else $error("FAIRNESS_KNOWN"); \
    for (genvar i = 0; i < REQUESTERS; i++) begin : g_requester \
        a_grant : \
        assert property (@(posedge clk) disable iff (!reset_n || !enable) \
            !grant[i] || (request[i] && eligible[i])) \
        else $error("FAIRNESS_GRANT"); \
        a_wait : \
        assert property (@(posedge clk) disable iff (!reset_n || !enable) \
            !request[i] || !eligible[i] || grant[i] || !(COUNT_ELAPSED || opportunity) || waits[i]<MAX_WAIT-1) \
        else $error("FAIRNESS_WAIT"); \
    end \
endchecker : NAME

`endif
