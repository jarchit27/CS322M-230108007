`timescale 1ns / 1ps

module slave_fsm(
    input clk,
    input rst,
    input req,
    input [7:0] data_in,
    output ack,
    output reg [7:0] last_byte
);

// State parameters for the slave FSM
parameter WAIT_REQ   = 2'd0;
parameter ACK_ASSERT = 2'd1;
parameter ACK_HOLD   = 2'd2;
parameter WAIT_DROP  = 2'd3;

reg [1:0] state, next_state;

// Combinational logic for state transitions
always @(*) begin
    case (state)
        WAIT_REQ:   next_state = req ? ACK_ASSERT : WAIT_REQ;
        ACK_ASSERT: next_state = ACK_HOLD; // Unconditionally move to hold state for the 2nd cycle
        ACK_HOLD:   next_state = WAIT_DROP;  // After 2 cycles, move to wait for req drop
        WAIT_DROP:  next_state = req ? WAIT_DROP : WAIT_REQ;
        default:    next_state = WAIT_REQ;
    endcase
end

// Sequential logic for state register and data latching
always @(posedge clk) begin
    if (rst) begin
        state     <= WAIT_REQ;
        last_byte <= 8'd0;
    end else begin
        state <= next_state;
        // Latch the incoming data when request is first seen
        if (state == WAIT_REQ && req) begin
            last_byte <= data_in;
        end
    end
end

// Output logic: Assert ack for exactly two cycles
// Ack is high only in ACK_ASSERT and ACK_HOLD states.
assign ack = (state == ACK_ASSERT) || (state == ACK_HOLD);

endmodule
