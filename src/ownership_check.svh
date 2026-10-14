// SPDX-License-Identifier: MIT
`ifndef SVA_OWNERSHIP_CHECK_SVH
`define SVA_OWNERSHIP_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_OWNERSHIP_CHECK(NAME, USERS) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic [USERS-1:0] grant, \
    input logic [USERS-1:0] release_owner, \
    input logic [USERS-1:0] access \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    logic [USERS-1:0] owners; \
    logic [USERS-1:0] next_owners; \
    always_comb next_owners = (owners & ~release_owner) | grant; \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable) owners <= '0; \
        else owners <= next_owners; \
    end \
    initial begin \
        a_cfg : \
        assert (USERS > 0) \
        else $error("OWNERSHIP_CFG"); \
    end \
    a_known : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {grant, release_owner, access} \
    )) \
    else $error("OWNERSHIP_KNOWN"); \
    a_exclusive : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) $onehot0( \
        next_owners \
    ) && ((release_owner & ~owners) == '0) && ((grant & (owners & ~release_owner)) == '0)) \
    else $error("OWNERSHIP_GRANT"); \
    a_access : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) (access & ~owners) == '0) \
    else $error("OWNERSHIP_ACCESS"); \
endchecker : NAME

`endif
