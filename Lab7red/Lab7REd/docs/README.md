# Lab 7 - WS2812 Fade Controller

ECE272 Digital Logic Design - Lab 7
WS2812 LED Smooth Color Fading Controller

## Project Overview

This project implements a smooth color fading controller for WS2812 RGB LEDs. The system cycles through 5 predefined colors with 3-second linear transitions at 30 fps (frames per second) for smooth visual blending.

### Color Sequence (15 seconds total loop)
1. **White** (0xFFFFFF) - 3 seconds
2. **Red** (0x0000FF) - 3 seconds
3. **Off/Black** (0x000000) - 3 seconds
4. **Green** (0xFF0000) - 3 seconds
5. **Teal/Cyan** (0xFFFF00) - 3 seconds

## Project Structure

```
Lab7REd/
├── Design Files (SystemVerilog)
│   ├── de10_lite_wrapper.sv       # Top-level FPGA wrapper with pin names
│   ├── ws2812_fade_top.sv         # Main system integrating all modules
│   ├── fading_controller.sv       # Linear color interpolation engine
│   ├── color_memory.sv            # ROM storing 5 colors
│   └── ws2812_driver_rgb.sv       # WS2812 protocol driver
│
├── Testbench Files (SystemVerilog)
│   ├── tb_color_memory.sv         # Tests: color_memory.sv
│   ├── tb_fading_controller.sv    # Tests: fading_controller.sv
│   └── tb_ws2812_fade_top.sv      # Tests: Complete system (FULL CYCLE)
│
├── Simulation Scripts (ModelSim .do files)
│   ├── sim_color_memory.do        # Run color_memory testbench
│   ├── sim_fading_controller.do   # Run fading_controller testbench
│   └── sim_ws2812_fade_top.do     # Run complete system testbench
│
└── Quartus Project Files
    └── Lab7LED.qsf                # Pin assignments and project settings
```

## Design Architecture

### Module Hierarchy

```
de10_lite_wrapper (Top-level for FPGA)
└── ws2812_fade_top
    ├── color_memory (ROM with 5 colors)
    ├── fading_controller (Linear interpolation)
    └── ws2812_driver_rgb (WS2812 protocol)
```

### Module Descriptions

#### 1. `color_memory.sv`
- **Type:** Combinational ROM
- **Function:** Stores 5 predefined colors
- **Interface:**
  - Input: `addr[2:0]` - Color address (0-4)
  - Output: `data_out[23:0]` - RGB color value

#### 2. `fading_controller.sv`
- **Type:** Sequential (clocked)
- **Function:** Smoothly interpolates between colors
- **Key Features:**
  - 30 frames per 3-second transition
  - Independent linear interpolation for R, G, B channels
  - Signed arithmetic for smooth color transitions
  - 5,000,000 clock cycles per frame (at 50 MHz)
- **Interface:**
  - Input: `clk`, `reset_n`, `target_color[23:0]`
  - Output: `current_color[23:0]`, `transition_done`

#### 3. `ws2812_driver_rgb.sv`
- **Type:** Sequential (clocked)
- **Function:** Converts RGB color to WS2812 protocol
- **Key Features:**
  - Converts RGB to GRB format (WS2812 requirement)
  - Generates precise timing: T0H=400ns, T0L=850ns, T1H=800ns, T1L=450ns
  - 50µs reset period between frames
- **Interface:**
  - Input: `clk`, `reset_n`, `rgb_color[23:0]`
  - Output: `ws2812_data`

#### 4. `ws2812_fade_top.sv`
- **Type:** Sequential (clocked)
- **Function:** Integrates all modules and manages color sequencing
- **Key Features:**
  - Cycles through 5 colors automatically
  - Wraps from color 4 back to color 0
  - Updates color address when transition completes
- **Interface:**
  - Input: `clk`, `reset_n`
  - Output: `ws2812_out`

## Testbenches

### Testbench Summary Table

| Testbench File | Module Under Test | What It Tests | Run Time |
|----------------|-------------------|---------------|----------|
| `tb_color_memory.sv` | `color_memory.sv` | All 5 color addresses return correct values | ~100 ns |
| `tb_fading_controller.sv` | `fading_controller.sv` | Linear interpolation through all 5 color transitions | ~500 µs |
| `tb_ws2812_fade_top.sv` | `ws2812_fade_top.sv` | **FULL BLENDING CYCLE** through all 5 colors | ~5 ms |

### Detailed Testbench Descriptions

#### 1. `tb_color_memory.sv`
- **Tests:** `color_memory.sv`
- **Verification:**
  - Reads all 5 color addresses (0-4)
  - Verifies each address returns correct RGB value
  - Tests default/invalid address handling
- **Pass Criteria:** All 5 colors match expected values

#### 2. `tb_fading_controller.sv`
- **Tests:** `fading_controller.sv`
- **Verification:**
  - Tests all 5 color transitions:
    1. Black → White
    2. White → Red
    3. Red → Off
    4. Off → Green
    5. Green → Teal
  - Verifies `transition_done` signal
  - Monitors color interpolation samples
- **Note:** Uses fast timing (1000 cycles/frame) for quick simulation
- **Pass Criteria:** Each transition reaches target color

#### 3. `tb_ws2812_fade_top.sv` ⭐ **MAIN SYSTEM TEST**
- **Tests:** `ws2812_fade_top.sv` (complete system)
- **Verification:**
  - **Shows ONE FULL BLENDING CYCLE** through all 5 colors
  - Verifies color sequencer wraps correctly (4 → 0)
  - Monitors WS2812 output activity
  - Checks final colors within ±2 tolerance (accounts for integer division)
- **Note:** Uses fast timing (2000 cycles/frame) for reasonable sim time
- **Pass Criteria:**
  - All 5 transitions complete successfully
  - Each color within ±2 of target
  - WS2812 driver shows activity (>100 toggles)

## Running Simulations

### Using ModelSim

#### Option 1: Run Individual Testbenches
```bash
# Test color memory
vsim -do sim_color_memory.do

# Test fading controller
vsim -do sim_fading_controller.do

# Test complete system (FULL CYCLE)
vsim -do sim_ws2812_fade_top.do
```

#### Option 2: Manual Compilation
```bash
# Create work library
vlib work

# Compile all design files
vlog -sv color_memory.sv
vlog -sv fading_controller.sv
vlog -sv ws2812_driver_rgb.sv
vlog -sv ws2812_fade_top.sv

# Compile testbench
vlog -sv tb_ws2812_fade_top.sv

# Run simulation
vsim -voptargs=+acc tb_ws2812_fade_top
run -all
```

### Expected Console Output

When running `tb_ws2812_fade_top.sv`, you should see:
```
=== WS2812 Fade Top-Level Testbench ===
This test shows ONE FULL BLENDING CYCLE through all 5 colors

Time(us) Color# Color Name  Target Color  Current Color  Status
0        0      White       ffffff        000000         Starting
...      0      White       ffffff        ffffff         Complete
                                                         PASS: Reached White
...      1      Red         0000ff        0000ff         Complete
                                                         PASS: Reached Red
...      2      Off         000000        000000         Complete
                                                         PASS: Reached Off
...      3      Green       ff0000        ff0000         Complete
                                                         PASS: Reached Green
...      4      Teal        ffff00        ffff00         Complete
                                                         PASS: Reached Teal

--- Testing Wrap-Around ---
Wrapped back to color 0 (White)

=== ONE FULL BLENDING CYCLE COMPLETE ===
WS2812 output toggles: [large number]
PASS: WS2812 driver is actively sending data
```

## Hardware Deployment

### Pin Connections (DE10-Lite Board)

| Signal | Pin Name | Pin Number | Description |
|--------|----------|------------|-------------|
| Clock | PINP11 | P11 | 50 MHz clock (MAX10_CLK1_50) |
| Reset | PINB8 | B8 | KEY[0] button (active low) |
| WS2812 Data | PINAB7 | AB7 | Arduino_IO2 header pin |

### WS2812 LED Wiring

⚠️ **IMPORTANT POWER WARNING**
- WS2812 requires **5V power** from Arduino 5V pin
- **DO NOT** connect WS2812 data OUT back to FPGA (5V will damage 3.3V pins)
- Data IN from FPGA (PIN_AB7) is 3.3V but acceptable to WS2812

**Wiring Diagram:**
```
DE10-Lite Board          WS2812 LED
┌─────────────┐         ┌──────────┐
│ Arduino 5V  │────────>│ VDD (5V) │
│ Arduino GND │────────>│ GND      │
│ PIN_AB7     │────────>│ DIN      │
│             │    ✗    │ DOUT     │ <- DO NOT CONNECT
└─────────────┘         └──────────┘
```

### Synthesis and Programming

1. **Open Quartus Project:**
   ```
   Open "Lab7LED.qpf" in Quartus Prime
   ```

2. **Compile Design:**
   - Processing → Start Compilation
   - Or press Ctrl+L

3. **Program FPGA:**
   - Tools → Programmer
   - Click "Start" to program the DE10-Lite board

4. **Verify Operation:**
   - LED should cycle through colors: White → Red → Off → Green → Teal
   - Each color transition takes ~3 seconds
   - Transitions should be smooth (no abrupt color changes)
   - Press KEY[0] to reset to White

## Design Parameters

### Timing Specifications
- **Clock Frequency:** 50 MHz (20 ns period)
- **Transition Time:** 3 seconds per color
- **Frame Rate:** 30 fps (frames per second)
- **Frames Per Transition:** 30 frames
- **Clock Cycles Per Frame:** 5,000,000 cycles
- **Total Loop Time:** 15 seconds (5 colors × 3 seconds)

### WS2812 Protocol Timing
- **T0H (0 bit high):** 400 ns (20 cycles @ 50MHz)
- **T0L (0 bit low):** 850 ns (43 cycles)
- **T1H (1 bit high):** 800 ns (40 cycles)
- **T1L (1 bit low):** 450 ns (23 cycles)
- **Reset Period:** 50 µs (2500 cycles)
- **Bits Per Color:** 24 bits (8R + 8G + 8B)
- **Bit Order:** GRB (Green, Red, Blue)

## Design Notes

### Color Format
- **Storage:** RGB format (Red[23:16], Green[15:8], Blue[7:0])
- **WS2812 Transmission:** GRB format (auto-converted by driver)

### Interpolation Algorithm
For each color channel (R, G, B):
```
current = start + (target - start) × frame_counter / 30
```
- Uses signed 9-bit arithmetic for differences
- Supports both increasing and decreasing values
- Clamps results to 0-255 range

### Simulation vs. Hardware Timing
- **Simulation:** Uses fast timing (1000-2000 cycles/frame) for quick verification
- **Hardware:** Uses real timing (5,000,000 cycles/frame) for proper 3-second transitions
- Testbenches override `CYCLES_PER_FRAME` parameter using `defparam`

## Verification Checklist

For TA checkoff, ensure you can demonstrate:

- [ ] **Simulation:** ModelSim waveform showing ONE FULL BLENDING CYCLE
  - Run: `vsim -do sim_ws2812_fade_top.do`
  - Show: All 5 color transitions complete
  - Show: Color address wraps from 4 to 0

- [ ] **Hardware:** WS2812 LED cycling through all 5 colors
  - Verify: Smooth transitions (not abrupt)
  - Verify: ~3 seconds per color
  - Verify: Correct color sequence

- [ ] **Understanding:** Be able to explain:
  - How linear interpolation works
  - Why RGB is converted to GRB
  - How the color sequencer wraps around
  - The symmetry between R, G, B channels in fading_controller

## Troubleshooting

### Common Issues

**Issue:** LED doesn't light up
- Check 5V power connection
- Verify GND is connected
- Confirm FPGA is programmed
- Press KEY[0] to reset

**Issue:** Colors are wrong
- WS2812 uses GRB format (check `ws2812_driver_rgb.sv:51`)
- Verify color memory values match spec

**Issue:** Transitions are abrupt (not smooth)
- Check `CYCLES_PER_FRAME` parameter in hardware build
- Should be 5,000,000 for 3-second transitions
- Testbench uses fast timing (normal)

**Issue:** Simulation takes too long
- Ensure testbenches use `defparam` to override timing
- `tb_ws2812_fade_top.sv` uses 2000 cycles/frame (not 5M)

**Issue:** Colors don't cycle
- Check `transition_done` signal in `fading_controller`
- Verify `color_addr` increments in `ws2812_fade_top`

## Files Created

### Required for Quartus Synthesis
- `de10_lite_wrapper.sv`
- `ws2812_fade_top.sv`
- `fading_controller.sv`
- `color_memory.sv`
- `ws2812_driver_rgb.sv`
- `Lab7LED.qsf`

### Required for Simulation
- All above .sv files
- `tb_color_memory.sv`
- `tb_fading_controller.sv`
- `tb_ws2812_fade_top.sv`
- `sim_color_memory.do`
- `sim_fading_controller.do`
- `sim_ws2812_fade_top.do`

### Documentation
- `README.md` (this file)

## Authors & Date

- **Course:** ECE272 Digital Logic Design
- **Lab:** Lab 7 - WS2812 Fade Controller
- **Date:** December 5, 2025
- **Implementation:** Automated design system

## References

- WS2812 Datasheet: https://cdn-shop.adafruit.com/datasheets/WS2812.pdf
- DE10-Lite User Manual: https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=1021&PartNo=4
- Lab 7 Assignment Document: "Lab 7 - WS2812 Fade Controller.docx"
