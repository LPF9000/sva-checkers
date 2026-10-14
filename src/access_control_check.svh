// SPDX-License-Identifier: MIT
`ifndef SVA_ACCESS_CONTROL_CHECK_SVH
`define SVA_ACCESS_CONTROL_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_ACCESS_CONTROL_CHECK(NAME, WIDTH, MAX_LATENCY, DENIED_READ_VALUE) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic accepted, \
    input logic authorized, \
    input logic write, \
    input logic response, \
    input logic response_error, \
    input logic [WIDTH-1:0] read_data, \
    input logic [WIDTH-1:0] protected_value, \
    input logic forbidden_effect, \
    input logic protected_update_allowed \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    const logic [WIDTH-1:0] denied_read_bits = DENIED_READ_VALUE; \
    bit pending_denied; \
    bit guard_active; \
    bit denied_write; \
    logic [WIDTH-1:0] saved_value; \
    int age; \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            pending_denied <= 0; \
            guard_active <= 0; \
            denied_write <= 0; \
            saved_value <= '0; \
            age <= 0; \
        end else begin \
            if (accepted && !authorized && write) guard_active <= 1; \
            else if (protected_update_allowed) guard_active <= 0; \
            if (accepted && !authorized) begin \
                pending_denied <= 1; \
                denied_write <= write; \
                saved_value <= protected_value; \
                age <= 0; \
            end else if (response && pending_denied) begin \
                pending_denied <= 0; \
                age <= 0; \
            end else if (pending_denied && age < MAX_LATENCY) age <= age + 1; \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (WIDTH > 0 && MAX_LATENCY > 0 && MAX_LATENCY < 2147483647) \
        else $error("ACCESS_CFG"); \
    end \
    a_events : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {accepted,authorized,write,response,response_error,forbidden_effect,protected_update_allowed} \
    ) && (!accepted || !pending_denied) && !(accepted && !authorized && response)) \
    else $error("ACCESS_EVENTS"); \
    a_denied_effect : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !forbidden_effect && \
        (!(guard_active || (pending_denied && denied_write)) || protected_update_allowed || protected_value===saved_value)) \
    else $error("ACCESS_EFFECT"); \
    a_response : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !response || !pending_denied || (response_error && (denied_write || read_data===denied_read_bits))) \
    else $error("ACCESS_RESPONSE"); \
    a_deadline : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !pending_denied || age<MAX_LATENCY) \
    else $error("ACCESS_DEADLINE"); \
    final if (pending_denied) $error("ACCESS_FINAL_DRAIN"); \
endchecker : NAME

`endif
