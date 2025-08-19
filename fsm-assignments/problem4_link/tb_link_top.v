`timescale 1ns / 1ps

module tb_link_top();

// Testbench registers
reg clk;
reg rst;

// Wire to connect to the 'done' output of the DUT
wire done;

// Instantiate the Design Under Test (DUT)
link_top uut (
    .clk(clk),
    .rst(rst),
    .done(done)
);

// Clock generation: 100 MHz clock (10 ns period)
initial clk = 0;
always #5 clk = ~clk;

// Reset generation: Assert reset for 12 ns at the beginning
initial begin
    rst = 1;
    #12 rst = 0;
end

// Simulation control and monitoring
initial begin
    // Set up waveform dumping
    $dumpfile("dump.vcd");
    // Dump all variables in the testbench and the DUT instance
    $dumpvars(1, tb_link_top);

    // Monitor key signals and print them to the console on change
    $monitor("T=%0t | req=%b ack=%b data=%h last_byte=%h done=%b",
             $time, uut.mas.req, uut.sla.ack, uut.mas.data, uut.sla.last_byte, done);

    // Stop the simulation after 1000 ns
    #1000 $finish;
end

endmodule
