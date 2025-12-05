//=============================================================================
// Module: LedDriver (Top Level)
// Description: WS2812 LED Driver for DE10-Lite FPGA
//              Converts 3-bit RGB switch inputs to WS2812 protocol output
//
// Block Diagram:
//   
//   [SW 8:6] ---> [Mapping] ---> green[7:0] --|
//   [SW 5:3] ---> [Mapping] ---> red[7:0]   --|---> [ShiftController] ---> ws2812
//   [SW 2:0] ---> [Mapping] ---> blue[7:0]  --|
//   
//   clk (50MHz) ---------------------------------------->
//   reset_n (KEY0) ------------------------------------->
//
// Interface:
//   - clk: 50MHz clock from DE10-Lite
//   - reset_n: Active-low reset (KEY0 button)
//   - red[2:0]: 3 switches for red intensity
//   - green[2:0]: 3 switches for green intensity
//   - blue[2:0]: 3 switches for blue intensity
//   - ws2812: Data output to WS2812 LED
//
// WS2812 Data Format: G7-G0, R7-R0, B7-B0 (Green first, MSB first)
//
// Hardware Connection (DE10-Lite):
//   - Power WS2812 from 5V on Arduino header
//   - Connect ws2812 output to an Arduino GPIO pin
//   - NEVER connect WS2812 DOUT back to FPGA (5V logic!)
//
// Author: ENGR 110 Lab 6
// Date: 2024
//=============================================================================

module LedDriver (
    input  logic       clk,         // 50MHz system clock (PIN_P11)
    input  logic       reset_n,     // Active-low reset (KEY0)
    input  logic [2:0] red,         // Red intensity switches
    input  logic [2:0] green,       // Green intensity switches
    input  logic [2:0] blue,        // Blue intensity switches
    output logic       ws2812       // WS2812 data output
);

    //-------------------------------------------------------------------------
    // Internal Signals
    //-------------------------------------------------------------------------
    logic [7:0] red_mapped;         // 8-bit red value
    logic [7:0] green_mapped;       // 8-bit green value
    logic [7:0] blue_mapped;        // 8-bit blue value
    logic [23:0] color_data;        // Combined 24-bit GRB data
    
    //-------------------------------------------------------------------------
    // Instantiate Mapping Modules
    // Convert 3-bit switch values to 8-bit color intensities
    //-------------------------------------------------------------------------
    
    // Red channel mapping
    Mapping u_map_red (
        .in  (red),
        .out (red_mapped)
    );
    
    // Green channel mapping
    Mapping u_map_green (
        .in  (green),
        .out (green_mapped)
    );
    
    // Blue channel mapping
    Mapping u_map_blue (
        .in  (blue),
        .out (blue_mapped)
    );
    
    //-------------------------------------------------------------------------
    // Combine RGB to GRB format
    // WS2812 expects: G7-G0, R7-R0, B7-B0
    //-------------------------------------------------------------------------
    assign color_data = {green_mapped, red_mapped, blue_mapped};
    
    //-------------------------------------------------------------------------
    // Instantiate Shift Controller
    // Handles all timing and protocol generation
    //-------------------------------------------------------------------------
    ShiftController u_shift_ctrl (
        .clk        (clk),
        .reset_n    (reset_n),
        .color_data (color_data),
        .ws2812_out (ws2812)
    );

endmodule
