// SPDX-License-Identifier: MIT
`ifndef SVA_CANCELLATION_CHECK_SVH
`define SVA_CANCELLATION_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_CANCELLATION_CHECK(NAME, ID_WIDTH, GEN_WIDTH, CAPACITY, MAX_LATENCY, REQUIRE_CANCEL_RESPONSE, REQUIRE_DRAIN) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic accepted, \
    input logic [ID_WIDTH-1:0] request_id, \
    input logic [GEN_WIDTH-1:0] generation, \
    input logic commit, \
    input logic [ID_WIDTH-1:0] commit_id, \
    input logic flush, \
    input logic cancel, \
    input logic [ID_WIDTH-1:0] cancel_id, \
    input logic response, \
    input logic [ID_WIDTH-1:0] response_id, \
    input logic [GEN_WIDTH-1:0] response_generation, \
    input logic response_canceled, \
    input logic flush_ack \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    typedef struct packed { \
        logic [CAPACITY-1:0][ID_WIDTH-1:0] ids; \
        logic [CAPACITY-1:0][GEN_WIDTH-1:0] tags; \
        logic [CAPACITY-1:0] committed; \
        logic [CAPACITY-1:0] cancel_pending; \
        logic [CAPACITY-1:0][31:0] ages; \
        int count; \
    } state_t; \
    typedef struct packed { \
        logic [CAPACITY-1:0][ID_WIDTH-1:0] next_ids; \
        logic [CAPACITY-1:0][GEN_WIDTH-1:0] next_tags; \
        logic [CAPACITY-1:0] next_committed; \
        logic [CAPACITY-1:0] next_cancel_pending; \
        logic [CAPACITY-1:0][31:0] next_ages; \
        int next_count; \
        bit events_ok; \
        bit cleanup_ok; \
        bit deadlines_ok; \
        int index; \
    } result_t; \
    state_t state; \
    result_t result; \
    logic [GEN_WIDTH-1:0] expected_generation; \
    bit flushing; \
    int flush_age; \
    function automatic result_t compute(input state_t current); \
        result_t next_value; \
        next_value = '0; \
        next_value.next_count = current.count; \
        next_value.events_ok = 1; \
        next_value.cleanup_ok = 1; \
        next_value.deadlines_ok = 1; \
        next_value.index = -1; \
        for (int i = 0; i < CAPACITY; i++) begin \
            next_value.next_ids[i] = current.ids[i]; \
            next_value.next_tags[i] = current.tags[i]; \
            next_value.next_committed[i] = current.committed[i]; \
            next_value.next_cancel_pending[i] = current.cancel_pending[i]; \
            next_value.next_ages[i]=int'(current.ages[i])<MAX_LATENCY ? current.ages[i]+1 : current.ages[i]; \
            if(i<current.count && current.cancel_pending[i] && int'(current.ages[i])>=MAX_LATENCY) \
                next_value.deadlines_ok = 0; \
        end \
        if (commit) begin \
            for (int i = 0; i < CAPACITY; i++) begin \
                if (i < current.count && current.ids[i] == commit_id && next_value.index < 0) \
                    next_value.index = i; \
            end \
            if (next_value.index < 0 || current.cancel_pending[next_value.index]) \
                next_value.events_ok = 0; \
            else next_value.next_committed[next_value.index] = 1; \
        end \
        next_value.index = -1; \
        if (cancel) begin \
            for (int i = 0; i < CAPACITY; i++) begin \
                if (i < current.count && current.ids[i] == cancel_id && next_value.index < 0) \
                    next_value.index = i; \
            end \
            if(next_value.index<0 || next_value.next_committed[next_value.index] || current.cancel_pending[next_value.index]) \
                next_value.events_ok = 0; \
        end \
        for (int i = 0; i < CAPACITY; i++) begin \
            if(i<current.count && !next_value.next_committed[i] && (flush || (cancel && i==next_value.index))) begin \
                next_value.next_cancel_pending[i] = 1; \
                next_value.next_ages[i] = 0; \
            end \
        end \
        if (!REQUIRE_CANCEL_RESPONSE) begin \
            next_value.next_count = 0; \
            for (int i = 0; i < CAPACITY; i++) begin \
                if (i < current.count && !next_value.next_cancel_pending[i]) begin \
                    next_value.next_ids[next_value.next_count] = next_value.next_ids[i]; \
                    next_value.next_tags[next_value.next_count] = next_value.next_tags[i]; \
                    next_value.next_committed[next_value.next_count] = next_value.next_committed[i]; \
                    next_value.next_cancel_pending[next_value.next_count] = 0; \
                    next_value.next_ages[next_value.next_count] = next_value.next_ages[i]; \
                    next_value.next_count = next_value.next_count + 1; \
                end \
            end \
        end \
        next_value.index = -1; \
        if (response) begin \
            for (int i = 0; i < CAPACITY; i++) begin \
                if(i<next_value.next_count && next_value.next_ids[i]==response_id && next_value.next_tags[i]==response_generation && next_value.index<0) \
                    next_value.index = i; \
            end \
            if (next_value.index < 0) next_value.events_ok = 0; \
            else begin \
                if (response_canceled != next_value.next_cancel_pending[next_value.index]) \
                    next_value.events_ok = 0; \
                for (int i = 0; i < CAPACITY - 1; i++) begin \
                    if (i >= next_value.index && i < next_value.next_count - 1) begin \
                        next_value.next_ids[i] = next_value.next_ids[i+1]; \
                        next_value.next_tags[i] = next_value.next_tags[i+1]; \
                        next_value.next_committed[i] = next_value.next_committed[i+1]; \
                        next_value.next_cancel_pending[i] = next_value.next_cancel_pending[i+1]; \
                        next_value.next_ages[i] = next_value.next_ages[i+1]; \
                    end \
                end \
                next_value.next_count = next_value.next_count - 1; \
            end \
        end \
        if (accepted) begin \
            if (flush || cancel || next_value.next_count >= CAPACITY) next_value.events_ok = 0; \
            for (int i = 0; i < CAPACITY; i++) begin \
                if(i<next_value.next_count && next_value.next_ids[i]==request_id && next_value.next_tags[i]==generation) \
                    next_value.events_ok = 0; \
            end \
            if (next_value.next_count < CAPACITY) begin \
                next_value.next_ids[next_value.next_count] = request_id; \
                next_value.next_tags[next_value.next_count] = generation; \
                next_value.next_committed[next_value.next_count] = 0; \
                next_value.next_cancel_pending[next_value.next_count] = 0; \
                next_value.next_ages[next_value.next_count] = 0; \
                next_value.next_count = next_value.next_count + 1; \
            end \
        end \
        for (int i = 0; i < CAPACITY; i++) begin \
            if (i < next_value.next_count && next_value.next_cancel_pending[i]) \
                next_value.cleanup_ok = 0; \
        end \
        return next_value; \
    endfunction \
    always_comb result = compute(state); \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) begin \
            state.count <= 0; \
            expected_generation <= '0; \
            flushing <= 0; \
            flush_age <= 0; \
            state.ids <= '0; \
            state.tags <= '0; \
            state.committed <= 0; \
            state.cancel_pending <= 0; \
            state.ages <= 0; \
        end else begin \
            if (result.events_ok) begin \
                state.count <= result.next_count; \
                state.ids <= result.next_ids; \
                state.tags <= result.next_tags; \
                state.committed <= result.next_committed; \
                state.cancel_pending <= result.next_cancel_pending; \
                state.ages <= result.next_ages; \
            end \
            if (flush) begin \
                expected_generation <= expected_generation + 1'b1; \
                flushing <= !flush_ack; \
                flush_age <= 0; \
            end else if (flush_ack) begin \
                flushing  <= 0; \
                flush_age <= 0; \
            end else if (flushing && flush_age < MAX_LATENCY) flush_age <= flush_age + 1; \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (ID_WIDTH>0 && GEN_WIDTH>0 && CAPACITY>0 && CAPACITY<=1024 && MAX_LATENCY>0 && MAX_LATENCY<2147483647) \
        else $error("CANCELLATION_CFG"); \
    end \
    a_known : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {accepted, commit, flush, cancel, response, response_canceled, flush_ack, generation} \
    ) && (!accepted || !$isunknown( \
        request_id \
    )) && (!commit || !$isunknown( \
        commit_id \
    )) && (!cancel || !$isunknown( \
        cancel_id \
    )) && (!response || !$isunknown( \
        {response_id, response_generation} \
    ))) \
    else $error("CANCELLATION_KNOWN"); \
    a_generation : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        generation==expected_generation && (!flush || expected_generation!={GEN_WIDTH{1'b1}})) \
    else $error("CANCELLATION_GENERATION"); \
    a_events : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        result.events_ok && !(flush && cancel) && (!flush || !flushing)) \
    else $error("CANCELLATION_EVENTS"); \
    a_ack : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !flush_ack || ((flushing || flush) && result.cleanup_ok)) \
    else $error("CANCELLATION_ACK"); \
    a_deadline : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        result.deadlines_ok && (!flushing || flush_age<MAX_LATENCY)) \
    else $error("CANCELLATION_DEADLINE"); \
    final if (REQUIRE_DRAIN && state.count != 0) $error("CANCELLATION_FINAL_DRAIN"); \
endchecker : NAME

`endif
