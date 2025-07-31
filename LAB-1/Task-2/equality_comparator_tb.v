`timescale 1ns/1ns
`include "equality_comparator.v"

module tb();

  reg [3:0]A ,B;
  wire eq;

  four_bit_equality_comparator dut(.a(A),.b(B), .eq(eq));

  initial begin

    $dumpfile("equality_comparator_tb_vcd.vcd");
    $dumpvars(0, tb);

    A = 4'd15; B = 4'd15;
    #10;
    A = 4'd0; B = 4'd1;
    #10;
    A = 4'd1; B = 4'd13;
    #10;
    A = 4'd1; B = 4'd1;
    #10;
    A = 4'd1; B = 4'd7;
    #10;

    $display("Test is completed...");

  end

endmodule