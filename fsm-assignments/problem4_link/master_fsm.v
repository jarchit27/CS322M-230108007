`timescale 1ns / 1ps

module master_fsm(
    input clk,
    input rst,
    input ack,
    output req,
    output done,
    output [7:0] data
);

// State parameters for the master FSM
parameter IDLE        = 3'd0;
parameter ASSERT_REQ  = 3'd1;
parameter WAIT_ACK_HI = 3'd2;
parameter DROP_REQ    = 3'd3;
parameter WAIT_ACK_LO = 3'd4;
parameter NEXT_BYTE   = 3'd5;
parameter DONE_ST     = 3'd6;

reg [2:0] state, next_state;
reg [2:0] bytes_sent;
reg [7:0] data_reg;

// Combinational logic for state transitions
always @(*) begin
    case (state)
        IDLE:        next_state = ASSERT_REQ;
        ASSERT_REQ:  next_state = WAIT_ACK_HI;
        WAIT_ACK_HI: next_state = (ack ? DROP_REQ : WAIT_ACK_HI);
        DROP_REQ:    next_state = WAIT_ACK_LO;
        WAIT_ACK_LO: next_state = (!ack ? NEXT_BYTE : WAIT_ACK_LO);
        NEXT_BYTE:   next_state = (bytes_sent == 3'd4 ? DONE_ST : ASSERT_REQ);
        DONE_ST:     next_state = DONE_ST;
        default:     next_state = IDLE;
    endcase
end

// Sequential logic for state register, byte counter, and data register
always @(posedge clk) begin
    if (rst) begin
        state      <= IDLE;
        bytes_sent <= 3'd0;
        data_reg   <= 8'hA0;
    end else begin
        state <= next_state;
        // Increment byte counter and data after slave drops ack
        if (state == WAIT_ACK_LO && ack == 1'b0) begin
            bytes_sent <= bytes_sent + 3'd1;
            data_reg   <= data_reg + 8'h01;
        end
    end
end

// Output logic for req and done signals
assign req  = (state == ASSERT_REQ) || (state == WAIT_ACK_HI);
assign done = (state == DONE_ST);
assign data = data_reg;

endmodule
