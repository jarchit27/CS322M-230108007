# Problem 3: Mealy Vending Machine

This task implements a Mealy FSM for a vending machine that accepts 5 and 10-cent coins for a 20-cent item and provides change if necessary.

## 1. State Diagram

The FSM uses four states to represent the total amount of money deposited so far. The outputs (`dispense`, `chg5`) depend on the current state and the coin input. Transitions are labeled `coin_input / {dispense, chg5}`.

* **States:**
    * `S_0`: 0 cents deposited.
    * `S_5`: 5 cents deposited.
    * `S_10`: 10 cents deposited.
    * `S_15`: 15 cents deposited.

### Justification for Mealy Machine

A Mealy machine is a good choice here because the outputs (`dispense`, `chg5`) need to react **immediately** to the final coin insertion.

- If we were in state `S_15` (15 cents) and a 10-cent coin is inserted, the machine needs to assert `dispense` and `chg5` in that *same clock cycle*.
- A Moore machine's output only depends on the state. To achieve the same result, we would need extra "vend" states, making the FSM more complex. The Mealy design is more efficient, directly mapping the input that completes the transaction to the required output.

## 2. Simulation and Expected Behavior

The testbench simulates three scenarios:

1.  **Insert 10, then 10:** At the moment the second 10-cent coin is inserted, `dispense` should pulse high for one cycle.
2.  **Insert 10, then 5, then 10:** At the moment the final 10-cent coin is inserted (total reaches 25), both `dispense` and `chg5` should pulse high for one cycle.
3.  **Insert 5, then 5, then 10:** At the moment the 10-cent coin is inserted (total reaches 20), `dispense` should pulse high for one cycle.

In all cases, after a dispense, the FSM should return to the `S_0` state.

## 3. How to Run Simulation

```sh
# Compile the Verilog files
iverilog -o sim_vending.out tb_vending_mealy.v vending_mealy.v

# Run the simulation executable
vvp sim_vending.out

# Open the generated waveform dump file
gtkwave tb_vending_mealy.vcd