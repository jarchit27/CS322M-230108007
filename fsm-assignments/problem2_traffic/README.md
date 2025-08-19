# Traffic Light Controller FSM

## Overview

This task is a Moore FSM in Verilog that controls a two-road (NS/EW) traffic light. It uses a 1 Hz `tick` signal to cycle through four states with specific durations:

- **NS Green:** 5 ticks
- **NS Yellow:** 2 ticks
- **EW Green:** 5 ticks
- **EW Yellow:** 2 ticks

The main files are `traffic_light.v` (the FSM) and `tb_traffic_light.v` (the testbench).

---

## Simulation Instructions

Use a Verilog simulator like Icarus Verilog and a waveform viewer like GTKWave.

### 1. Compile and Run

```shell
iverilog -o sim.out tb_traffic_light.v traffic_light.v
vvp sim.out
```

### 2. Visualize Waveforms

```shell
gtkwave dump.vcd
```

In GTKWave, add the `clk`, `rst`, `tick`, `state`, `tick_count`, and all light output signals (`ns_g`, `ew_r`, etc.) to the wave display to verify the behavior.

---

## Expected Behavior

The waveform should show the FSM correctly cycling through its four states (`S_NS_G` -> `S_NS_Y` -> `S_EW_G` -> `S_EW_Y`). Verify that the duration of each state, measured by the `tick` signal, matches the 5/2/5/2 second timing specification. The corresponding traffic light outputs should be active for each state.
