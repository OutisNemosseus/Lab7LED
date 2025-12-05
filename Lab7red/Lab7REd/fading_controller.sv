// Fading Controller Module
// Smoothly transitions between colors over ~3 seconds
// Updates at 30 fps for smooth animation (30 frames per transition)

module fading_controller (
    input  logic clk,           // 50 MHz clock
    input  logic reset_n,       // Active low reset
    input  logic [23:0] target_color,  // Target color in RGB format
    output logic [23:0] current_color, // Current color output (interpolated)
    output logic transition_done       // Pulses high when transition completes
);

    // Timing parameters
    // 3 seconds at 50 MHz = 150,000,000 cycles
    // 30 frames per transition = 5,000,000 cycles per frame
    localparam CYCLES_PER_FRAME = 5_000_000;
    localparam NUM_FRAMES = 30;

    // Counters
    logic [22:0] cycle_counter;      // Counts cycles within a frame
    logic [4:0]  frame_counter;      // Counts frames (0-29)

    // Color storage
    logic [23:0] start_color;        // Starting color for transition
    logic [23:0] target_color_reg;   // Registered target color

    // Color channel extraction
    logic [7:0] start_r, start_g, start_b;
    logic [7:0] target_r, target_g, target_b;
    logic [7:0] current_r, current_g, current_b;

    // Signed differences for interpolation
    logic signed [8:0] delta_r, delta_g, delta_b;

    // Interpolation calculations (scaled by frame_counter)
    logic signed [16:0] interp_r, interp_g, interp_b;

    // Extract color channels
    assign start_r = start_color[23:16];
    assign start_g = start_color[15:8];
    assign start_b = start_color[7:0];

    assign target_r = target_color_reg[23:16];
    assign target_g = target_color_reg[15:8];
    assign target_b = target_color_reg[7:0];

    // Calculate signed deltas
    assign delta_r = $signed({1'b0, target_r}) - $signed({1'b0, start_r});
    assign delta_g = $signed({1'b0, target_g}) - $signed({1'b0, start_g});
    assign delta_b = $signed({1'b0, target_b}) - $signed({1'b0, start_b});

    // Linear interpolation: current = start + (delta * frame_counter) / NUM_FRAMES
    assign interp_r = $signed({1'b0, start_r}) + ((delta_r * $signed({1'b0, frame_counter})) / NUM_FRAMES);
    assign interp_g = $signed({1'b0, start_g}) + ((delta_g * $signed({1'b0, frame_counter})) / NUM_FRAMES);
    assign interp_b = $signed({1'b0, start_b}) + ((delta_b * $signed({1'b0, frame_counter})) / NUM_FRAMES);

    // Clamp to 8-bit unsigned range
    assign current_r = (interp_r < 0) ? 8'd0 : (interp_r > 255) ? 8'd255 : interp_r[7:0];
    assign current_g = (interp_g < 0) ? 8'd0 : (interp_g > 255) ? 8'd255 : interp_g[7:0];
    assign current_b = (interp_b < 0) ? 8'd0 : (interp_b > 255) ? 8'd255 : interp_b[7:0];

    // Assemble current color
    assign current_color = {current_r, current_g, current_b};

    // Main state machine
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            cycle_counter <= 0;
            frame_counter <= 0;
            start_color <= 24'h00_00_00;
            target_color_reg <= 24'h00_00_00;
            transition_done <= 0;
        end else begin
            // Default: no transition done pulse
            transition_done <= 0;

            // Detect target color change - start new transition
            if (target_color != target_color_reg) begin
                start_color <= current_color;  // Current becomes new start
                target_color_reg <= target_color;
                frame_counter <= 0;
                cycle_counter <= 0;
            end else begin
                // Count cycles for frame timing
                if (cycle_counter >= CYCLES_PER_FRAME - 1) begin
                    cycle_counter <= 0;

                    // Advance frame counter
                    if (frame_counter >= NUM_FRAMES - 1) begin
                        frame_counter <= NUM_FRAMES - 1;  // Stay at final frame
                        transition_done <= 1;              // Signal completion
                    end else begin
                        frame_counter <= frame_counter + 1;
                    end
                end else begin
                    cycle_counter <= cycle_counter + 1;
                end
            end
        end
    end

endmodule
