// Color Memory Module
// Stores 5 colors for the fading sequence
// Note: WS2812 uses GRB format, but we store as RGB and convert in driver

module color_memory (
    input  logic [2:0] addr,
    output logic [23:0] data_out  // RGB format: [23:16]=R, [15:8]=G, [7:0]=B
);

    always_comb begin
        case (addr)
            3'd0: data_out = 24'hFF_FF_FF;  // White
            3'd1: data_out = 24'h00_00_FF;  // Red
            3'd2: data_out = 24'h00_00_00;  // Off
            3'd3: data_out = 24'hFF_00_00;  // Green
            3'd4: data_out = 24'hFF_FF_00;  // Teal (Cyan)
            default: data_out = 24'h00_00_00;
        endcase
    end

endmodule
