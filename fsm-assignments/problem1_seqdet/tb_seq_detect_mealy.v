// - Generates a 100 MHz clock.
// - Applies a synchronous active-high reset.
// - Drives a test bitstream: 11011011101

`timescale 1ns / 1ps

module tb_seq_detect_mealy;

    // Testbench Signals
    reg clk;
    reg rst;
    reg din;
    wire y;

    // Test vector containing the input bitstream
    reg [10:0] test_vector = 11'b11011011101;
    integer i;

    // Instantiate the DUT
    seq_detect_mealy dut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .y(y)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock (10 ns period)
    end

    // Test Sequence
    initial begin
        // 1. Initialize and apply reset
        $display("T=%0t: Starting simulation. Applying reset.", $time);
        rst = 1;
        din = 0;
        #20; // Hold reset for a couple of clock cycles
        rst = 0;
        $display("T=%0t: Reset released. Driving bitstream.", $time);

        // 2. Drive the test vector bit by bit
        for (i = 10; i >= 0; i = i - 1) begin
            @(posedge clk);
            din = test_vector[i];
            // Display the state as a 2-bit binary value instead of a string
            $display("T=%0t: din = %b, y = %b, state = %b", $time, din, y, dut.current_state);
        end

        // 3. Add a few extra cycles to see the final state
        @(posedge clk);
        din = 0;
        $display("T=%0t: din = %b, y = %b, state = %b", $time, din, y, dut.current_state);
        @(posedge clk);
        $display("T=%0t: din = %b, y = %b, state = %b", $time, din, y, dut.current_state);


        // 4. Finish simulation
        $display("T=%0t: Simulation finished.", $time);
        $finish;
    end

    initial begin
        $dumpfile("tb_seq_detect_mealy.vcd");
        $dumpvars(0, tb_seq_detect_mealy);
    end

endmodule