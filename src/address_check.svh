// SPDX-License-Identifier: MIT
`ifndef SVA_ADDRESS_CHECK_SVH
`define SVA_ADDRESS_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_ADDRESS_CHECK(NAME, ADDR_WIDTH, SIZE_WIDTH, BASE_ADDR, LAST_ADDR, ALIGNMENT) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic accepted, \
    input logic write, \
    input logic read_allowed, \
    input logic write_allowed, \
    input logic [ADDR_WIDTH-1:0] address, \
    input logic [SIZE_WIDTH-1:0] bytes \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    typedef logic [63:0] arithmetic_t; \
    const arithmetic_t alignment_bytes = ALIGNMENT; \
    logic [ADDR_WIDTH:0] end_address; \
    always_comb end_address = {1'b0, address} + (ADDR_WIDTH + 1)'(bytes) - 1; \
    initial begin \
        a_cfg : \
        assert (ADDR_WIDTH > 0 && ADDR_WIDTH <= 63 && SIZE_WIDTH > 0 && \
        SIZE_WIDTH <= ADDR_WIDTH && BASE_ADDR <= LAST_ADDR && ALIGNMENT > 0) \
        else $error("ADDRESS_CFG"); \
    end \
    a_span : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !accepted || (!$isunknown( \
        {write, read_allowed, write_allowed, address, bytes} \
    ) && bytes != 0 && address >= BASE_ADDR && end_address <= LAST_ADDR && !end_address[ADDR_WIDTH] \
        && arithmetic_t'(address) % alignment_bytes == 0 && (write ? write_allowed : read_allowed))) \
    else $error("ADDRESS_ACCESS"); \
endchecker : NAME

`endif
