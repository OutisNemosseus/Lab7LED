// Testbench for complete WS2812 Fade System
// Tests: ws2812_fade_top.sv (and all sub-modules)
// Verifies complete color cycling through all 5 colors

`timescale 1ns / 1ps

module tb_ws2812_fade_top;

    // Timing parameters
    localparam CLK_PERIOD = 20;  // 50 MHz = 20ns period
    localparam CYCLES_PER_FRAME_FAST = 2000;  // Fast simulation

    // Signals
    logic clk;
    logic reset_n;
    logic ws2812_out;

    // Expected color sequence
    logic [23:0] expected_colors [0:4] = '{
        24'hFF_FF_FF,  // 0: White
        24'h00_00_FF,  // 1: Red
        24'h00_00_00,  // 2: Off
        24'hFF_00_00,  // 3: Green
        24'hFF_FF_00   // 4: Teal
    };

    string color_names [0:4] = '{
        "White",
        "Red",
        "Off",
        "Green",
        "Teal"
    };

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Instantiate DUT
    ws2812_fade_top dut (
        .clk(clk),
        .reset_n(reset_n),
        .ws2812_out(ws2812_out)
    );

    // Override timing for faster simulation
    defparam dut.u_fading_controller.CYCLES_PER_FRAME = CYCLES_PER_FRAME_FAST;

    // Test procedure
    initial begin
        $display("=== WS2812 Fade Top-Level Testbench ===");
        $display("This test shows ONE FULL BLENDING CYCLE through all 5 colors");
        $display("Using fast timing: %0d cycles per frame\n", CYCLES_PER_FRAME_FAST);
        $display("Time(us)\tColor#\tColor Name\tTarget Color\tCurrent Color\tStatus");

        // Initialize
        reset_n = 0;
        #200;
        reset_n = 1;
        #200;

        // Monitor all 5 color transitions
        for (int i = 0; i < 5; i++) begin
            // Wait for transition to start (color address changes)
            wait(dut.color_addr == i[2:0]);
            $display("%0t\t%0d\t%-8s\t%h\t%h\tStarting",
                     $time/1000, i, color_names[i],
                     dut.target_color, dut.current_color);

            // Wait for transition to complete
            wait(dut.transition_done);
            $display("%0t\t%0d\t%-8s\t%h\t%h\tComplete",
                     $time/1000, i, color_names[i],
                     dut.target_color, dut.current_color);

            // Verify we reached the target color (approximately)
            // Allow small error due to integer division in interpolation
            logic [7:0] r_diff, g_diff, b_diff;
            r_diff = (dut.current_color[23:16] > expected_colors[i][23:16]) ?
                     (dut.current_color[23:16] - expected_colors[i][23:16]) :
                     (expected_colors[i][23:16] - dut.current_color[23:16]);
            g_diff = (dut.current_color[15:8] > expected_colors[i][15:8]) ?
                     (dut.current_color[15:8] - expected_colors[i][15:8]) :
                     (expected_colors[i][15:8] - dut.current_color[15:8]);
            b_diff = (dut.current_color[7:0] > expected_colors[i][7:0]) ?
                     (dut.current_color[7:0] - expected_colors[i][7:0]) :
                     (expected_colors[i][7:0] - dut.current_color[7:0]);

            if (r_diff <= 2 && g_diff <= 2 && b_diff <= 2) begin
                $display("\t\t\t\t\t\t\t\tPASS: Reached %s", color_names[i]);
            end else begin
                $display("\t\t\t\t\t\t\t\tWARN: Color deviation for %s", color_names[i]);
                $display("\t\t\t\t\t\t\t\t      Expected: %h, Got: %h",
                         expected_colors[i], dut.current_color);
            end

            // Small delay before next color
            #500;
        end

        // Wait for wrap-around back to first color
        $display("\n--- Testing Wrap-Around ---");
        wait(dut.color_addr == 3'd0 && dut.transition_done);
        $display("%0t\tWrapped back to color 0 (White)", $time/1000);

        $display("\n=== ONE FULL BLENDING CYCLE COMPLETE ===");
        $display("Total simulation time: %0t us\n", $time/1000);
        $finish;
    end

    // Timeout watchdog
    initial begin
        #500ms;  // 500 milliseconds timeout
        $display("ERROR: Simulation timeout!");
        $finish;
    end

    // Monitor WS2812 output activity
    int ws2812_toggles = 0;
    logic last_ws2812 = 0;

    always @(posedge clk) begin
        if (ws2812_out != last_ws2812) begin
            ws2812_toggles++;
            last_ws2812 = ws2812_out;
        end
    end

    // Report WS2812 activity at end
    final begin
        $display("WS2812 output toggles: %0d", ws2812_toggles);
        if (ws2812_toggles > 100) begin
            $display("PASS: WS2812 driver is actively sending data");
        end else begin
            $display("WARN: Low WS2812 activity");
        end
    end

endmodule
