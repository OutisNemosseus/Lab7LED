# -------- sevenseg_tb.do (for file: sevenSeg.v, top: sevenSeg) --------

# 1) 先确保没有占用库的仿真会话
onerror {resume}
if {[runStatus] ne ""} { quit -sim }

# 2) 清理/重建 work 库，避免 Windows 无法 unlink 的错误
if {[file exists work]} {
    catch {vdel -all}
    catch {file delete -force work}
}
vlib work
vmap work work

# 3) 编译你的 Verilog（+acc 便于探针到内部信号 Sa..Sg）
vlog +acc ./sevenSeg.v

# 4) 以 ns 为时间单位启动 GUI 仿真，顶层是模块名 sevenSeg
vsim -gui -t ns -voptargs=+acc work.sevenSeg

# ---- 波形窗口布置 ----
configure wave -timelineunits ns
quietly wave clear

add wave -divider {Inputs}
add wave -radix hex sim:/sevenSeg/digit

add wave -divider {Outputs (active-low)}
add wave -radix hex sim:/sevenSeg/segments
add wave -radix bin sim:/sevenSeg/segments\(6\)
add wave -radix bin sim:/sevenSeg/segments\(5\)
add wave -radix bin sim:/sevenSeg/segments\(4\)
add wave -radix bin sim:/sevenSeg/segments\(3\)
add wave -radix bin sim:/sevenSeg/segments\(2\)
add wave -radix bin sim:/sevenSeg/segments\(1\)
add wave -radix bin sim:/sevenSeg/segments\(0\)

add wave -divider {Internal "S*" (active-high before inversion)}
# 注意：只有当源码里真的定义了 Sa..Sg 这些 wire 时，这些 add wave 才会成功
add wave -radix bin sim:/sevenSeg/Sa
add wave -radix bin sim:/sevenSeg/Sb
add wave -radix bin sim:/sevenSeg/Sc
add wave -radix bin sim:/sevenSeg/Sd
add wave -radix bin sim:/sevenSeg/Se
add wave -radix bin sim:/sevenSeg/Sf
add wave -radix bin sim:/sevenSeg/Sg

# ---- 激励（0x0 到 0xF，每步 20ns）----
restart -f
force -freeze sim:/sevenSeg/digit 4'h0 0ns
for {set i 1} {$i < 16} {incr i} {
    set t [expr {$i * 20}]
    force -freeze sim:/sevenSeg/digit [format "4'h%X" $i] ${t}ns
}
run 340 ns
wave zoom full

# 可选：导出 VCD
# vcd file sevenseg_wave.vcd
# vcd add  sim:/sevenSeg/*
# vcd save
# -------- end --------
