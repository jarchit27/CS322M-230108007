module four_bit_equality_comparator(
    input [3:0] a,input [3:0] b,
    output eq
);
    
    assign eq = (a == b) ? 1 : 0;

endmodule