// SPDX-License-Identifier: MIT
`ifndef SVA_CONFIGURATION_CHECK_SVH
`define SVA_CONFIGURATION_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_CONFIGURATION_CHECK(NAME, WIDTH, RESET_VALUE, MAX_LATENCY, REPLACE_PENDING) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic update_accepted, \
    input logic [WIDTH-1:0] update_value, \
    input logic commit, \
    input logic legal_boundary, \
    input logic [WIDTH-1:0] active_value \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    const logic [WIDTH-1:0] reset_bits = RESET_VALUE; \
    bit pending; \
    logic [WIDTH-1:0] pending_value; \
    logic [WIDTH-1:0] expected_active; \
    int age; \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            pending <= 0; \
            pending_value <= '0; \
            expected_active <= reset_bits; \
            age <= 0; \
        end else begin \
            if (commit && pending) begin \
                expected_active <= pending_value; \
                pending <= 0; \
                age <= 0; \
            end \
            if (update_accepted) begin \
                pending <= 1; \
                pending_value <= update_value; \
                age <= 0; \
            end else if (pending && !commit && age < MAX_LATENCY) age <= age + 1; \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (WIDTH > 0 && MAX_LATENCY > 0 && MAX_LATENCY < 2147483647) \
        else $error("CONFIGURATION_CFG"); \
    end \
    a_events : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {update_accepted, commit, legal_boundary} \
    ) && (!update_accepted || !$isunknown( \
        update_value \
    )) && (!commit || (pending && legal_boundary)) && \
        (!update_accepted || !pending || commit || REPLACE_PENDING)) \
    else $error("CONFIGURATION_EVENTS"); \
    a_active : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        active_value===expected_active) \
    else $error("CONFIGURATION_ACTIVE"); \
    a_deadline : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !pending || age < MAX_LATENCY) \
    else $error("CONFIGURATION_DEADLINE"); \
    final if (pending) $error("CONFIGURATION_FINAL_DRAIN"); \
endchecker : NAME

`endif
