# ModelSim simulation script for fading_controller testbench
# Tests: fading_controller.sv

# Create work library if it doesn't exist
vlib work

# Compile source files
vlog -sv fading_controller.sv
vlog -sv tb_fading_controller.sv

# Start simulation
vsim -voptargs=+acc tb_fading_controller

# Add waves
add wave -divider "Clock and Reset"
add wave /tb_fading_controller/clk
add wave /tb_fading_controller/reset_n

add wave -divider "Controller Interface"
add wave -hex /tb_fading_controller/target_color
add wave -hex /tb_fading_controller/current_color
add wave /tb_fading_controller/transition_done

add wave -divider "DUT Internal - Counters"
add wave -unsigned /tb_fading_controller/dut/cycle_counter
add wave -unsigned /tb_fading_controller/dut/frame_counter

add wave -divider "DUT Internal - Colors"
add wave -hex /tb_fading_controller/dut/start_color
add wave -hex /tb_fading_controller/dut/target_color_reg

add wave -divider "DUT Internal - R Channel"
add wave -hex /tb_fading_controller/dut/start_r
add wave -hex /tb_fading_controller/dut/target_r
add wave -hex /tb_fading_controller/dut/current_r
add wave -decimal /tb_fading_controller/dut/delta_r
add wave -decimal /tb_fading_controller/dut/interp_r

add wave -divider "DUT Internal - G Channel"
add wave -hex /tb_fading_controller/dut/start_g
add wave -hex /tb_fading_controller/dut/target_g
add wave -hex /tb_fading_controller/dut/current_g
add wave -decimal /tb_fading_controller/dut/delta_g
add wave -decimal /tb_fading_controller/dut/interp_g

add wave -divider "DUT Internal - B Channel"
add wave -hex /tb_fading_controller/dut/start_b
add wave -hex /tb_fading_controller/dut/target_b
add wave -hex /tb_fading_controller/dut/current_b
add wave -decimal /tb_fading_controller/dut/delta_b
add wave -decimal /tb_fading_controller/dut/interp_b

# Run simulation
run -all

# Zoom to fit
wave zoom full
