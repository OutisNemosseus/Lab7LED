# ======================================================
# DO: adder4_sim.do  (simulate work.Adder4 with waves)
# ======================================================

# 1) Build
vlib work
vmap work work
vlog +acc full_adder.v
vlog +acc Adder4.v

# 2) Simulate top of interest
vsim -gui work.Adder4

# 3) Add waves (show as Unsigned for easy reading)
add wave -radix unsigned A
add wave -radix unsigned B
add wave -radix unsigned Cin
add wave -radix unsigned Z
add wave -radix unsigned Cout
# Optional: 5-bit result (Cout·Z) as one bus
add wave -radix unsigned -label Sum5 {Cout Z}

# 初始小步运行，稳定组合逻辑
run 1ns

# 4) Test cases (每个运行 10ns)
# TC1: A=0, B=0, Cin=0 -> Sum=0, Cout=0
force A   4'b0000
force B   4'b0000
force Cin 1'b0
run 10ns

# TC2: A=3, B=1, Cin=1 -> Sum=5(0101), Cout=0
force A   4'b0011
force B   4'b0001
force Cin 1'b1
run 10ns

# TC3: A=7, B=8, Cin=0 -> Sum=15(1111), Cout=0
force A   4'b0111
force B   4'b1000
force Cin 1'b0
run 10ns

# TC4: A=9, B=7, Cin=0 -> Sum=0(0000), Cout=1
force A   4'b1001
force B   4'b0111
force Cin 1'b0
run 10ns

# TC5: A=15, B=15, Cin=1 -> Sum=31(11111), Cout=0
force A   4'b1111
force B   4'b1111
force Cin 1'b1
run 10ns

# 5) 自动缩放波形视图
# 看全局
wave zoom full
# 再放大到最后 60ns 区间（可按需调整）
set tnow [examine -radix decimal simtime]
set tstart [expr {$tnow - 60}]
if {$tstart < 0} { set tstart 0 }
wave zoom range ${tstart}ns ${tnow}ns
