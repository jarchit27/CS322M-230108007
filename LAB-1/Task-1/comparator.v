module one_bit_comparator(
  input a,b,
  output o1, // o1 = 1 when a > b 
  output o2, // o2 = 1 when a = b
  output o3 //  o3 = 1 when a < b
);

  assign o1 = a & (~b);
  assign o2 = ~(a^b); 
  assign o3 = (~a) & b;
    
endmodule