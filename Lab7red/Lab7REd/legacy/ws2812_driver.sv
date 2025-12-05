// WS2812 LED Driver
// Pin: Arduino_IO2 (PIN_AB7) - 3.3V LVTTL
// Clock: 50MHz

module ws2812_driver (
    input  logic PINP11,   // 50MHz clock (MAX10_CLK1_50)
    output logic PINAB7    // WS2812 data output
);

    logic clk;
    assign clk = PINP11;

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
    
    // 24-bit color: GRB format
    // Bright RED
    localparam [23:0] LED_COLOR = 24'h00_FF_00;  // G=00, R=FF, B=00
    
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
    
    // Internal reset using a counter at power-up
    logic [3:0] init_cnt = 0;
    logic       rst_n = 0;
    
    always_ff @(posedge clk) begin
        if (init_cnt < 4'hF) begin
            init_cnt <= init_cnt + 1;
            rst_n <= 0;
        end else begin
            rst_n <= 1;
        end
    end
    
    // Get current bit from color data (MSB first)
    assign current_bit = LED_COLOR[23 - bit_idx];
    
    // Calculate durations based on bit value
    assign high_duration = current_bit ? T1H : T0H;
    assign bit_duration  = current_bit ? (T1H + T1L) : (T0H + T0L);
    
    // State machine
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state <= SEND_BIT;
            cycle_cnt <= 0;
            bit_idx <= 0;
            PINAB7 <= 0;
        end else begin
            case (state)
                SEND_BIT: begin
                    // Output high during high_duration, then low
                    if (cycle_cnt < high_duration)
                        PINAB7 <= 1;
                    else
                        PINAB7 <= 0;
                    
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
                    PINAB7 <= 0;
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
