// SPDX-License-Identifier: MIT
`ifndef SVA_REGISTER_CHECK_SVH
`define SVA_REGISTER_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_REGISTER_CHECK(NAME, WIDTH, RESET_VALUE, RW_MASK, W1C_MASK, W1S_MASK, READ_CLEAR_MASK, SET_WINS, HW_AFTER_SW) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic write_accepted, \
    input logic read_accepted, \
    input logic [WIDTH-1:0] write_data, \
    input logic [WIDTH-1:0] write_mask, \
    input logic [WIDTH-1:0] read_data, \
    input logic [WIDTH-1:0] hardware_set, \
    input logic [WIDTH-1:0] hardware_clear, \
    input logic [WIDTH-1:0] value \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    const logic [WIDTH-1:0] read_clear_bits = READ_CLEAR_MASK; \
    const logic [WIDTH-1:0] w1s_bits = W1S_MASK; \
    const logic [WIDTH-1:0] w1c_bits = W1C_MASK; \
    const logic [WIDTH-1:0] rw_bits = RW_MASK; \
    const logic [WIDTH-1:0] reset_bits = RESET_VALUE; \
    logic [WIDTH-1:0] shadow; \
    logic [WIDTH-1:0] next_shadow; \
    function automatic logic [WIDTH-1:0] software_update(input logic [WIDTH-1:0] old_value); \
        logic [WIDTH-1:0] result; \
        result = old_value; \
        if (read_accepted) result = result & ~read_clear_bits; \
        if (write_accepted) begin \
            result = (result & ~(rw_bits & write_mask)) | (write_data & rw_bits & write_mask); \
            result = result & ~(write_data & w1c_bits & write_mask); \
            result = result | (write_data & w1s_bits & write_mask); \
        end \
        return result; \
    endfunction \
    function automatic logic [WIDTH-1:0] hardware_update(input logic [WIDTH-1:0] old_value); \
        return SET_WINS ? ((old_value & ~hardware_clear) | hardware_set) : ((old_value | hardware_set) & ~hardware_clear); \
    endfunction \
    always_comb \
        next_shadow = HW_AFTER_SW ? hardware_update(software_update(shadow)) : \
            software_update(hardware_update(shadow)); \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) shadow <= reset_bits; \
        else shadow <= next_shadow; \
    end \
    initial begin \
        a_cfg : \
        assert (WIDTH>0 && ((RW_MASK & W1C_MASK)==0) && ((RW_MASK & W1S_MASK)==0) && ((W1C_MASK & W1S_MASK)==0)) \
        else $error("REGISTER_CFG"); \
    end \
    a_known : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {write_accepted, read_accepted, hardware_set, hardware_clear, value} \
    ) && (!write_accepted || !$isunknown( \
        {write_mask, write_data & write_mask} \
    ))) \
    else $error("REGISTER_KNOWN"); \
    a_value : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) value === shadow) \
    else $error("REGISTER_STATE"); \
    a_read : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        !read_accepted || read_data===shadow) \
    else $error("REGISTER_READ"); \
endchecker : NAME

`endif
