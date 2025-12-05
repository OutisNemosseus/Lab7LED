//=============================================================================
// Module: ShiftRegister
// Description: 24-bit shift register for WS2812 color data
//              Stores GRB data and shifts out MSB first
//              
// Data Format (from WS2812 datasheet):
//   - Order: G7-G0, R7-R0, B7-B0 (Green, Red, Blue)
//   - MSB sent first
//   - Total: 24 bits per LED
//
// Operation:
//   - load: Parallel load of 24-bit color data
//   - shift_en: Shift register left by 1 bit (MSB out)
//   - bit_out: Current MSB (bit to be sent)
//
// Author: ENGR 110 Lab 6
// Date: 2024
//=============================================================================

module ShiftRegister (
    input  logic        clk,            // 50MHz system clock
    input  logic        reset_n,        // Active-low asynchronous reset
    input  logic        load,           // Load parallel data
    input  logic        shift_en,       // Enable shift (shift left)
    input  logic [23:0] data_in,        // Parallel data input [G7:G0, R7:R0, B7:B0]
    output logic        bit_out         // Serial output (MSB)
);

    //-------------------------------------------------------------------------
    // Internal Register
    //-------------------------------------------------------------------------
    logic [23:0] shift_reg;
    
    //-------------------------------------------------------------------------
    // Shift Register Logic
    // Priority: reset > load > shift
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Reset: Clear register
            shift_reg <= 24'd0;
        end else if (load) begin
            // Load: Parallel load of color data
            shift_reg <= data_in;
        end else if (shift_en) begin
            // Shift: Left shift, bring in 0 at LSB
            shift_reg <= {shift_reg[22:0], 1'b0};
        end
        // else: Hold current value
    end
    
    //-------------------------------------------------------------------------
    // Output: MSB of shift register
    //-------------------------------------------------------------------------
    assign bit_out = shift_reg[23];

endmodule
