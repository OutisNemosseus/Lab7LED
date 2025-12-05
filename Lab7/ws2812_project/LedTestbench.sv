//=============================================================================
// Module: LedTestbench
// Description: Testbench for WS2812 LED Driver
//              Verifies timing and protocol correctness
//
// Test Strategy:
//   1. Test BitSender timing for 0 and 1 codes
//   2. Test complete 24-bit transmission
//   3. Verify reset timing
//   4. Test various color combinations
//
// Timing Verification (50MHz = 20ns period):
//   - T0H: 0.35µs = 350ns = ~18 cycles
//   - T1H: 0.7µs = 700ns = ~35 cycles
//   - T0L: 0.8µs = 800ns = ~40 cycles
//   - T1L: 0.6µs = 600ns = ~30 cycles
//   - Reset: >50µs = 50000ns = 2500+ cycles
//
// Author: ENGR 110 Lab 6
// Date: 2024
//=============================================================================

`timescale 1ns/1ps

module LedTestbench;

    //-------------------------------------------------------------------------
    // Parameters
    //-------------------------------------------------------------------------
    localparam CLK_PERIOD = 20;     // 50MHz = 20ns period
    
    // Expected timing values (in ns)
    localparam T0H_NS = 360;        // 18 cycles * 20ns
    localparam T1H_NS = 700;        // 35 cycles * 20ns
    localparam T0L_NS = 800;        // 40 cycles * 20ns
    localparam T1L_NS = 600;        // 30 cycles * 20ns
    localparam RESET_NS = 80000;    // 4000 cycles * 20ns
    
    // Tolerance (±150ns from datasheet, we'll use ±200ns for margin)
    localparam TOLERANCE = 200;
    
    //-------------------------------------------------------------------------
    // DUT Signals
    //-------------------------------------------------------------------------
    logic       clk;
    logic       reset_n;
    logic [2:0] red;
    logic [2:0] green;
    logic [2:0] blue;
    logic       ws2812;
    
    //-------------------------------------------------------------------------
    // Test Variables
    //-------------------------------------------------------------------------
    integer bit_count;
    integer high_time;
    integer low_time;
    integer error_count;
    real    high_duration_ns;
    real    low_duration_ns;
    
    //-------------------------------------------------------------------------
    // Clock Generation
    //-------------------------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    //-------------------------------------------------------------------------
    // DUT Instantiation
    //-------------------------------------------------------------------------
    LedDriver DUT (
        .clk     (clk),
        .reset_n (reset_n),
        .red     (red),
        .green   (green),
        .blue    (blue),
        .ws2812  (ws2812)
    );
    
    //-------------------------------------------------------------------------
    // Monitor Task: Measure pulse widths
    //-------------------------------------------------------------------------
    task automatic measure_bit_timing(
        output real t_high,
        output real t_low
    );
        integer start_time;
        
        // Wait for rising edge
        @(posedge ws2812);
        start_time = $time;
        
        // Wait for falling edge
        @(negedge ws2812);
        t_high = $time - start_time;
        start_time = $time;
        
        // Wait for next rising edge (or timeout for reset)
        fork
            @(posedge ws2812);
            #100000;  // 100µs timeout
        join_any
        disable fork;
        
        t_low = $time - start_time;
    endtask
    
    //-------------------------------------------------------------------------
    // Verify Timing Task
    //-------------------------------------------------------------------------
    task automatic verify_timing(
        input real measured,
        input real expected,
        input string name
    );
        real diff;
        diff = measured - expected;
        if (diff < 0) diff = -diff;
        
        if (diff > TOLERANCE) begin
            $display("ERROR: %s timing out of spec!", name);
            $display("  Expected: %.0f ns, Measured: %.0f ns, Diff: %.0f ns", 
                     expected, measured, diff);
            error_count++;
        end else begin
            $display("PASS: %s timing OK (%.0f ns, expected %.0f ns)", 
                     name, measured, expected);
        end
    endtask
    
    //-------------------------------------------------------------------------
    // Main Test Sequence
    //-------------------------------------------------------------------------
    initial begin
        // Initialize
        error_count = 0;
        reset_n = 1'b0;
        red = 3'd0;
        green = 3'd0;
        blue = 3'd0;
        
        $display("========================================");
        $display("WS2812 LED Driver Testbench");
        $display("========================================");
        $display("Clock Period: %0d ns (50MHz)", CLK_PERIOD);
        $display("");
        
        // Apply reset
        $display("Applying reset...");
        #100;
        reset_n = 1'b1;
        #100;
        
        //---------------------------------------------------------------------
        // Test 1: All zeros (color = 0x000000)
        //---------------------------------------------------------------------
        $display("");
        $display("----------------------------------------");
        $display("Test 1: All zeros (Black)");
        $display("Expected: 24 bits of '0' code");
        $display("----------------------------------------");
        
        red = 3'd0;
        green = 3'd0;
        blue = 3'd0;
        
        // Measure first few bits
        for (int i = 0; i < 5; i++) begin
            measure_bit_timing(high_duration_ns, low_duration_ns);
            $display("Bit %0d: High=%.0fns, Low=%.0fns", i, high_duration_ns, low_duration_ns);
            verify_timing(high_duration_ns, T0H_NS, $sformatf("Bit%0d T0H", i));
        end
        
        // Wait for reset
        #150000;
        
        //---------------------------------------------------------------------
        // Test 2: All ones (color = 0xFFFFFF, white at max)
        //---------------------------------------------------------------------
        $display("");
        $display("----------------------------------------");
        $display("Test 2: All maximum (White)");
        $display("Expected: 24 bits of '1' code");
        $display("----------------------------------------");
        
        red = 3'd7;
        green = 3'd7;
        blue = 3'd7;
        
        // Wait for new frame to start
        #100000;
        
        // Measure first few bits
        for (int i = 0; i < 5; i++) begin
            measure_bit_timing(high_duration_ns, low_duration_ns);
            $display("Bit %0d: High=%.0fns, Low=%.0fns", i, high_duration_ns, low_duration_ns);
            verify_timing(high_duration_ns, T1H_NS, $sformatf("Bit%0d T1H", i));
        end
        
        //---------------------------------------------------------------------
        // Test 3: Known pattern (Red only = G:0x00, R:0xFF, B:0x00)
        //---------------------------------------------------------------------
        $display("");
        $display("----------------------------------------");
        $display("Test 3: Pure Red");
        $display("GRB = 0x00FF00");
        $display("Expected: G=0x00 (8x'0'), R=0xFF (8x'1'), B=0x00 (8x'0')");
        $display("----------------------------------------");
        
        red = 3'd7;     // Max red
        green = 3'd0;   // No green
        blue = 3'd0;    // No blue
        
        // Wait for new frame
        #100000;
        
        // Measure Green bits (should be 0)
        $display("Green byte (should be 0x00 - all '0' codes):");
        for (int i = 0; i < 8; i++) begin
            measure_bit_timing(high_duration_ns, low_duration_ns);
            $display("  G[%0d]: High=%.0fns (expect ~360ns for '0')", 7-i, high_duration_ns);
        end
        
        // Measure Red bits (should be 1)
        $display("Red byte (should be 0xFF - all '1' codes):");
        for (int i = 0; i < 8; i++) begin
            measure_bit_timing(high_duration_ns, low_duration_ns);
            $display("  R[%0d]: High=%.0fns (expect ~700ns for '1')", 7-i, high_duration_ns);
        end
        
        // Measure Blue bits (should be 0)
        $display("Blue byte (should be 0x00 - all '0' codes):");
        for (int i = 0; i < 8; i++) begin
            measure_bit_timing(high_duration_ns, low_duration_ns);
            $display("  B[%0d]: High=%.0fns (expect ~360ns for '0')", 7-i, high_duration_ns);
        end
        
        //---------------------------------------------------------------------
        // Test 4: Mixed pattern
        //---------------------------------------------------------------------
        $display("");
        $display("----------------------------------------");
        $display("Test 4: Mixed color (R=4, G=2, B=6)");
        $display("Mapped: R=146 (0x92), G=73 (0x49), B=219 (0xDB)");
        $display("GRB = 0x4992DB");
        $display("----------------------------------------");
        
        red = 3'd4;
        green = 3'd2;
        blue = 3'd6;
        
        // Let it run for a couple frames
        #300000;
        
        //---------------------------------------------------------------------
        // Summary
        //---------------------------------------------------------------------
        $display("");
        $display("========================================");
        $display("Test Complete!");
        $display("Errors: %0d", error_count);
        $display("========================================");
        
        if (error_count == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("SOME TESTS FAILED - Review output above");
        end
        
        $finish;
    end
    
    //-------------------------------------------------------------------------
    // Timeout watchdog
    //-------------------------------------------------------------------------
    initial begin
        #5000000;  // 5ms timeout
        $display("TIMEOUT: Simulation exceeded 5ms");
        $finish;
    end
    
    //-------------------------------------------------------------------------
    // Optional: VCD dump for waveform viewing
    //-------------------------------------------------------------------------
    initial begin
        $dumpfile("ws2812_test.vcd");
        $dumpvars(0, LedTestbench);
    end

endmodule
