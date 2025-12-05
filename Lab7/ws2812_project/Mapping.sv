//=============================================================================
// Module: Mapping
// Description: Maps a 3-bit input (0-7) to an 8-bit output (0-255)
//              Evenly distributes values: 0->0, 1->36, 2->73, 3->109, 
//              4->146, 5->182, 6->219, 7->255
//
// Author: ENGR 110 Lab 6
// Date: 2024
//=============================================================================

module Mapping (
    input  logic [2:0] in,      // 3-bit input (0-7)
    output logic [7:0] out      // 8-bit output (0-255)
);

    //-------------------------------------------------------------------------
    // Combinational Logic: Lookup table for mapping
    // Formula: out = in * 255 / 7 (rounded to nearest integer)
    // This provides even distribution across the 0-255 range
    //-------------------------------------------------------------------------
    always_comb begin
        case (in)
            3'd0: out = 8'd0;     // 0 * 255/7 = 0
            3'd1: out = 8'd36;    // 1 * 255/7 ≈ 36
            3'd2: out = 8'd73;    // 2 * 255/7 ≈ 73
            3'd3: out = 8'd109;   // 3 * 255/7 ≈ 109
            3'd4: out = 8'd146;   // 4 * 255/7 ≈ 146
            3'd5: out = 8'd182;   // 5 * 255/7 ≈ 182
            3'd6: out = 8'd219;   // 6 * 255/7 ≈ 219
            3'd7: out = 8'd255;   // 7 * 255/7 = 255
            default: out = 8'd0;
        endcase
    end

endmodule
