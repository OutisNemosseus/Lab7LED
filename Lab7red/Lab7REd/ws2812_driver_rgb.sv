// WS2812 LED Driver with RGB Color Input
// Accepts 24-bit RGB color and converts to GRB for WS2812
// Continuously sends color data to LED

module ws2812_driver_rgb (
    input  logic clk,              // 50MHz clock
    input  logic reset_n,          // Active low reset
    input  logic [23:0] rgb_color, // Input color: [23:16]=R, [15:8]=G, [7:0]=B
    output logic ws2812_data       // WS2812 data output
);

    // 50MHz = 20ns per cycle
    // T0H = 400ns  = 20 cycles
    // T0L = 850ns  = 43 cycles
    // T1H = 800ns  = 40 cycles
    // T1L = 450ns  = 23 cycles
    // Reset = 50us = 2500 cycles

    localparam T0H = 20;
    localparam T0L = 43;
    localparam T1H = 40;
    localparam T1L = 23;
    localparam RESET_CYCLES = 2500;

    // State machine
    typedef enum logic [1:0] {
        SEND_BIT,
        RESET_STATE
    } state_t;

    state_t state;

    logic [15:0] cycle_cnt;
    logic [4:0]  bit_idx;
    logic        current_bit;
    logic [15:0] bit_duration;
    logic [15:0] high_duration;

    // Convert RGB to GRB format for WS2812
    logic [23:0] grb_color;
    assign grb_color = {rgb_color[15:8], rgb_color[23:16], rgb_color[7:0]};  // G, R, B

    // Get current bit from color data (MSB first)
    assign current_bit = grb_color[23 - bit_idx];

    // Calculate durations based on bit value
    assign high_duration = current_bit ? T1H : T0H;
    assign bit_duration  = current_bit ? (T1H + T1L) : (T0H + T0L);

    // State machine
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= SEND_BIT;
            cycle_cnt <= 0;
            bit_idx <= 0;
            ws2812_data <= 0;
        end else begin
            case (state)
                SEND_BIT: begin
                    // Output high during high_duration, then low
                    if (cycle_cnt < high_duration)
                        ws2812_data <= 1;
                    else
                        ws2812_data <= 0;

                    if (cycle_cnt >= bit_duration - 1) begin
                        cycle_cnt <= 0;
                        if (bit_idx >= 23) begin
                            bit_idx <= 0;
                            state <= RESET_STATE;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        cycle_cnt <= cycle_cnt + 1;
                    end
                end

                RESET_STATE: begin
                    ws2812_data <= 0;
                    if (cycle_cnt >= RESET_CYCLES - 1) begin
                        cycle_cnt <= 0;
                        state <= SEND_BIT;
                    end else begin
                        cycle_cnt <= cycle_cnt + 1;
                    end
                end

                default: state <= SEND_BIT;
            endcase
        end
    end

endmodule
