# riscvtest.s

# Test the RISC-V processor.  
# If successful, it should write the value 25 to address 100

#       RISC-V Assembly         Description               Address   Machine Code
main:   addi x2, x0, 5          # x2 = 5                  0         00500113
        addi x3, x0, 12         # x3 = 12                 4         00C00193
        addi x7, x3, -9         # x7 = (12 - 9) = 3       8         FF718393
        or   x4, x7, x2         # x4 = (3 OR 5) = 7       C         0023E233
        and  x5, x3, x4         # x5 = (12 AND 7) = 4     10        0041F2B3
        add  x5, x5, x4         # x5 = (4 + 7) = 11       14        004282B3
        beq  x5, x7, end        # shouldn't be taken      18        02728863
        slt  x4, x3, x4         # x4 = (12 < 7) = 0       1C        0041A233
        beq  x4, x0, around     # should be taken         20        00020463
        addi x5, x0, 0          # shouldn't happen        24        00000293
around: slt  x4, x7, x2         # x4 = (3 < 5)  = 1       28        0023A233
        add  x7, x4, x5         # x7 = (1 + 11) = 12      2C        005203B3
        sub  x7, x7, x2         # x7 = (12 - 5) = 7       30        402383B3
        sw   x7, 84(x3)         # [96] = 7                34        0471AA23
        lw   x2, 96(x0)         # x2 = [96] = 7           38        06002103
        add  x9, x2, x5         # x9 = (7 + 11) = 18      3C        005104B3
        jal  x3, end            # jump to end, x3 = 0x44  40        008001EF
        addi x2, x0, 1          # shouldn't happen        44        00100113
end:    add  x2, x2, x9         # x2 = (7 + 18)  = 25     48        00910133
        addi x4, x0, 10         # x4 = 10                 4C        00A00213
        addi x8, x0, 20         # x8 = 20                 50        01400413
        addi x6, x0, -20        # x6 = -20                54        FEC00313
        andn x7, x4, x8         # x7 = (10 &(~20)) = 10   58        0082038B
        orn x7, x4, x8          # x7 = (10 &(~20)) = -21  5C        0082138B
        xnor x7, x4, x8         # x7 = (10 &(~20)) = -31  60        0082238B
        min x7 , x4,x6          # x7 = min(10,-20) = -20  64        0262038B
        max x7 , x4,x6          # x7 = max(10,-20) = 10   68        0262138B
        minu x7 , x4,x6         # x7 = minu(10,-20) = 10  6C        0262238B
        maxu x7 , x4,x6         # x7 = maxu(10,-20)= -20  70        0262338B
        abs x7, x7, x0          # x7 = abs(-20) = 20      74        0603838B
        addi x1, x0, -128       # x1 = -128               78        F8000093
        abs x1 , x1,x0          # x1 = 128                7C        0600808B
        abs x7 , x0,x0          # x7 = 0                  80        0600038B
        addi x0, x0, 10         # x0 = 0                  84        00A00013
        addi x4, x0, 3          # x4 = 3                  88        00300213
        addi x6, x0, 16         # x6 = 16                 8C        01000313
        rol x1 ,x6,x4           # x1 = (16<<3) = 128      90        0443008B       
        ror x1 ,x6,x4           # x1 = (16>>3) = 2        94        0443108B   
        ror x1, x6,x0           # x1 = (16>>0) = 16       98        0403108B
        addi x4, x0, 31         # x4 = 31                 9C        01F00213
        addi x6,x0,31           # x6 = 1                  A0        00100313
        rol x1 , x6,x4          # x1 = 0x80000000         A4        0443008B
        addi x1,x1,1            # x1 = 0x80000001         A8        00108093
        addi x4, x0, 3          # x4 = 3                  AC        00300213
        rol x1 ,x1,x4           # x1 = 0x0000000C         B0        0443008B
        sw   x2, 0x20(x3)       # mem[100] = 25           B4        0221A023
done:   beq  x2, x2, done       # infinite loop           B8        00210063 