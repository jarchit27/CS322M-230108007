# RVX10 Instruction Encoding

This document shows the decoding of machine code for RVX10 instructions using the R-type instruction format:

Instruction format (R-type style used by RVX10)

  31   25  24 20 19 15 14 12  11 7  6    0
 +------------+-------+-------+------+-------+----------+
 | funct7 | rs2 | rs1 |funct3| rd | opcode |            |
 +------------+-------+-------+------+-------+----------+
 
Machine code is interpreted as:

inst = (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

All RVX10 instructions use `opcode = 0x0B`.

## Instruction Set

![alt text](image.png)

## Encoding Table

![alt text](image-1.png)