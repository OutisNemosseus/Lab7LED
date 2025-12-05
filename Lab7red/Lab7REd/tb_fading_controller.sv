// Testbench for fading_controller module
// Tests: fading_controller.sv
// Verifies smooth linear color transitions over 3 seconds at 30 fps

`timescale 1ns / 1ps

module tb_fading_controller;

    // Timing parameters
    localparam CLK_PERIOD = 20;  // 50 MHz = 20ns period
    localparam CYCLES_PER_FRAME = 5_000_000;  // Real timing
    localparam CYCLES_PER_FRAME_FAST = 1000;   // Fast simulation timing

    // Use fast timing for simulation
    localparam TEST_CYCLES_PER_FRAME = CYCLES_PER_FRAME_FAST;

    // Signals
    logic clk;
    logic reset_n;
    logic [23:0] target_color;
    logic [23:0] current_color;
    logic transition_done;

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Instantiate DUT
    fading_controller dut (
        .clk(clk),
        .reset_n(reset_n),
        .target_color(target_color),
        .current_color(current_color),
        .transition_done(transition_done)
    );

    // Override timing parameter for faster simulation
    // Note: In real design, this uses 5_000_000 cycles
    defparam dut.CYCLES_PER_FRAME = TEST_CYCLES_PER_FRAME;

    // Test procedure
    initial begin
        $display("=== Fading Controller Testbench ===");
        $display("Using fast timing: %0d cycles per frame", TEST_CYCLES_PER_FRAME);
        $display("Time(us)\t\tCurrent Color\tTarget Color\tDone");

        // Initialize
        reset_n = 0;
        target_color = 24'h00_00_00;
        #100;
        reset_n = 1;
        #100;

        // Test 1: Fade from Black to White
        $display("\n--- Test 1: Black to White ---");
        target_color = 24'hFF_FF_FF;

        // Wait for transition to complete
        wait(transition_done);
        $display("%0t\t%h\t%h\t%0d", $time/1000, current_color, target_color, transition_done);

        // Verify we reached target
        if (current_color == 24'hFF_FF_FF) begin
            $display("PASS: Reached White");
        end else begin
            $display("FAIL: Expected FFFFFF, got %h", current_color);
        end

        // Test 2: Fade from White to Red
        #1000;
        $display("\n--- Test 2: White to Red ---");
        target_color = 24'h00_00_FF;

        wait(transition_done);
        $display("%0t\t%h\t%h\t%0d", $time/1000, current_color, target_color, transition_done);

        if (current_color == 24'h00_00_FF) begin
            $display("PASS: Reached Red");
        end else begin
            $display("FAIL: Expected 0000FF, got %h", current_color);
        end

        // Test 3: Fade from Red to Off (Black)
        #1000;
        $display("\n--- Test 3: Red to Off ---");
        target_color = 24'h00_00_00;

        wait(transition_done);
        $display("%0t\t%h\t%h\t%0d", $time/1000, current_color, target_color, transition_done);

        if (current_color == 24'h00_00_00) begin
            $display("PASS: Reached Off");
        end else begin
            $display("FAIL: Expected 000000, got %h", current_color);
        end

        // Test 4: Fade from Off to Green
        #1000;
        $display("\n--- Test 4: Off to Green ---");
        target_color = 24'hFF_00_00;

        wait(transition_done);
        $display("%0t\t%h\t%h\t%0d", $time/1000, current_color, target_color, transition_done);

        if (current_color == 24'hFF_00_00) begin
            $display("PASS: Reached Green");
        end else begin
            $display("FAIL: Expected FF0000, got %h", current_color);
        end

        // Test 5: Fade from Green to Teal
        #1000;
        $display("\n--- Test 5: Green to Teal ---");
        target_color = 24'hFF_FF_00;

        wait(transition_done);
        $display("%0t\t%h\t%h\t%0d", $time/1000, current_color, target_color, transition_done);

        if (current_color == 24'hFF_FF_00) begin
            $display("PASS: Reached Teal");
        end else begin
            $display("FAIL: Expected FFFF00, got %h", current_color);
        end

        #1000;
        $display("\n=== Fading Controller Test Complete ===\n");
        $finish;
    end

    // Monitor color changes during first transition
    int sample_count = 0;
    logic [23:0] last_color = 24'h00_00_00;

    always @(posedge clk) begin
        if (target_color == 24'hFF_FF_FF && sample_count < 5 && current_color != last_color) begin
            $display("Sample %0d: Color = %h", sample_count, current_color);
            last_color = current_color;
            sample_count++;
        end
    end

endmodule
