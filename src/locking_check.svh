// SPDX-License-Identifier: MIT
`ifndef SVA_LOCKING_CHECK_SVH
`define SVA_LOCKING_CHECK_SVH
`include "lifecycle_check.svh"

`define SVA_DECLARE_LOCKING_CHECK(NAME, WIDTH, LOCK_WINS) \
checker NAME ( \
    input logic clk, \
    input logic reset_n, \
    input logic enable, \
    input logic lock_accepted, \
    input logic permitted_unlock, \
    input logic clear_lock_reset, \
    input logic protected_write, \
    input logic [WIDTH-1:0] protected_value, \
    input logic lock_value \
); \
    `SVA_ASSERT_LIFECYCLE(clk, reset_n, enable) \
    bit expected_locked; \
    logic [WIDTH-1:0] saved_value; \
    always_ff @(posedge clk) begin \
        if (!reset_n || !enable || clear_lock_reset) begin \
            expected_locked <= 0; \
            saved_value <= protected_value; \
        end else begin \
            if (permitted_unlock) expected_locked <= 0; \
            if (lock_accepted) begin \
                expected_locked <= 1; \
                saved_value <= protected_value; \
            end else if (!expected_locked) saved_value <= protected_value; \
        end \
    end \
    initial begin \
        a_cfg : \
        assert (WIDTH > 0) \
        else $error("LOCKING_CFG"); \
    end \
    a_control : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) !$isunknown( \
        {lock_accepted, permitted_unlock, clear_lock_reset, protected_write, lock_value} \
    ) && !(lock_accepted && permitted_unlock)) \
    else $error("LOCKING_CONTROL"); \
    a_state : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        clear_lock_reset || lock_value==expected_locked) \
    else $error("LOCKING_STATE"); \
    a_protection : \
    assert property (@(posedge clk) disable iff (!reset_n || !enable) \
        clear_lock_reset || permitted_unlock || \
        ((!expected_locked || protected_value===saved_value) && \
        (!(expected_locked || (LOCK_WINS && lock_accepted)) || !protected_write))) \
    else $error("LOCKING_PROTECTION"); \
endchecker : NAME

`endif
