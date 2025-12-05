# Testbench Quick Reference Guide

## Which Testbench Tests Which Module?

### Quick Lookup Table

| Run This Testbench | To Test This Module | Purpose |
|--------------------|---------------------|---------|
| `tb_color_memory.sv` | `color_memory.sv` | Verify ROM returns correct colors for addresses 0-4 |
| `tb_fading_controller.sv` | `fading_controller.sv` | Verify linear interpolation and smooth color transitions |
| `tb_ws2812_fade_top.sv` | `ws2812_fade_top.sv` | **Verify COMPLETE SYSTEM** with full blending cycle |

---

## Testbench 1: Color Memory

### Module Under Test
- **File:** `color_memory.sv`
- **Type:** Combinational ROM

### Testbench File
- **File:** `tb_color_memory.sv`
- **Run Command:** `vsim -do sim_color_memory.do`

### What It Tests
✅ All 5 color addresses (0-4) return correct RGB values
✅ Address 0 → 0xFFFFFF (White)
✅ Address 1 → 0x0000FF (Red)
✅ Address 2 → 0x000000 (Off)
✅ Address 3 → 0xFF0000 (Green)
✅ Address 4 → 0xFFFF00 (Teal)
✅ Invalid addresses return default value

### Expected Output
```
=== Color Memory Testbench ===
Time  Addr  Data Out  Expected  Status
0     0     ffffff    ffffff    PASS
10    1     0000ff    0000ff    PASS
20    2     000000    000000    PASS
30    3     ff0000    ff0000    PASS
40    4     ffff00    ffff00    PASS
```

---

## Testbench 2: Fading Controller

### Module Under Test
- **File:** `fading_controller.sv`
- **Type:** Sequential (clocked state machine)

### Testbench File
- **File:** `tb_fading_controller.sv`
- **Run Command:** `vsim -do sim_fading_controller.do`

### What It Tests
✅ Linear interpolation from Black → White
✅ Transition from White → Red
✅ Transition from Red → Off
✅ Transition from Off → Green
✅ Transition from Green → Teal
✅ `transition_done` signal pulses correctly
✅ Color updates at 30 fps rate
✅ Separate R, G, B channel interpolation

### Expected Output
```
=== Fading Controller Testbench ===

--- Test 1: Black to White ---
PASS: Reached White

--- Test 2: White to Red ---
PASS: Reached Red

--- Test 3: Red to Off ---
PASS: Reached Off

--- Test 4: Off to Green ---
PASS: Reached Green

--- Test 5: Green to Teal ---
PASS: Reached Teal
```

### Key Signals to Observe
- `target_color` - What color we're fading to
- `current_color` - Current interpolated color
- `transition_done` - Pulses when fade completes
- `frame_counter` - Should count 0 to 29 (30 frames)
- `delta_r`, `delta_g`, `delta_b` - Signed color differences

---

## Testbench 3: Complete System ⭐ **MAIN TEST**

### Module Under Test
- **File:** `ws2812_fade_top.sv`
- **Type:** Complete integrated system

### Testbench File
- **File:** `tb_ws2812_fade_top.sv`
- **Run Command:** `vsim -do sim_ws2812_fade_top.do`

### What It Tests
✅ **ONE FULL BLENDING CYCLE** through all 5 colors
✅ Color sequencer increments: 0 → 1 → 2 → 3 → 4
✅ Color sequencer wraps: 4 → 0
✅ Each color transition completes successfully
✅ Final colors match targets (within ±2 tolerance)
✅ WS2812 driver generates output
✅ Integration of all modules:
  - `color_memory.sv`
  - `fading_controller.sv`
  - `ws2812_driver_rgb.sv`

### Expected Output
```
=== WS2812 Fade Top-Level Testbench ===
This test shows ONE FULL BLENDING CYCLE through all 5 colors

Time(us)  Color#  Color Name  Target Color  Current Color  Status
50        0       White       ffffff        000000         Starting
1500      0       White       ffffff        ffffff         Complete
                                                           PASS: Reached White
1600      1       Red         0000ff        ffffff         Starting
3100      1       Red         0000ff        0000ff         Complete
                                                           PASS: Reached Red
[... continues for all 5 colors ...]

--- Testing Wrap-Around ---
Wrapped back to color 0 (White)

=== ONE FULL BLENDING CYCLE COMPLETE ===
WS2812 output toggles: 15000
PASS: WS2812 driver is actively sending data
```

### Key Signals to Observe
- `color_addr` - Should sequence 0→1→2→3→4→0
- `target_color` - Color from memory
- `current_color` - Interpolated color from fading controller
- `transition_done` - Triggers address increment
- `ws2812_out` - Should toggle frequently (WS2812 protocol)

---

## Running Simulations Step-by-Step

### Quick Test (Recommended for TA Demo)
```bash
# Run the main system test (shows FULL CYCLE)
cd C:\ECE272\Lab7red\Lab7REd
vsim -do sim_ws2812_fade_top.do
```

### Complete Test Suite
```bash
# Test 1: Color Memory
vsim -do sim_color_memory.do

# Test 2: Fading Controller
vsim -do sim_fading_controller.do

# Test 3: Complete System
vsim -do sim_ws2812_fade_top.do
```

### Manual Simulation
```bash
# Create work library
vlib work

# Compile all files
vlog -sv color_memory.sv
vlog -sv fading_controller.sv
vlog -sv ws2812_driver_rgb.sv
vlog -sv ws2812_fade_top.sv

# Choose ONE testbench to compile and run:

# Option A: Test color memory
vlog -sv tb_color_memory.sv
vsim -voptargs=+acc tb_color_memory
run -all

# Option B: Test fading controller
vlog -sv tb_fading_controller.sv
vsim -voptargs=+acc tb_fading_controller
run -all

# Option C: Test complete system
vlog -sv tb_ws2812_fade_top.sv
vsim -voptargs=+acc tb_ws2812_fade_top
run -all
```

---

## Waveform Viewing Tips

### Color Memory Waveform
**Key Signals:**
- `addr` - Input address (0-4)
- `data_out` - Output color (display in hex)

**What to Look For:**
- Combinational logic (instant response)
- Each address produces correct color

### Fading Controller Waveform
**Key Signals:**
- `target_color` - Target (hex)
- `current_color` - Current (hex)
- `frame_counter` - Should count 0-29
- `delta_r`, `delta_g`, `delta_b` - Signed differences
- `transition_done` - Pulses at frame 29

**What to Look For:**
- `current_color` gradually changes from start to target
- Linear interpolation (even steps)
- All three color channels (R, G, B) update independently

### Complete System Waveform
**Key Signals:**
- `color_addr` - Address (0-4, decimal)
- `target_color` - From memory (hex)
- `current_color` - From fading controller (hex)
- `transition_done` - Triggers address increment
- `ws2812_out` - Protocol output (binary)

**What to Look For:**
- Color address increments when `transition_done` pulses
- Smooth color transitions (not abrupt jumps)
- WS2812 output toggles frequently
- Address wraps from 4 back to 0

---

## Pass/Fail Criteria

### tb_color_memory.sv
✅ **PASS:** All 5 addresses return expected colors
❌ **FAIL:** Any color mismatch

### tb_fading_controller.sv
✅ **PASS:** All 5 transitions reach target colors
❌ **FAIL:** Any transition fails to reach target

### tb_ws2812_fade_top.sv
✅ **PASS:**
- All 5 color transitions complete
- Each color within ±2 of target
- WS2812 output shows >100 toggles
- Address wraps correctly (4 → 0)

❌ **FAIL:**
- Transition doesn't complete
- Color error > ±2
- No WS2812 activity
- Address doesn't wrap

---

## Timing Notes

### Simulation Timing (Fast)
To keep simulation time reasonable, testbenches override the frame timing:
- **Real Hardware:** 5,000,000 cycles/frame (3 seconds @ 50MHz)
- **Simulation:** 1,000 - 2,000 cycles/frame (fast)

This is done with:
```systemverilog
defparam dut.u_fading_controller.CYCLES_PER_FRAME = 2000;
```

### Hardware Timing (Real)
When synthesized for FPGA, the design uses real timing:
- 5,000,000 cycles/frame = 100ms @ 50MHz = 3 seconds per color

---

## Common Questions

**Q: Why are there 3 testbenches?**
A: Bottom-up verification strategy:
1. Test smallest module (ROM)
2. Test complex module (fading controller)
3. Test complete system (integration)

**Q: Which testbench should I show the TA?**
A: `tb_ws2812_fade_top.sv` - It shows the complete blending cycle required by the lab.

**Q: Why doesn't the simulation take 15 seconds?**
A: Fast timing is used in simulation. Real hardware uses 3 seconds per color.

**Q: What if colors are slightly off in simulation?**
A: ±2 tolerance is acceptable due to integer division in interpolation math.

**Q: How do I know WS2812 driver is working?**
A: Look for `ws2812_out` toggling frequently in waveform (>100 transitions).

---

## For TA Checkoff

Show this simulation:
```bash
vsim -do sim_ws2812_fade_top.do
```

Point out in waveform:
1. ✅ `color_addr` sequences: 0 → 1 → 2 → 3 → 4 → 0
2. ✅ Each transition completes (transition_done pulses)
3. ✅ Colors match expected sequence
4. ✅ WS2812 output is active

Explain:
- Linear interpolation algorithm in `fading_controller.sv`
- Why RGB converts to GRB for WS2812
- How frame counter creates 30-step transitions
- Block diagram showing module hierarchy
