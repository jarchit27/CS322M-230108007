module seq_detect_mealy(
    input wire clk,   // System clock
    input wire rst,   // Synchronous active-high reset
    input wire din,   // Serial input bit per clock
    output reg y      // 1-cycle pulse when pattern "1101" is seen
);

    // S_IDLE: No part of the sequence has been detected.
    // S_1:    A "1" has been detected.
    // S_11:   "11" has been detected.
    // S_110:  "110" has been detected.
    localparam [1:0] S_IDLE = 2'b00;
    localparam [1:0] S_1    = 2'b01;
    localparam [1:0] S_11   = 2'b10;
    localparam [1:0] S_110  = 2'b11;

    // Internal Registers
    reg [1:0] current_state, next_state;

    
    // State Register Logic (Sequential)
    // This block represents the memory of the FSM, updating the state on each rising clock edge.
    always @(posedge clk) begin
        if (rst) begin
            // On reset, return to the initial idle state.
            current_state <= S_IDLE;
        end else begin
            // Otherwise, transition to the next calculated state.
            current_state <= next_state;
        end
    end

    
    // Next State Logic 
    // This block determines the next state based on the current state and the input 'din'.
    always @(*) begin
        // By default, stay in the current state. 
        next_state = current_state;
        case (current_state)
            S_IDLE: begin
                if (din) next_state = S_1;    // Detected "1"
                else     next_state = S_IDLE; // Still "0"
            end
            S_1: begin
                if (din) next_state = S_11;   // Detected "11"
                else     next_state = S_IDLE; // Sequence broken, got "10"
            end
            S_11: begin
                if (din) next_state = S_11;   // Sequence is "111", stay here as we still have "11"
                else     next_state = S_110;  // Detected "110"
            end
            S_110: begin
                if (din) next_state = S_1;    // Detected "1101", sequence found. 
                else     next_state = S_IDLE; // Sequence broken, got "1100"
            end
            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    // This block defines the output 'y'.
    always @(*) begin
        // The output 'y' is high only when we are in state S_110 and the input 'din' is 1.
        if (current_state == S_110 && din == 1'b1) begin
            y = 1'b1;
        end else begin
            y = 1'b0;
        end
    end

endmodule
