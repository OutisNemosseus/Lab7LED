# ModelSim simulation script for complete WS2812 fade system
# Tests: ws2812_fade_top.sv (integrates all modules)
# This script demonstrates ONE FULL BLENDING CYCLE

# Create work library if it doesn't exist
vlib work

# Compile all source files
vlog -sv ../design/color_memory.sv
vlog -sv ../design/fading_controller.sv
vlog -sv ../design/ws2812_driver_rgb.sv
vlog -sv ../design/ws2812_fade_top.sv
vlog -sv ../testbench/tb_ws2812_fade_top.sv

# Start simulation
vsim -voptargs=+acc tb_ws2812_fade_top

# Add waves - Top Level
add wave -divider "=== TOP LEVEL SIGNALS ==="
add wave /tb_ws2812_fade_top/clk
add wave /tb_ws2812_fade_top/reset_n
add wave /tb_ws2812_fade_top/ws2812_out

add wave -divider "=== COLOR SEQUENCER ==="
add wave -unsigned /tb_ws2812_fade_top/dut/color_addr
add wave -hex /tb_ws2812_fade_top/dut/target_color
add wave -hex /tb_ws2812_fade_top/dut/current_color
add wave /tb_ws2812_fade_top/dut/transition_done

add wave -divider "=== FADING CONTROLLER ==="
add wave -unsigned /tb_ws2812_fade_top/dut/u_fading_controller/frame_counter
add wave -unsigned /tb_ws2812_fade_top/dut/u_fading_controller/cycle_counter
add wave -hex /tb_ws2812_fade_top/dut/u_fading_controller/start_color
add wave -hex /tb_ws2812_fade_top/dut/u_fading_controller/target_color_reg

add wave -divider "=== RGB CHANNELS ==="
add wave -hex /tb_ws2812_fade_top/dut/u_fading_controller/current_r
add wave -hex /tb_ws2812_fade_top/dut/u_fading_controller/current_g
add wave -hex /tb_ws2812_fade_top/dut/u_fading_controller/current_b

add wave -divider "=== WS2812 DRIVER ==="
add wave -hex /tb_ws2812_fade_top/dut/u_ws2812_driver/rgb_color
add wave -hex /tb_ws2812_fade_top/dut/u_ws2812_driver/grb_color
add wave -unsigned /tb_ws2812_fade_top/dut/u_ws2812_driver/bit_idx
add wave /tb_ws2812_fade_top/dut/u_ws2812_driver/state
add wave /tb_ws2812_fade_top/dut/u_ws2812_driver/ws2812_data

# Configure wave window
configure wave -namecolwidth 300
configure wave -valuecolwidth 100
configure wave -timelineunits us

# Run simulation
run -all

# Zoom to fit
wave zoom full

# Print summary
echo "========================================="
echo "Simulation Complete!"
echo "Check the transcript for test results"
echo "========================================="
