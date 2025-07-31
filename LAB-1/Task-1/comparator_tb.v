`timescale 1ns/1ns
`include "comparator.v"

module tb();

  reg A ,B;
  wire o1, o2, o3;

  one_bit_comparator dut(.a(A),.b(B), .o1(o1),.o2(o2),.o3(o3));

  initial begin

    $dumpfile("comparator_tb_vcd.vcd");
    $dumpvars(0, tb);

    A = 1'b0; B = 1'b0;
    #10;

    A = 1'b0; B = 1'b1;
    #10;


    A = 1'b1; B = 1'b0;
    #10;

    A = 1'b1; B = 1'b1;
    #10;
    $display("Test is completed...");

  end

endmodule