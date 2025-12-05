//=============================================================================
// Module: ShiftController
// Description: Controls the transmission of 24 bits to WS2812 LED
//              Manages BitSender and ShiftRegister interaction
//              Generates RESET signal between frames
//
// Operation Sequence:
//   1. Load 24-bit GRB data into shift register
//   2. Send each bit via BitSender (MSB first)
//   3. After each bit is done, shift register and send next
//   4. After 24 bits, generate RESET signal (>50µs low)
//   5. Repeat
//
// Timing:
//   - 24 bits × ~1.25µs = ~30µs per LED
//   - RESET: 50-100µs (we use ~80µs = 4000 cycles)
//
// Author: ENGR 110 Lab 6
// Date: 2024
//=============================================================================

module ShiftController (
    input  logic        clk,            // 50MHz system clock
    input  logic        reset_n,        // Active-low asynchronous reset
    input  logic [23:0] color_data,     // 24-bit color data [G7:G0, R7:R0, B7:B0]
    output logic        ws2812_out      // Output to WS2812 data line
);

    //-------------------------------------------------------------------------
    // Parameters
    //-------------------------------------------------------------------------
    localparam RESET_CYCLES = 4000;     // 80µs reset time (50µs minimum, <100µs max)
    localparam BIT_COUNT = 24;          // 24 bits per LED
    
    //-------------------------------------------------------------------------
    // State Machine Definition
    //-------------------------------------------------------------------------
    typedef enum logic [2:0] {
        IDLE        = 3'b000,   // Initial state, load data
        SEND_BIT    = 3'b001,   // Sending a bit
        WAIT_DONE   = 3'b010,   // Wait for BitSender to finish
        SHIFT       = 3'b011,   // Shift to next bit
        RESET_LED   = 3'b100    // Generate reset signal
    } state_t;
    
    state_t state, next_state;
    
    //-------------------------------------------------------------------------
    // Internal Signals
    //-------------------------------------------------------------------------
    logic [4:0]  bit_counter;       // Count bits sent (0-23)
    logic [12:0] reset_counter;     // Count reset time
    
    // ShiftRegister interface
    logic        sr_load;
    logic        sr_shift_en;
    logic        sr_bit_out;
    
    // BitSender interface
    logic        bs_send;
    logic        bs_done;
    logic        bs_ws2812_out;
    
    // Data latch
    logic [23:0] color_latched;
    
    //-------------------------------------------------------------------------
    // Instantiate ShiftRegister
    //-------------------------------------------------------------------------
    ShiftRegister u_shift_reg (
        .clk        (clk),
        .reset_n    (reset_n),
        .load       (sr_load),
        .shift_en   (sr_shift_en),
        .data_in    (color_latched),
        .bit_out    (sr_bit_out)
    );
    
    //-------------------------------------------------------------------------
    // Instantiate BitSender
    //-------------------------------------------------------------------------
    BitSender u_bit_sender (
        .clk        (clk),
        .reset_n    (reset_n),
        .send       (bs_send),
        .bit_val    (sr_bit_out),
        .ws2812_out (bs_ws2812_out),
        .done       (bs_done)
    );
    
    //-------------------------------------------------------------------------
    // State Register
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    //-------------------------------------------------------------------------
    // Color Data Latch - Sample input when starting new frame
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            color_latched <= 24'd0;
        end else if (state == IDLE || state == RESET_LED) begin
            color_latched <= color_data;
        end
    end
    
    //-------------------------------------------------------------------------
    // Bit Counter
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            bit_counter <= 5'd0;
        end else begin
            case (state)
                IDLE: begin
                    bit_counter <= 5'd0;
                end
                SHIFT: begin
                    bit_counter <= bit_counter + 5'd1;
                end
                default: ; // Hold value
            endcase
        end
    end
    
    //-------------------------------------------------------------------------
    // Reset Counter
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            reset_counter <= 13'd0;
        end else begin
            if (state == RESET_LED) begin
                reset_counter <= reset_counter + 13'd1;
            end else begin
                reset_counter <= 13'd0;
            end
        end
    end
    
    //-------------------------------------------------------------------------
    // Next State Logic
    //-------------------------------------------------------------------------
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: begin
                // Start transmission immediately
                next_state = SEND_BIT;
            end
            
            SEND_BIT: begin
                // Move to wait state (send pulse is just one cycle)
                next_state = WAIT_DONE;
            end
            
            WAIT_DONE: begin
                if (bs_done) begin
                    // Check if more bits to send
                    if (bit_counter < BIT_COUNT - 1) begin
                        next_state = SHIFT;
                    end else begin
                        // All 24 bits sent, do reset
                        next_state = RESET_LED;
                    end
                end
            end
            
            SHIFT: begin
                // After shifting, send next bit
                next_state = SEND_BIT;
            end
            
            RESET_LED: begin
                if (reset_counter >= RESET_CYCLES - 1) begin
                    // Reset complete, start new frame
                    next_state = IDLE;
                end
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    //-------------------------------------------------------------------------
    // Output Logic
    //-------------------------------------------------------------------------
    
    // Load shift register when entering IDLE (starting new frame)
    assign sr_load = (state == IDLE);
    
    // Shift after each bit is sent
    assign sr_shift_en = (state == SHIFT);
    
    // Send pulse when entering SEND_BIT state
    assign bs_send = (state == SEND_BIT);
    
    // WS2812 output: BitSender output during transmission, LOW during reset
    assign ws2812_out = (state == RESET_LED) ? 1'b0 : bs_ws2812_out;

endmodule
