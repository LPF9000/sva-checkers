// SPDX-License-Identifier: MIT
`ifndef SVA_ID_TRACKER_CHECK_SVH
`define SVA_ID_TRACKER_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_ID_TRACKER_CHECK(NAME, ID_WIDTH, DATA_WIDTH, CAPACITY, MAX_LATENCY, IN_ORDER, ALLOW_ID_REUSE, CHECK_DATA, REQUIRE_DRAIN, REQUIRE_DATA) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic accepted, \
    input logic completed, \
    input logic canceled, \
    input logic drain, \
    input logic [ID_WIDTH-1:0] request_id, \
    input logic [ID_WIDTH-1:0] response_id, \
    input logic [ID_WIDTH-1:0] cancel_id, \
    input logic [DATA_WIDTH-1:0] expected_data, \
    input logic [DATA_WIDTH-1:0] actual_data, \
    input logic [DATA_WIDTH-1:0] valid_mask \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    typedef struct packed { \
        logic [CAPACITY-1:0][ID_WIDTH-1:0] ids; \
        logic [CAPACITY-1:0][DATA_WIDTH-1:0] payloads; \
        logic [CAPACITY-1:0][DATA_WIDTH-1:0] masks; \
        logic [CAPACITY-1:0][31:0] ages; \
        int count; \
    } state_t; \
    typedef struct packed { \
        logic [CAPACITY-1:0][ID_WIDTH-1:0] next_ids; \
        logic [CAPACITY-1:0][DATA_WIDTH-1:0] next_payloads; \
        logic [CAPACITY-1:0][DATA_WIDTH-1:0] next_masks; \
        logic [CAPACITY-1:0][31:0] next_ages; \
        int next_count; \
        int completion_index; \
        int cancellation_index; \
        bit events_ok; \
        bit data_ok; \
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
        next_value.data_ok = 1; \
        next_value.deadline_ok = 1; \
        next_value.completion_index = -1; \
        next_value.cancellation_index = -1; \
        for (int i = 0; i < CAPACITY; i++) begin \
            next_value.next_ids[i] = current.ids[i]; \
            next_value.next_payloads[i] = current.payloads[i]; \
            next_value.next_masks[i] = current.masks[i]; \
            next_value.next_ages[i] = int'(current.ages[i]) < MAX_LATENCY ? current.ages[i] + 1 : current.ages[i]; \
            if (i < current.count && MAX_LATENCY != 0 && int'(current.ages[i]) >= MAX_LATENCY) \
                next_value.deadline_ok = 0; \
            if (i < current.count && current.ids[i] == response_id && next_value.completion_index < 0) \
                next_value.completion_index = i; \
        end \
        if (completed) begin \
            if (next_value.completion_index < 0 || (IN_ORDER && next_value.completion_index != 0)) \
                next_value.events_ok = 0; \
            else begin \
                if (CHECK_DATA && ($isunknown( \
                        (actual_data ^ current.payloads[next_value.completion_index]) & current.masks[next_value.completion_index] \
                    ) || (((actual_data ^ current.payloads[next_value.completion_index]) & \
                           current.masks[next_value.completion_index]) != '0))) \
                    next_value.data_ok = 0; \
                for (int i = 0; i < CAPACITY - 1; i++) begin \
                    if (i >= next_value.completion_index && i < current.count - 1) begin \
                        next_value.next_ids[i] = current.ids[i+1]; \
                        next_value.next_payloads[i] = current.payloads[i+1]; \
                        next_value.next_masks[i] = current.masks[i+1]; \
                        next_value.next_ages[i] = next_value.next_ages[i+1]; \
                    end \
                end \
                next_value.next_count = next_value.next_count - 1; \
            end \
        end \
        for (int i = 0; i < CAPACITY; i++) begin \
            if (i < next_value.next_count && next_value.next_ids[i] == cancel_id && next_value.cancellation_index < 0) \
                next_value.cancellation_index = i; \
        end \
        if (canceled) begin \
            if (next_value.cancellation_index < 0) next_value.events_ok = 0; \
            else begin \
                for (int i = 0; i < CAPACITY - 1; i++) begin \
                    if (i >= next_value.cancellation_index && i < next_value.next_count - 1) begin \
                        next_value.next_ids[i] = next_value.next_ids[i+1]; \
                        next_value.next_payloads[i] = next_value.next_payloads[i+1]; \
                        next_value.next_masks[i] = next_value.next_masks[i+1]; \
                        next_value.next_ages[i] = next_value.next_ages[i+1]; \
                    end \
                end \
                next_value.next_count = next_value.next_count - 1; \
            end \
        end \
        if (accepted) begin \
            for (int i = 0; i < CAPACITY; i++) begin \
                if (i < next_value.next_count && next_value.next_ids[i] == request_id && !ALLOW_ID_REUSE) \
                    next_value.events_ok = 0; \
            end \
            if (next_value.next_count >= CAPACITY) next_value.events_ok = 0; \
            else begin \
                next_value.next_ids[next_value.next_count] = request_id; \
                next_value.next_payloads[next_value.next_count] = expected_data; \
                next_value.next_masks[next_value.next_count] = valid_mask; \
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
            state.ids <= '0; \
            state.payloads <= '0; \
            state.masks <= '0; \
            state.ages <= 0; \
        end else if (result.events_ok) begin \
            state.count <= result.next_count; \
            state.ids <= result.next_ids; \
            state.payloads <= result.next_payloads; \
            state.masks <= result.next_masks; \
            state.ages <= result.next_ages; \
        end \
    end \
    initial begin \
        a_cfg : \
        assert ((!REQUIRE_DATA || CHECK_DATA) && ID_WIDTH > 0 && DATA_WIDTH > 0 && CAPACITY > 0 && CAPACITY <= 1024 && MAX_LATENCY >= 0 && MAX_LATENCY < 2147483647) \
        else $error("TRANSACTION_CFG"); \
    end \
    a_known : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {accepted, completed, canceled, drain} \
    ) && (!accepted || !$isunknown( \
        request_id \
    )) && (!completed || !$isunknown( \
        response_id \
    )) && (!canceled || !$isunknown( \
        cancel_id \
    )) && (!accepted || !CHECK_DATA || (!$isunknown( \
        valid_mask \
    ) && !$isunknown( \
        expected_data & valid_mask \
    )))) \
    else $error("TRANSACTION_KNOWN"); \
    a_events : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) result.events_ok) \
    else $error("TRANSACTION_ORDER"); \
    a_data : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) result.data_ok) \
    else $error("TRANSACTION_DATA"); \
    a_deadline : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) result.deadline_ok) \
    else $error("TRANSACTION_DEADLINE"); \
    a_drain : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !drain || result.next_count == 0) \
    else $error("TRANSACTION_DRAIN"); \
    final if (REQUIRE_DRAIN && state.count != 0) $error("TRANSACTION_FINAL_DRAIN"); \
endchecker : NAME

`endif
