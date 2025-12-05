# ModelSim simulation script for color_memory testbench
# Tests: color_memory.sv

# Create work library if it doesn't exist
vlib work

# Compile source files
vlog -sv color_memory.sv
vlog -sv tb_color_memory.sv

# Start simulation
vsim -voptargs=+acc tb_color_memory

# Add waves
add wave -divider "Testbench Signals"
add wave -hex /tb_color_memory/addr
add wave -hex /tb_color_memory/data_out

add wave -divider "DUT Internal"
add wave -hex /tb_color_memory/dut/*

# Run simulation
run -all

# Zoom to fit
wave zoom full
