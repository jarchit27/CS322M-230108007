// Operation:
// - Item price is 20 cents.
// - Accepts 5-cent (coin=01) and 10-cent (coin=10) coins.
// - When total is >= 20, 'dispense' is asserted for one cycle.
// - If total is 25, 'chg5' is also asserted to return 5 cents change.
// - The total is reset after a dispense.

module vending_mealy(
    input wire clk,          // System clock
    input wire rst,          // Synchronous active-high reset
    input wire [1:0] coin,   // Coin input: 01=5, 10=10, 00=idle
    output reg dispense,     // 1-cycle pulse to dispense item
    output reg chg5          // 1-cycle pulse to return 5 cents change
);

    // State Definitions
    localparam [1:0] S_0  = 2'b00; // 0 cents
    localparam [1:0] S_5  = 2'b01; // 5 cents
    localparam [1:0] S_10 = 2'b10; // 10 cents
    localparam [1:0] S_15 = 2'b11; // 15 cents

    // Coin Value Definitions
    localparam [1:0] C_NONE = 2'b00;
    localparam [1:0] C_5    = 2'b01;
    localparam [1:0] C_10   = 2'b10;

    // Internal Registers
    reg [1:0] current_state, next_state;

    // State Register Logic
    always @(posedge clk) begin
        if (rst) begin
            current_state <= S_0;
        end else begin
            current_state <= next_state;
        end
    end

    // Next State Logic (Combinational)
    always @(*) begin
        next_state = current_state; // Default: stay in current state
        case (current_state)
            S_0: begin
                if (coin == C_5)      next_state = S_5;
                else if (coin == C_10) next_state = S_10;
            end
            S_5: begin
                if (coin == C_5)      next_state = S_10;
                else if (coin == C_10) next_state = S_15;
            end
            S_10: begin
                if (coin == C_5)      next_state = S_15;
                // If coin is 10, total is 20. Vend and reset.
                else if (coin == C_10) next_state = S_0;
            end
            S_15: begin
                // If coin is 5 or 10, total is >=20. Vend and reset.
                if (coin == C_5 || coin == C_10) next_state = S_0;
            end
            default: begin
                next_state = S_0;
            end
        endcase
    end

    // Output Logic
    always @(*) begin
        // Default outputs to low
        dispense = 1'b0;
        chg5 = 1'b0;

        case (current_state)
            S_10: begin
                if (coin == C_10) begin // Total becomes 20
                    dispense = 1'b1;
                end
            end
            S_15: begin
                if (coin == C_5) begin  // Total becomes 20
                    dispense = 1'b1;
                end else if (coin == C_10) begin // Total becomes 25
                    dispense = 1'b1;
                    chg5 = 1'b1;
                end
            end
        endcase
    end

endmodule