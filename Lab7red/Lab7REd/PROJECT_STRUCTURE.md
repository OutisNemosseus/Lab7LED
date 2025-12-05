# Lab 7 Project Structure Guide

## ✅ Reorganization Complete!

The project has been reorganized into a clean, professional folder structure.

---

## 📁 Folder Structure

```
Lab7REd/
│
├── design/         ⭐ Design Files (5 .sv files)
│                      - Use these in Quartus
│                      - Use these in ModelSim
│
├── testbench/      ⭐ Testbenches (3 .sv files)
│                      - Only for ModelSim simulation
│                      - Do NOT include in Quartus
│
├── sim/            ⭐ Simulation Scripts (3 .do files)
│                      - Run these in ModelSim
│                      - cd sim/ first!
│
├── quartus/        ⭐ Quartus Project (2 files)
│                      - Open Lab7LED.qpf here
│                      - Already configured!
│
├── docs/           📖 Documentation (4 files)
│                      - README.md - Full docs
│                      - TESTBENCH_GUIDE.md - Test guide
│                      - QUARTUS_SETUP.md - Setup guide
│                      - Lab assignment .docx
│
├── legacy/         🗄️ Old Files (2 .sv files)
│                      - Not used anymore
│                      - Kept for reference
│
└── README.md       📋 Main project README
```

---

## 🎯 What Files to Use Where

### For Quartus Compilation

**Open:** `quartus/Lab7LED.qpf`

**Includes these files automatically:**
- design/de10_lite_wrapper.sv (top-level)
- design/ws2812_fade_top.sv
- design/fading_controller.sv
- design/color_memory.sv
- design/ws2812_driver_rgb.sv

**Do NOT include:**
- testbench/*.sv files
- sim/*.do files
- legacy/*.sv files

---

### For ModelSim Simulation

**Navigate to:** `sim/` directory

**Run one of:**
```bash
vsim -do sim_color_memory.do
vsim -do sim_fading_controller.do
vsim -do sim_ws2812_fade_top.do    # ← Main test for TA
```

**Each .do script automatically compiles:**
- Required files from design/
- Required files from testbench/

---

## 🔄 What Changed

### Before (Messy):
```
Lab7REd/
├── color_memory.sv
├── de10_lite_wrapper.sv
├── fading_controller.sv
├── ws2812_driver_rgb.sv
├── ws2812_fade_top.sv
├── tb_color_memory.sv
├── tb_fading_controller.sv
├── tb_ws2812_fade_top.sv
├── sim_color_memory.do
├── sim_fading_controller.do
├── sim_ws2812_fade_top.do
├── Lab7LED.qsf
├── README.md
├── TESTBENCH_GUIDE.md
└── ... all mixed together!
```

### After (Clean):
```
Lab7REd/
├── design/        (5 design files)
├── testbench/     (3 test files)
├── sim/           (3 .do scripts)
├── quartus/       (project files)
├── docs/          (documentation)
└── legacy/        (old files)
```

---

## ✅ Benefits

1. **Clear Organization**
   - Design files separate from tests
   - Documentation in one place
   - Easy to find what you need

2. **Professional Structure**
   - Standard industry practice
   - Makes sense to anyone reviewing
   - Ready for portfolio

3. **No Confusion**
   - Design files: design/
   - Test files: testbench/
   - Scripts: sim/
   - Docs: docs/

4. **Git Friendly**
   - All files properly tracked
   - Rename history preserved
   - Clean diff views

---

## 🚀 Updated Workflows

### Workflow 1: Run Simulation

**OLD way:**
```bash
vsim -do sim_ws2812_fade_top.do
(hope you're in right directory!)
```

**NEW way:**
```bash
cd sim
vsim -do sim_ws2812_fade_top.do
(clear intent!)
```

---

### Workflow 2: Open Quartus

**OLD way:**
```bash
quartus Lab7LED.qpf
(in messy root directory)
```

**NEW way:**
```bash
cd quartus
quartus Lab7LED.qpf
(clean project directory)
```

---

### Workflow 3: Read Documentation

**OLD way:**
```bash
# README.md mixed with code files
```

**NEW way:**
```bash
cd docs
# All docs in one place
open README.md
open TESTBENCH_GUIDE.md
open QUARTUS_SETUP.md
```

---

## 📝 File Paths Updated

### Quartus .qsf File
**Before:**
```tcl
set_global_assignment -name SYSTEMVERILOG_FILE color_memory.sv
```

**After:**
```tcl
set_global_assignment -name SYSTEMVERILOG_FILE ../design/color_memory.sv
```

### Simulation .do Files
**Before:**
```tcl
vlog -sv color_memory.sv
vlog -sv tb_color_memory.sv
```

**After:**
```tcl
vlog -sv ../design/color_memory.sv
vlog -sv ../testbench/tb_color_memory.sv
```

---

## 🎓 For TA Checkoff

**Show simulation:**
```bash
cd sim
vsim -do sim_ws2812_fade_top.do
```

**Show hardware:**
```bash
cd quartus
quartus Lab7LED.qpf
# Then compile and program
```

**Everything still works exactly the same!**
Just cleaner organization.

---

## 💡 Tips

1. **Always cd to the right directory first**
   - For simulation: `cd sim`
   - For Quartus: `cd quartus`
   - For docs: `cd docs`

2. **Paths are relative**
   - .do files use `../design/` and `../testbench/`
   - .qsf file uses `../design/`
   - Works from their respective directories

3. **Git tracks everything**
   - All moves preserved in history
   - Can see file evolution
   - Safe to reorganize

---

## 📊 File Count Summary

| Folder | Files | Purpose |
|--------|-------|---------|
| design/ | 5 | SystemVerilog design modules |
| testbench/ | 3 | SystemVerilog testbenches |
| sim/ | 3 | ModelSim .do scripts |
| quartus/ | 2 | Quartus project files |
| docs/ | 4 | Documentation & guides |
| legacy/ | 2 | Deprecated old files |
| **Total** | **19** | Clean & organized! |

---

## 🔗 GitHub

Repository: https://github.com/OutisNemosseus/Lab7LED

**Latest commit:**
- Reorganized into clean folder structure
- All paths updated
- All tests working
- Ready for checkoff!

---

## ❓ FAQ

**Q: Do I need to change anything in Quartus?**
A: No! The .qsf file already has correct paths. Just open and compile.

**Q: Will my old workflow still work?**
A: The commands are the same, just cd to the right folder first.

**Q: Where are my design files?**
A: All 5 SystemVerilog design files are in `design/`

**Q: Where are my testbenches?**
A: All 3 testbench files are in `testbench/`

**Q: Which .do file do I run for the TA?**
A: `sim/sim_ws2812_fade_top.do` - Shows full blending cycle

**Q: What's in the legacy folder?**
A: Old versions of files we don't use anymore. Kept for reference.

**Q: Can I delete the legacy folder?**
A: Yes, but it's small and might be useful for comparison.

---

## ✨ Summary

**Before:** 20+ files all mixed together in one folder
**After:** Clean 6-folder structure with clear purposes

**Result:** Professional, organized, easy to navigate! 🎉
