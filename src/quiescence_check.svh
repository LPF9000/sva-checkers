// SPDX-License-Identifier: MIT
`ifndef SVA_QUIESCENCE_CHECK_SVH
`define SVA_QUIESCENCE_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_QUIESCENCE_CHECK(NAME, MAX_LATENCY, ALLOW_NEW_DURING_DRAIN) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic shutdown, \
    input logic acknowledge, \
    input logic wake, \
    input logic new_work, \
    input logic forbidden_activity, \
    input int unsigned outstanding \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    typedef enum logic [1:0] { \
        RUNNING, \
        DRAINING, \
        QUIESCENT \
    } state_t; \
    state_t state; \
    int age; \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            state <= RUNNING; \
            age   <= 0; \
        end else \
            case (state) \
                RUNNING: \
                if (shutdown) begin \
                    state <= DRAINING; \
                    age   <= 0; \
                end \
                DRAINING: \
                if (acknowledge) begin \
                    state <= QUIESCENT; \
                    age   <= 0; \
                end else if (age < MAX_LATENCY) age <= age + 1; \
                QUIESCENT: if (wake) state <= RUNNING; \
                default:   state <= RUNNING; \
            endcase \
    end \
    initial begin \
        a_cfg : \
        assert (MAX_LATENCY > 0 && MAX_LATENCY < 2147483647) \
        else $error("QUIESCENCE_CFG"); \
    end \
    a_events : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {shutdown, acknowledge, wake, new_work, forbidden_activity, outstanding} \
    ) && (!shutdown || state == RUNNING) && \
        (!acknowledge || (state == DRAINING && outstanding == 0 && !new_work)) && \
        (!wake || state == QUIESCENT)) \
    else $error("QUIESCENCE_EVENTS"); \
    a_activity : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        (state!=QUIESCENT || (!new_work && !forbidden_activity && outstanding==0)) && \
        (ALLOW_NEW_DURING_DRAIN || (!(state==DRAINING || shutdown) || !new_work))) \
    else $error("QUIESCENCE_ACTIVITY"); \
    a_deadline : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        state!=DRAINING || age<MAX_LATENCY) \
    else $error("QUIESCENCE_DEADLINE"); \
    final if (state == DRAINING) $error("QUIESCENCE_FINAL_DRAIN"); \
endchecker : NAME

`endif
