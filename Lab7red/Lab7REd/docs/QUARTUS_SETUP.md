# Quartus Setup Guide for Lab 7

## Quick Start (Recommended)

1. **Open the project:**
   - Launch Quartus Prime
   - File → Open Project
   - Navigate to: `C:\ECE272\Lab7red\Lab7REd\Lab7LED.qpf`
   - Click "Open"

2. **Verify settings:**
   - Assignments → Settings → General
   - Check "Top-level entity" = `de10_lite_wrapper` ✅

3. **Compile:**
   - Processing → Start Compilation
   - Or press `Ctrl+L`
   - Wait for compilation to complete (~2-5 minutes)

4. **Program FPGA:**
   - Tools → Programmer
   - Click "Hardware Setup" and select "USB-Blaster"
   - Click "Start" to program
   - LED should start fading!

---

## File Organization

### Top-Level Entity
**Set as top-level:** `de10_lite_wrapper`

```
de10_lite_wrapper.sv (Top-level for FPGA synthesis)
└── Instantiates: ws2812_fade_top
```

### Design Files Included in Project

| File | Purpose | Include? |
|------|---------|----------|
| `de10_lite_wrapper.sv` | Top-level with pin names | ✅ YES |
| `ws2812_fade_top.sv` | Main system integration | ✅ YES |
| `fading_controller.sv` | Interpolation engine | ✅ YES |
| `color_memory.sv` | Color ROM | ✅ YES |
| `ws2812_driver_rgb.sv` | WS2812 driver | ✅ YES |
| `tb_*.sv` | Testbenches | ❌ NO |
| `sim_*.do` | ModelSim scripts | ❌ NO |
| `ws2812_driver.sv` | Old standalone | ❌ NO |
| `ws2812_top.sv` | Old top-level | ❌ NO |

---

## Pin Assignments

The `.qsf` file already contains these pin assignments:

| Signal | Pin | Location | I/O Standard |
|--------|-----|----------|--------------|
| PINP11 (Clock) | PIN_P11 | MAX10_CLK1_50 | 3.3-V LVTTL |
| PINAB16 (Reset) | PIN_AB16 | KEY[0] | 3.3-V LVTTL |
| PINAB7 (WS2812) | PIN_AB7 | Arduino_IO2 | 3.3-V LVTTL |

**To verify pin assignments:**
- Assignments → Pin Planner
- Check that pins match the table above

---

## Manual Setup (If Starting from Scratch)

If you need to create the project manually:

### Step 1: Create New Project
```
File → New Project Wizard
- Working directory: C:\ECE272\Lab7red\Lab7REd
- Project name: Lab7LED
- Top-level entity: de10_lite_wrapper
```

### Step 2: Add Files
```
Project → Add/Remove Files in Project
Add these 5 files:
  ✅ de10_lite_wrapper.sv
  ✅ ws2812_fade_top.sv
  ✅ fading_controller.sv
  ✅ color_memory.sv
  ✅ ws2812_driver_rgb.sv
```

### Step 3: Set Device
```
Assignments → Device
- Family: MAX 10
- Device: 10M50DAF484C7G
- Package: 484-pin FBGA
```

### Step 4: Assign Pins
```
Assignments → Pin Planner
Or use: Assignments → Import Assignments
Select: Lab7LED.qsf
```

### Step 5: Set Top-Level
```
Assignments → Settings → General
Top-level entity: de10_lite_wrapper
```

---

## Compilation Steps

### 1. Analysis & Synthesis
- Processing → Start → Start Analysis & Synthesis
- Or: `Ctrl+K`
- Checks syntax and elaborates design

### 2. Fitter
- Processing → Start → Start Fitter
- Places and routes the design

### 3. Assembler
- Processing → Start → Start Assembler
- Generates programming file (.sof)

### 4. Full Compilation (All Steps)
- Processing → Start Compilation
- Or: `Ctrl+L`
- Runs all steps above

---

## Expected Compilation Results

### Resource Usage
```
Logic Elements: ~300-500 LEs (out of 50,660)
Registers: ~100-200 registers
Memory Bits: Minimal (5 colors × 24 bits)
I/O Pins: 3 pins
```

### Timing
```
Fmax (Maximum frequency): Should exceed 50 MHz
Setup slack: Should be positive
Hold slack: Should be positive
```

If timing fails:
- Check that clock is assigned to PIN_P11
- Verify I/O standards are 3.3-V LVTTL

---

## Programming the FPGA

### Step 1: Connect Hardware
- Connect DE10-Lite to PC via USB
- Power on the board
- Install USB-Blaster driver (if needed)

### Step 2: Open Programmer
```
Tools → Programmer
```

### Step 3: Configure Programmer
```
- Hardware Setup → USB-Blaster [USB-0]
- Mode: JTAG
- File: output_files/Lab7LED.sof
- Device: 10M50DA
- Check "Program/Configure" box
```

### Step 4: Program
```
Click "Start"
Wait for "100% (Successful)"
```

### Step 5: Verify
- WS2812 LED should light up
- Should cycle through colors
- Press KEY[0] to reset

---

## Troubleshooting

### Issue: "Top-level entity not found"
**Solution:**
1. Check entity name in `de10_lite_wrapper.sv:7` matches project settings
2. Verify file is added to project
3. Assignments → Settings → General → Top-level entity = `de10_lite_wrapper`

### Issue: "Pin assignment conflicts"
**Solution:**
1. Assignments → Import Assignments → Select `Lab7LED.qsf`
2. Or manually assign pins using Pin Planner

### Issue: "Timing does not meet requirements"
**Solution:**
1. Check clock assignment: PIN_P11 should be 50 MHz clock
2. Verify I/O standard: 3.3-V LVTTL
3. Enable optimization: Assignments → Settings → Compiler Settings → Optimization Mode = "Performance (High Effort)"

### Issue: "Cannot find file"
**Solution:**
1. Verify all 5 design files are in the project directory
2. Project → Add/Remove Files → Add missing files
3. Check file paths in .qsf are relative (not absolute)

### Issue: "USB-Blaster not detected"
**Solution:**
1. Reinstall USB-Blaster driver
2. Check USB cable connection
3. Try different USB port
4. Verify board power LED is on

---

## File Hierarchy in Quartus

When you open the project, the hierarchy should look like:

```
📁 Lab7LED (Project)
└── 📄 de10_lite_wrapper (Top-level)
    └── 📄 ws2812_fade_top
        ├── 📄 color_memory
        ├── 📄 fading_controller
        └── 📄 ws2812_driver_rgb
```

**To view hierarchy:**
- Processing → Start → Start Analysis & Elaboration
- Then: View → Utility Windows → Project Navigator → Hierarchy

---

## Verification Checklist

Before programming the FPGA:

- [ ] Top-level entity = `de10_lite_wrapper`
- [ ] All 5 design files added to project
- [ ] Pin assignments imported from .qsf
- [ ] Device = 10M50DAF484C7G
- [ ] Compilation successful (no errors)
- [ ] Timing analysis passed
- [ ] .sof file generated in output_files/

After programming:

- [ ] Power LED on DE10-Lite is lit
- [ ] WS2812 LED lights up
- [ ] Colors cycle: White → Red → Off → Green → Teal
- [ ] Transitions are smooth (~3 seconds each)
- [ ] KEY[0] resets to White

---

## Quick Reference

### Compile Command
```
Processing → Start Compilation (Ctrl+L)
```

### Program FPGA
```
Tools → Programmer → Start
```

### View Hierarchy
```
View → Utility Windows → Project Navigator → Hierarchy
```

### Assign Pins
```
Assignments → Pin Planner
```

### Check Timing
```
Tools → TimeQuest Timing Analyzer
```

---

## Output Files Location

After compilation, find these files in:
```
Lab7REd/output_files/
├── Lab7LED.sof          # FPGA programming file (SRAM)
├── Lab7LED.pof          # FPGA programming file (Flash)
├── Lab7LED.fit.rpt      # Fitter report
├── Lab7LED.sta.rpt      # Timing analysis report
└── Lab7LED.map.rpt      # Synthesis report
```

The `.sof` file is used for SRAM programming (temporary).
The `.pof` file is used for Flash programming (permanent).

For lab demonstration, use `.sof` (faster).

---

## Summary

**Simplest workflow:**
1. Open `Lab7LED.qpf` in Quartus
2. Press `Ctrl+L` to compile
3. Tools → Programmer → Start
4. Done! LED should be fading through colors

The `.qsf` file already has all settings configured correctly.
