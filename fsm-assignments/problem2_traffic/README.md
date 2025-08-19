# Traffic Light Controller FSM

## Overview

This task is a Moore FSM in Verilog that controls a two-road (NS/EW) traffic light. It uses a 1 Hz `tick` signal to cycle through four states with specific durations:

- **NS Green:** 5 ticks
- **NS Yellow:** 2 ticks
- **EW Green:** 5 ticks
- **EW Yellow:** 2 ticks

The main files are `traffic_light.v` (the FSM) and `tb_traffic_light.v` (the testbench).

## 3. How to Run Simulation

To compile and run the simulation using Icarus Verilog and view the waveform with GTKWave, use the following commands:

```sh
# Compile the Verilog files
iverilog -o sim.out tb_traffic_light.v traffic_light.v

# Run the simulation executable
vvp sim.out

# Open the generated waveform dump file
gtkwave dump.vcd