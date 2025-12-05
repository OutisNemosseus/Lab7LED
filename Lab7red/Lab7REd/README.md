# Lab 7 - WS2812 Fade Controller

**ECE272 Digital Logic Design - Lab 7**
WS2812 LED Smooth Color Fading Controller

---

## 📁 Project Structure

```
Lab7REd/
│
├── 📂 design/              ⭐ Design files (for Quartus & simulation)
│   ├── de10_lite_wrapper.sv       # Top-level FPGA wrapper
│   ├── ws2812_fade_top.sv         # Main system integration
│   ├── fading_controller.sv       # Linear interpolation engine
│   ├── color_memory.sv            # Color ROM (5 colors)
│   └── ws2812_driver_rgb.sv       # WS2812 protocol driver
│
├── 📂 testbench/          ⭐ Testbenches (for ModelSim)
│   ├── tb_color_memory.sv         # Tests: color_memory.sv
│   ├── tb_fading_controller.sv    # Tests: fading_controller.sv
│   └── tb_ws2812_fade_top.sv      # Tests: Complete system (FULL CYCLE)
│
├── 📂 sim/                ⭐ Simulation scripts (ModelSim .do files)
│   ├── sim_color_memory.do        # Run color memory test
│   ├── sim_fading_controller.do   # Run fading controller test
│   └── sim_ws2812_fade_top.do     # Run complete system test
│
├── 📂 quartus/            ⭐ Quartus project files
│   ├── Lab7LED.qpf                # Quartus project file
│   └── Lab7LED.qsf                # Pin assignments & settings
│
├── 📂 docs/               📖 Documentation
│   ├── README.md                  # Detailed project documentation
│   ├── TESTBENCH_GUIDE.md        # Testbench reference guide
│   ├── QUARTUS_SETUP.md          # Quartus setup instructions
│   └── Lab 7 - WS2812 Fade Controller.docx
│
├── 📂 legacy/             🗄️ Old files (not used)
│   ├── ws2812_driver.sv
│   └── ws2812_top.sv
│
├── .gitignore
└── PInlabred.txt
```

---

## 🚀 Quick Start

### **For Simulation (ModelSim):**

```bash
# Navigate to sim directory
cd sim

# Run complete system test (shows FULL BLENDING CYCLE)
vsim -do sim_ws2812_fade_top.do
```

### **For Hardware (Quartus):**

```bash
# Navigate to quartus directory
cd quartus

# Open project in Quartus
quartus Lab7LED.qpf

# Or compile via command line
quartus_sh --flow compile Lab7LED
```

Then:
1. Open Quartus → File → Open Project → `quartus/Lab7LED.qpf`
2. Processing → Start Compilation (`Ctrl+L`)
3. Tools → Programmer → Start
4. Wire WS2812 LED and enjoy the fade!

---

## 📊 Design Overview

### Color Sequence (15 seconds total)
1. **White** (0xFFFFFF) - 3 seconds
2. **Red** (0x0000FF) - 3 seconds
3. **Off/Black** (0x000000) - 3 seconds
4. **Green** (0xFF0000) - 3 seconds
5. **Teal/Cyan** (0xFFFF00) - 3 seconds

### Key Features
✅ 30 FPS smooth linear interpolation
✅ Independent R/G/B channel fading
✅ WS2812 protocol (GRB format, correct timing)
✅ Automatic color cycling with wrap-around
✅ 3-second transitions per color

---

## 🧪 Testing & Verification

### Testbenches Summary

| Run This | Tests This Module | Purpose |
|----------|-------------------|---------|
| `sim/sim_color_memory.do` | `design/color_memory.sv` | Verify ROM colors |
| `sim/sim_fading_controller.do` | `design/fading_controller.sv` | Verify interpolation |
| `sim/sim_ws2812_fade_top.do` | `design/ws2812_fade_top.sv` | **FULL CYCLE** ⭐ |

**For TA Checkoff:** Run `sim/sim_ws2812_fade_top.do` to demonstrate one complete blending cycle.

---

## 🔌 Hardware Connections

### DE10-Lite Pin Assignments

| Signal | Pin | Board Connection |
|--------|-----|------------------|
| Clock (PINP11) | PIN_P11 | MAX10_CLK1_50 (50 MHz) |
| Reset (PINB8) | PIN_B8 | KEY[0] button |
| WS2812 Data (PINAB7) | PIN_AB7 | Arduino_IO2 header |

### WS2812 LED Wiring

⚠️ **IMPORTANT:**
- Power WS2812 from **5V** (Arduino 5V pin)
- Connect GND to Arduino GND
- Connect DIN to PIN_AB7
- **DO NOT** connect DOUT back to FPGA (5V will damage 3.3V pins!)

```
DE10-Lite          WS2812 LED
┌──────────┐      ┌──────────┐
│ 5V       │─────→│ VDD (5V) │
│ GND      │─────→│ GND      │
│ PIN_AB7  │─────→│ DIN      │
│          │  ✗   │ DOUT     │ ← DO NOT CONNECT
└──────────┘      └──────────┘
```

---

## 📚 Documentation

Detailed documentation is available in the `docs/` folder:

- **docs/README.md** - Complete technical documentation
- **docs/TESTBENCH_GUIDE.md** - Testbench usage guide
- **docs/QUARTUS_SETUP.md** - Quartus setup & troubleshooting

---

## 🎯 Lab Requirements Checklist

For successful TA checkoff:

- [ ] **Simulation:** Show ONE FULL BLENDING CYCLE in ModelSim
  - Run: `sim/sim_ws2812_fade_top.do`
  - Show: All 5 color transitions
  - Show: Color address wraps (4 → 0)

- [ ] **Hardware:** Demonstrate WS2812 LED cycling
  - Smooth transitions (~3 sec each)
  - Correct color sequence
  - KEY[0] reset works

- [ ] **Understanding:** Explain design
  - Linear interpolation algorithm
  - RGB to GRB conversion
  - Block diagram symmetry

---

## 🔧 Module Descriptions

### 1. **color_memory.sv** (ROM)
- Stores 5 predefined colors
- Combinational logic
- Address input (0-4) → RGB output

### 2. **fading_controller.sv** (Interpolator)
- Linear color interpolation
- 30 frames per 3-second transition
- Independent R/G/B channel math
- 5,000,000 cycles/frame @ 50 MHz

### 3. **ws2812_driver_rgb.sv** (Protocol Driver)
- RGB → GRB conversion
- WS2812 timing generation
- Continuous data transmission

### 4. **ws2812_fade_top.sv** (System Integration)
- Color sequencer (0→1→2→3→4→0)
- Connects memory, fader, driver
- Auto-advance on transition complete

### 5. **de10_lite_wrapper.sv** (Top-Level)
- Board-specific pin names
- FPGA synthesis top-level

---

## 📦 Files to Use

### For Quartus Compilation:
✅ **Include these 5 files** (in `design/`):
1. de10_lite_wrapper.sv (top-level)
2. ws2812_fade_top.sv
3. fading_controller.sv
4. color_memory.sv
5. ws2812_driver_rgb.sv

❌ **Do NOT include:**
- Testbenches (tb_*.sv)
- Simulation scripts (.do files)
- Legacy files

### For ModelSim Simulation:
- Run `.do` files from `sim/` directory
- Scripts automatically compile from `design/` and `testbench/`

---

## 🌐 GitHub Repository

**Repository:** https://github.com/OutisNemosseus/Lab7LED

All design files, testbenches, and documentation are version controlled.

---

## 🎓 Design Parameters

| Parameter | Value |
|-----------|-------|
| Clock Frequency | 50 MHz |
| Transition Time | 3 seconds per color |
| Frame Rate | 30 fps |
| Frames Per Transition | 30 frames |
| Cycles Per Frame | 5,000,000 |
| Total Loop Time | 15 seconds |
| WS2812 T0H | 400ns (20 cycles) |
| WS2812 T0L | 850ns (43 cycles) |
| WS2812 T1H | 800ns (40 cycles) |
| WS2812 T1L | 450ns (23 cycles) |
| WS2812 Reset | 50µs (2500 cycles) |

---

## 📝 Notes

- **Simulation Timing:** Testbenches use fast timing (1000-2000 cycles/frame) for quick verification
- **Hardware Timing:** Synthesis uses real timing (5,000,000 cycles/frame) for proper 3-second fades
- **Color Format:** Stored as RGB, transmitted as GRB (WS2812 requirement)
- **Interpolation:** Signed 9-bit math with clamping to 0-255 range

---

## 📧 Authors

**Course:** ECE272 Digital Logic Design
**Lab:** Lab 7 - WS2812 Fade Controller
**Date:** December 5, 2025

---

## 📄 License

Educational project for ECE272 coursework.
