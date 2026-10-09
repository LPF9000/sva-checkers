// SPDX-License-Identifier: MIT
`ifndef SVA_LENGTH_CHECK_SVH
`define SVA_LENGTH_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_LENGTH_CHECK(NAME, MAX_LENGTH, BOUNDARY_BYTES, ADDR_WIDTH) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic start, \
    input logic beat, \
    input logic last, \
    input logic cancel, \
    input int unsigned command_length, \
    input int unsigned valid_bytes, \
    input logic [ADDR_WIDTH-1:0] address \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    typedef logic [63:0] arithmetic_t; \
    const arithmetic_t boundary_bytes = BOUNDARY_BYTES; \
    bit active; \
    int remaining; \
    logic [ADDR_WIDTH-1:0] start_address; \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable || cancel) begin \
            active <= 0; \
            remaining <= 0; \
            start_address <= '0; \
        end else if (start) begin \
            active <= 1; \
            remaining <= int'(command_length); \
            start_address <= address; \
        end else if (beat && active && longint'(valid_bytes) <= longint'(remaining)) begin \
            remaining <= remaining - int'(valid_bytes); \
            if (last) active <= 0; \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (MAX_LENGTH > 0 && BOUNDARY_BYTES > 0 && ADDR_WIDTH > 0 && ADDR_WIDTH <= 63) \
        else $error("LENGTH_CFG"); \
    end \
    a_known : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {start, beat, last, cancel, command_length, valid_bytes, address} \
    )) \
    else $error("LENGTH_KNOWN"); \
    a_start : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !start || (!active && !beat && !cancel && command_length>0 && longint'(command_length)<=longint'(MAX_LENGTH))) \
    else $error("LENGTH_START"); \
    a_payload : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        (!last || beat) && (!beat || (!start && !cancel && active && valid_bytes>0 && longint'(valid_bytes)<=longint'(remaining) && last==(longint'(valid_bytes)==longint'(remaining))))) \
    else $error("LENGTH_PAYLOAD"); \
    a_boundary : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !beat || ((arithmetic_t'(address) + arithmetic_t'(valid_bytes) - 1) <= ((64'd1 << ADDR_WIDTH) - 1) && \
        arithmetic_t'(address)/boundary_bytes == arithmetic_t'(start_address)/boundary_bytes && \
        (arithmetic_t'(address)+arithmetic_t'(valid_bytes)-1)/boundary_bytes == arithmetic_t'(start_address)/boundary_bytes)) \
    else $error("LENGTH_BOUNDARY"); \
    final if (active) $error("LENGTH_FINAL_DRAIN"); \
endchecker : NAME

`endif
