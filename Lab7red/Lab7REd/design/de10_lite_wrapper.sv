// DE10-Lite Board Wrapper for WS2812 Fade Controller
// Maps board pins to the fade controller
// This is the top-level file for FPGA synthesis

module de10_lite_wrapper (
    input  logic PINP11,  // 50MHz clock from DE10-Lite (MAX10_CLK1_50)
    input  logic PINB8,   // Reset button (KEY[0] - active low)
    output logic PINAB7   // WS2812 data output (Arduino_IO2)
);

    // Instantiate the fade controller
    ws2812_fade_top u_fade_system (
        .clk(PINP11),
        .reset_n(PINB8),
        .ws2812_out(PINAB7)
    );

endmodule
