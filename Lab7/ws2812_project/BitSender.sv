//=============================================================================
// Module: BitSender
// Description: Generates the correct WS2812 timing waveform for a single bit
//              
// WS2812 Timing Requirements (from datasheet):
//   - 0 code: T0H = 0.35µs (high), T0L = 0.8µs (low)
//   - 1 code: T1H = 0.7µs (high),  T1L = 0.6µs (low)
//   - Total bit time: ~1.25µs
//   - Tolerance: ±150ns
//
// Clock Calculations (50MHz clock, 20ns period):
//   - T0H = 0.35µs / 20ns = 17.5 cycles → use 18 cycles
//   - T1H = 0.7µs / 20ns = 35 cycles
//   - T0L = 0.8µs / 20ns = 40 cycles
//   - T1L = 0.6µs / 20ns = 30 cycles
//   - Total for 0: 18 + 40 = 58 cycles (1.16µs)
//   - Total for 1: 35 + 30 = 65 cycles (1.30µs)
//
// Author: ENGR 110 Lab 6
// Date: 2024
//=============================================================================

module BitSender (
    input  logic       clk,         // 50MHz system clock
    input  logic       reset_n,     // Active-low asynchronous reset
    input  logic       send,        // Start sending a bit (pulse)
    input  logic       bit_val,     // Value of bit to send (0 or 1)
    output logic       ws2812_out,  // Output to WS2812 data line
    output logic       done         // Pulse when bit transmission complete
);

    //-------------------------------------------------------------------------
    // Timing Parameters (in clock cycles at 50MHz)
    //-------------------------------------------------------------------------
    localparam T0H_CYCLES = 18;     // 0.36µs - 0 code high time
    localparam T1H_CYCLES = 35;     // 0.70µs - 1 code high time
    localparam T0L_CYCLES = 40;     // 0.80µs - 0 code low time
    localparam T1L_CYCLES = 30;     // 0.60µs - 1 code low time
    
    // Maximum count needed (T0H + T0L = 58, T1H + T1L = 65)
    localparam MAX_COUNT = 65;
    
    //-------------------------------------------------------------------------
    // State Machine Definition
    //-------------------------------------------------------------------------
    typedef enum logic [1:0] {
        IDLE    = 2'b00,    // Waiting for send signal
        HIGH    = 2'b01,    // Output high phase
        LOW     = 2'b10     // Output low phase
    } state_t;
    
    state_t state, next_state;
    
    //-------------------------------------------------------------------------
    // Internal Signals
    //-------------------------------------------------------------------------
    logic [6:0] counter;            // Counter for timing (needs 7 bits for max 65)
    logic [6:0] high_time;          // Duration of high phase
    logic [6:0] low_time;           // Duration of low phase
    logic       bit_latched;        // Latched bit value
    
    //-------------------------------------------------------------------------
    // Determine timing based on bit value
    //-------------------------------------------------------------------------
    assign high_time = bit_latched ? T1H_CYCLES : T0H_CYCLES;
    assign low_time  = bit_latched ? T1L_CYCLES : T0L_CYCLES;
    
    //-------------------------------------------------------------------------
    // State Register with Asynchronous Reset
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    //-------------------------------------------------------------------------
    // Bit Latch - Capture bit value when send is asserted
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            bit_latched <= 1'b0;
        end else if (state == IDLE && send) begin
            bit_latched <= bit_val;
        end
    end
    
    //-------------------------------------------------------------------------
    // Counter Logic
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 7'd0;
        end else begin
            case (state)
                IDLE: begin
                    counter <= 7'd0;
                end
                HIGH: begin
                    if (counter >= high_time - 1) begin
                        counter <= 7'd0;  // Reset for low phase
                    end else begin
                        counter <= counter + 7'd1;
                    end
                end
                LOW: begin
                    if (counter >= low_time - 1) begin
                        counter <= 7'd0;
                    end else begin
                        counter <= counter + 7'd1;
                    end
                end
                default: counter <= 7'd0;
            endcase
        end
    end
    
    //-------------------------------------------------------------------------
    // Next State Logic
    //-------------------------------------------------------------------------
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (send) begin
                    next_state = HIGH;
                end
            end
            
            HIGH: begin
                if (counter >= high_time - 1) begin
                    next_state = LOW;
                end
            end
            
            LOW: begin
                if (counter >= low_time - 1) begin
                    next_state = IDLE;
                end
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    //-------------------------------------------------------------------------
    // Output Logic
    //-------------------------------------------------------------------------
    // WS2812 output: High during HIGH state, Low otherwise
    assign ws2812_out = (state == HIGH);
    
    // Done signal: Pulse when transitioning from LOW to IDLE
    assign done = (state == LOW) && (counter >= low_time - 1);

endmodule
