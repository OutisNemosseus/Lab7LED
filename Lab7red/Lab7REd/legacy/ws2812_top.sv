// Top-level module for WS2812 on DE10-Lite
// Uses Arduino_IO2 pin (PIN_AB7) for LED data output

module ws2812_top (
    input  logic PINP11,   // 50MHz clock (MAX10_CLK1_50)
    output logic PINAB7    // Arduino_IO2 -> WS2812 data
);

    ws2812_driver u_ws2812 (
        .PINP11 (PINP11),
        .PINAB7 (PINAB7)
    );

endmodule
