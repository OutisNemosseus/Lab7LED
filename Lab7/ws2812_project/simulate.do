#=============================================================================
# ModelSim Simulation Script
# WS2812 LED Driver - Lab 6
#
# Usage: In ModelSim, run: do simulate.do
#=============================================================================

# Quit any existing simulation
quit -sim

# Create work library
vlib work

# Compile all source files
vlog -sv Mapping.sv
vlog -sv BitSender.sv
vlog -sv ShiftRegister.sv
vlog -sv ShiftController.sv
vlog -sv LedDriver.sv
vlog -sv LedTestbench.sv

# Start simulation
vsim -t 1ns work.LedTestbench

# Add waves - Top level
add wave -divider "Clock and Reset"
add wave -format Logic /LedTestbench/clk
add wave -format Logic /LedTestbench/reset_n

add wave -divider "Inputs (RGB Switches)"
add wave -format Literal -radix unsigned /LedTestbench/red
add wave -format Literal -radix unsigned /LedTestbench/green
add wave -format Literal -radix unsigned /LedTestbench/blue

add wave -divider "WS2812 Output"
add wave -format Logic /LedTestbench/ws2812

# Add waves - Internal Signals (DUT)
add wave -divider "Mapped Colors (8-bit)"
add wave -format Literal -radix hexadecimal /LedTestbench/DUT/red_mapped
add wave -format Literal -radix hexadecimal /LedTestbench/DUT/green_mapped
add wave -format Literal -radix hexadecimal /LedTestbench/DUT/blue_mapped

add wave -divider "Combined GRB Data"
add wave -format Literal -radix hexadecimal /LedTestbench/DUT/color_data

# ShiftController internals
add wave -divider "ShiftController State"
add wave -format Literal /LedTestbench/DUT/u_shift_ctrl/state
add wave -format Literal -radix unsigned /LedTestbench/DUT/u_shift_ctrl/bit_counter
add wave -format Literal -radix unsigned /LedTestbench/DUT/u_shift_ctrl/reset_counter

# ShiftRegister internals
add wave -divider "ShiftRegister"
add wave -format Logic /LedTestbench/DUT/u_shift_ctrl/sr_load
add wave -format Logic /LedTestbench/DUT/u_shift_ctrl/sr_shift_en
add wave -format Literal -radix hexadecimal /LedTestbench/DUT/u_shift_ctrl/u_shift_reg/shift_reg
add wave -format Logic /LedTestbench/DUT/u_shift_ctrl/sr_bit_out

# BitSender internals
add wave -divider "BitSender"
add wave -format Literal /LedTestbench/DUT/u_shift_ctrl/u_bit_sender/state
add wave -format Logic /LedTestbench/DUT/u_shift_ctrl/bs_send
add wave -format Logic /LedTestbench/DUT/u_shift_ctrl/u_bit_sender/bit_latched
add wave -format Literal -radix unsigned /LedTestbench/DUT/u_shift_ctrl/u_bit_sender/counter
add wave -format Logic /LedTestbench/DUT/u_shift_ctrl/bs_done

# Configure wave window
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -timelineunits ns

# Run simulation
# First, run a short time to see a few bits
run 5us

# Zoom to fit
wave zoom full

# Print message
echo "============================================="
echo "Simulation running..."
echo "Use 'run 100us' to see a full 24-bit frame"
echo "Use 'run 200us' to see frame + reset"
echo "============================================="
