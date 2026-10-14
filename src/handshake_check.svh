// SPDX-License-Identifier: MIT
`ifndef SVA_HANDSHAKE_CHECK_SVH
`define SVA_HANDSHAKE_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_HANDSHAKE_CHECK(NAME, CAPACITY, MAX_LATENCY, ALLOW_BYPASS, REQUIRE_DRAIN) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic accepted, \
    input logic completed, \
    input logic canceled, \
    input logic drain \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    typedef struct packed { \
        int count; \
        logic [CAPACITY-1:0][31:0] ages; \
    } state_t; \
    typedef struct packed { \
        int next_count; \
        logic [CAPACITY-1:0][31:0] next_ages; \
        bit events_ok; \
        bit deadline_ok; \
    } result_t; \
    state_t  state; \
    result_t result; \
 \
    function automatic result_t compute(input state_t current); \
        result_t next_value; \
        next_value = '0; \
        next_value.next_count = current.count; \
        next_value.events_ok = 1; \
        next_value.deadline_ok = 1; \
        for (int i = 0; i < CAPACITY; i++) begin \
            next_value.next_ages[i]=int'(current.ages[i]) < MAX_LATENCY ? current.ages[i]+1 : current.ages[i]; \
            if (i < current.count && int'(current.ages[i]) >= MAX_LATENCY) \
                next_value.deadline_ok = 0; \
        end \
        if (completed || canceled) begin \
            if (completed && canceled) next_value.events_ok = 0; \
            if (current.count == 0) begin \
                if (!(ALLOW_BYPASS && accepted)) next_value.events_ok = 0; \
            end else begin \
                for (int i = 0; i < CAPACITY - 1; i++) begin \
                    next_value.next_ages[i] = next_value.next_ages[i+1]; \
                end \
                next_value.next_count = current.count - 1; \
            end \
        end \
        if (accepted && !(current.count == 0 && ALLOW_BYPASS && (completed || canceled))) begin \
            if (next_value.next_count >= CAPACITY) next_value.events_ok = 0; \
            else begin \
                next_value.next_ages[next_value.next_count] = 0; \
                next_value.next_count = next_value.next_count + 1; \
            end \
        end \
        return next_value; \
    endfunction \
    always_comb result = compute(state); \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            state.count <= 0; \
            state.ages  <= 0; \
        end else if (result.events_ok) begin \
            state.count <= result.next_count; \
            state.ages  <= result.next_ages; \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (CAPACITY > 0 && CAPACITY <= 1024 && MAX_LATENCY > 0 && MAX_LATENCY < 2147483647) \
        else $error("HANDSHAKE_CFG"); \
    end \
    a_known : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {accepted, completed, canceled, drain} \
    )) \
    else $error("HANDSHAKE_KNOWN"); \
    a_order : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) result.events_ok) \
    else $error("HANDSHAKE_ORDER"); \
    a_latency : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) result.deadline_ok) \
    else $error("HANDSHAKE_LATENCY"); \
    a_drain : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !drain || result.next_count==0) \
    else $error("HANDSHAKE_DRAIN"); \
    final if (REQUIRE_DRAIN && state.count != 0) $error("HANDSHAKE_FINAL_DRAIN"); \
endchecker : NAME

`endif
