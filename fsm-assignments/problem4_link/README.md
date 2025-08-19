# CS322M FSM Assignments - Problem 4: Master-Slave Handshake

This task implements a digital communication link between two Finite State Machines (FSMs), a **Master** and a **Slave**, using a 4-phase `req`/`ack` handshake protocol.

## Description

The goal is to transfer a burst of four 8-bit data bytes from the Master FSM to the Slave FSM.

-   **Master FSM (`master_fsm.v`):** Initiates the transfer. It places a data byte on the bus, raises the `req` signal, and waits for the `ack` signal from the slave. Once `ack` is detected, it drops `req` and waits for `ack` to be dropped before starting the next byte transfer. After four bytes are successfully sent, it asserts a `done` signal for one clock cycle.
-   **Slave FSM (`slave_fsm.v`):** Listens for the `req` signal. When `req` goes high, it latches the data from the bus and asserts the `ack` signal for exactly two clock cycles. It then waits for `req` to go low before de-asserting `ack`, completing the handshake.
-   **Top Module (`link_top.v`):** Instantiates and connects the master and slave FSMs.
-   **Testbench (`tb_link_top.v`):** Provides the clock and reset signals to test the entire system and generates a waveform file (`dump.vcd`) for analysis.

## Files in this Directory

-   `master_fsm.v`: The master FSM module.
-   `slave_fsm.v`: The slave FSM module.
-   `link_top.v`: The top-level wrapper connecting the master and slave.
-   `tb_link_top.v`: The testbench for simulation.

## How to Compile and Run (Icarus Verilog)

1.  **Compile the Verilog source files:**
    ```sh
    iverilog -o sim_out tb_link_top.v link_top.v master_fsm.v slave_fsm.v
    ```

2.  **Run the simulation:**
    ```sh
    vvp sim_out
    ```

3.  **View the waveforms:**
    ```sh
    gtkwave dump.vcd
    ```

## Expected Behavior

When you run the simulation, the console will display the state of the key signals at each time step. The master will send four bytes, starting with `A0` and incrementing to `A3`. The `last_byte` signal from the slave should show each of these values being latched sequentially. The simulation will run for 1000 ns, and the `done` signal will pulse high once the fourth byte's handshake is complete.

In the waveform viewer (GTKWave), you should observe four distinct handshake sequences. For each sequence, you will see `req` go high, followed by `ack` going high for two clock cycles, then `req` going low, and finally `ack` going low.
