module traffic_light(
    input  wire clk,
    input  wire rst,   // sync active-high
    input  wire tick,  // 1-cycle per-second pulse
    output reg  ns_g, ns_y, ns_r,
    output reg  ew_g, ew_y, ew_r
);

    // States
    localparam S_NS_G = 2'b00;
    localparam S_NS_Y = 2'b01;
    localparam S_EW_G = 2'b10;
    localparam S_EW_Y = 2'b11;

    reg [1:0] state, next_state;
    reg [2:0] tick_count; // counts up to 5

    // State register
    always @(posedge clk) begin
        if (rst) begin
            state <= S_NS_G;
            tick_count <= 0;
        end else begin
            state <= next_state;
        end
    end

    // Tick counter and next state logic
    always @(posedge clk) begin
        if (rst) begin
            tick_count <= 0;
        end else if (tick) begin
            case (state)
                S_NS_G: tick_count <= (tick_count == 4) ? 0 : tick_count + 1; // 5 ticks
                S_NS_Y: tick_count <= (tick_count == 1) ? 0 : tick_count + 1; // 2 ticks
                S_EW_G: tick_count <= (tick_count == 4) ? 0 : tick_count + 1; // 5 ticks
                S_EW_Y: tick_count <= (tick_count == 1) ? 0 : tick_count + 1; // 2 ticks
            endcase
        end
    end

    // Next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            S_NS_G: if (tick && tick_count == 4) next_state = S_NS_Y;
            S_NS_Y: if (tick && tick_count == 1) next_state = S_EW_G;
            S_EW_G: if (tick && tick_count == 4) next_state = S_EW_Y;
            S_EW_Y: if (tick && tick_count == 1) next_state = S_NS_G;
        endcase
    end

    // Outputs (Moore machine)
    always @(*) begin
        // default all red
        ns_g = 0; ns_y = 0; ns_r = 0;
        ew_g = 0; ew_y = 0; ew_r = 0;
        case (state)
            S_NS_G: begin ns_g=1; ew_r=1; ns_y=0; ns_r=0; ew_g=0; ew_y=0; end
            S_NS_Y: begin ns_y=1; ew_r=1; ns_g=0; ns_r=0; ew_g=0; ew_y=0; end
            S_EW_G: begin ew_g=1; ns_r=1; ns_g=0; ns_y=0; ew_y=0; ew_r=0; end
            S_EW_Y: begin ew_y=1; ns_r=1; ns_g=0; ns_y=0; ew_g=0; ew_r=0; end
        endcase
    end

endmodule
