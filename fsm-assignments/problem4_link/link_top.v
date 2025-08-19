`timescale 1ns / 1ps

module link_top(
    input clk,
    input rst,
    output done
);

// Internal wires for connecting the two FSMs
wire req;
wire ack;
wire [7:0] data;
wire [7:0] last_byte; // Observable in simulation

// Instantiate the Master FSM
master_fsm mas (
    .clk(clk),
    .rst(rst),
    .ack(ack),
    .req(req),
    .data(data),
    .done(done)
);

// Instantiate the Slave FSM
slave_fsm sla (
    .clk(clk),
    .rst(rst),
    .req(req),
    .data_in(data),
    .ack(ack),
    .last_byte(last_byte)
);

endmodule
