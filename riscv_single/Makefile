# Simple Makefile for RISC-V single-cycle simulation (Icarus Verilog)

IVFLAGS = -g2012
TOP     = riscvsingle.sv
OUT     = cpu_tb
VCD     = wave.vcd

.PHONY: all run waves clean

all: $(OUT)

$(OUT): $(TOP)
	iverilog $(IVFLAGS) -o $(OUT) $(TOP)

run: $(OUT)
	vvp $(OUT)

waves: $(OUT)
	vvp $(OUT)
	gtkwave $(VCD) &

clean:
	rm -f $(OUT) $(VCD)
