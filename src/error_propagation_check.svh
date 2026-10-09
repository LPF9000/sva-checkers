// SPDX-License-Identifier: MIT
`ifndef SVA_ERROR_PROPAGATION_CHECK_SVH
`define SVA_ERROR_PROPAGATION_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_ERROR_PROPAGATION_CHECK(NAME, ID_WIDTH, CODE_WIDTH, ERROR_CODE, MAX_LATENCY) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic error_trigger, \
    input logic [ID_WIDTH-1:0] error_id, \
    input logic terminal, \
    input logic [ID_WIDTH-1:0] terminal_id, \
    input logic [CODE_WIDTH-1:0] terminal_code, \
    input logic forbidden_effect, \
    input logic recover \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    const logic [CODE_WIDTH-1:0] error_bits = ERROR_CODE; \
    bit pending; \
    bit blocked; \
    logic [ID_WIDTH-1:0] expected_id; \
    int age; \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            pending <= 0; \
            blocked <= 0; \
            expected_id <= '0; \
            age <= 0; \
        end else begin \
            if (recover) blocked <= 0; \
            if (error_trigger) begin \
                pending <= 1; \
                blocked <= 1; \
                expected_id <= error_id; \
                age <= 0; \
            end else if (terminal && pending) begin \
                pending <= 0; \
                age <= 0; \
            end else if (pending && age < MAX_LATENCY) age <= age + 1; \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (ID_WIDTH>0 && CODE_WIDTH>0 && MAX_LATENCY>0 && MAX_LATENCY<2147483647 && !$isunknown( \
            error_bits \
        )) \
        else $error("ERROR_CFG"); \
    end \
    a_trigger : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {error_trigger, terminal, recover, forbidden_effect} \
    ) && (!error_trigger || (!pending && !terminal && !recover && !$isunknown( \
        error_id \
    )))) \
    else $error("ERROR_TRIGGER"); \
    a_response : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !terminal || !pending || (!$isunknown( \
        {terminal_id, terminal_code} \
    ) && terminal_id == expected_id && terminal_code == ERROR_CODE)) \
    else $error("ERROR_RESPONSE"); \
    a_latency : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !pending || age < MAX_LATENCY) \
    else $error("ERROR_LATENCY"); \
    a_effect : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        (!(blocked || error_trigger) || !forbidden_effect) && (!recover || !pending)) \
    else $error("ERROR_EFFECT"); \
endchecker : NAME

`endif
