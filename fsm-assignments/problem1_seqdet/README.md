# Problem 1: Mealy Sequence Detector "1101"

This task implements a Mealy FSM in Verilog to detect the sequence `1101` from a serial input bitstream, with support for overlapping patterns.

## 1. State Diagram

The FSM is designed with four states to track the progress of the sequence detection. The output `y` is shown on the transition arcs, in the format `input/output`.

* **States:**
    * `S_IDLE`: The initial state, waiting for the first '1'.
    * `S_1`: The sequence has started with a '1'.
    * `S_11`: The sequence "11" has been detected.
    * `S_110`: The sequence "110" has been detected.

**Overlap Handling:** The key transition for overlap is from `S_110`. If the input is `1`, the sequence `1101` is complete, and the output `y` is `1`. The FSM then transitions to `S_1` because this final `1` can be the start of a new `1101` sequence.

## 2. Simulation and Expected Behavior

The testbench (`tb_seq_detect_mealy.v`) drives the input stream `11011011101`.

* **Input Stream:** `1`, `1`, `0`, `1`, `1`, `0`, `1`, `1`, `1`, `0`, `1`
* **Clock Index:** `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `11`

The output `y` is expected to be a 1-cycle pulse at the clock cycles where the last bit of the sequence is detected.

* **First Detection:** `1101` is detected at **clock cycle 4**.
* **Second Detection (Overlapping):** `1101` is detected again at **clock cycle 7**. The `1` at cycle 5 is part of this sequence.
* **Third Detection:** `1101` is detected at **clock cycle 11**.

Therefore, `y` should be high during cycles **4**, **7**, and **11**.

## 3. How to Run Simulation

To compile and run the simulation using Icarus Verilog and view the waveform with GTKWave, use the following commands:

```sh
# Compile the Verilog files
iverilog -o sim_mealy.out tb_seq_detect_mealy.v seq_detect_mealy.v

# Run the simulation executable
vvp sim_mealy.out

# Open the generated waveform dump file
gtkwave tb_seq_detect_mealy.vcd