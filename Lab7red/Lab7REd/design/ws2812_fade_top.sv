// Top-level module for WS2812 Fading LED Controller
// Integrates color memory, fading controller, and WS2812 driver
// Cycles through 5 colors with smooth 3-second transitions

module ws2812_fade_top (
    input  logic clk,        // 50MHz clock (connect to PIN_P11)
    input  logic reset_n,    // Active low reset (connect to button)
    output logic ws2812_out  // WS2812 data output (connect to PIN_AB7)
);

    // Color sequencer signals
    logic [2:0] color_addr;
    logic [23:0] target_color;
    logic [23:0] current_color;
    logic transition_done;

    // Color address sequencer - cycles through 0-4
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            color_addr <= 3'd0;
        end else begin
            if (transition_done) begin
                if (color_addr >= 3'd4)
                    color_addr <= 3'd0;  // Wrap back to first color
                else
                    color_addr <= color_addr + 1;
            end
        end
    end

    // Instantiate color memory
    color_memory u_color_memory (
        .addr(color_addr),
        .data_out(target_color)
    );

    // Instantiate fading controller
    fading_controller u_fading_controller (
        .clk(clk),
        .reset_n(reset_n),
        .target_color(target_color),
        .current_color(current_color),
        .transition_done(transition_done)
    );

    // Instantiate WS2812 driver
    ws2812_driver_rgb u_ws2812_driver (
        .clk(clk),
        .reset_n(reset_n),
        .rgb_color(current_color),
        .ws2812_data(ws2812_out)
    );

endmodule
