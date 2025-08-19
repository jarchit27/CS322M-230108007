// - Generates a clock and reset signal.
// - Simulates a sequence of coin insertions to test different scenarios:
//   1. Exact change (10 + 10)
//   2. Overpayment with change (10 + 5 + 10)
//   3. Another exact change case (5 + 5 + 10)

`timescale 1ns / 1ps

module tb_vending_mealy;

    // Testbench Signals
    reg clk;
    reg rst;
    reg [1:0] coin;
    wire dispense;
    wire chg5;

    // Coin definitions for clarity
    localparam C_NONE = 2'b00;
    localparam C_5    = 2'b01;
    localparam C_10   = 2'b10;

    // Instantiate the DUT
    vending_mealy dut (
        .clk(clk),
        .rst(rst),
        .coin(coin),
        .dispense(dispense),
        .chg5(chg5)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Test Sequence
    initial begin
        // 1. Initialize and reset
        $display("T=%0t: Starting simulation. Applying reset.", $time);
        rst = 1;
        coin = C_NONE;
        #20;
        rst = 0;
        $display("T=%0t: Reset released.", $time);
        #10;

        // Scenario 1: 10 + 10 = 20 (Dispense)
        $display("T=%0t: Scenario 1: Inserting 10 + 10", $time);
        insert_coin(C_10);
        insert_coin(C_10); // Should dispense here
        #20;

        // Scenario 2: 10 + 5 + 10 = 25 (Dispense + Change)
        $display("T=%0t: Scenario 2: Inserting 10 + 5 + 10", $time);
        insert_coin(C_10);
        insert_coin(C_5);
        insert_coin(C_10); // Should dispense and give change here
        #20;

        // Scenario 3: 5 + 5 + 10 = 20 (Dispense)
        $display("T=%0t: Scenario 3: Inserting 5 + 5 + 10", $time);
        insert_coin(C_5);
        insert_coin(C_5);
        insert_coin(C_10); // Should dispense here
        #20;

        $display("T=%0t: Simulation finished.", $time);
        $finish;
    end

    // Task to simulate inserting a coin for one cycle
    task insert_coin;
        input [1:0] coin_val;
        begin
            @(posedge clk);
            coin = coin_val;
            $display("T=%0t: Inserting coin %d. Total was %d.", $time, (coin_val==C_5)?5:10, get_total(dut.current_state));
            @(posedge clk);
            coin = C_NONE;
        end
    endtask

    // Helper function to get total from state
    function integer get_total;
        input [1:0] state;
        case(state)
            2'b00: get_total = 0;
            2'b01: get_total = 5;
            2'b10: get_total = 10;
            2'b11: get_total = 15;
            default: get_total = -1;
        endcase
    endfunction

    initial begin
        $dumpfile("tb_vending_mealy.vcd");
        $dumpvars(0, tb_vending_mealy);
    end

endmodule
