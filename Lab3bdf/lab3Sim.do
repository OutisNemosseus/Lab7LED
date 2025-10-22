# -------- sevenseg_tb.do（修正版）--------
onerror {resume}
if {[runStatus] ne ""} { quit -sim }

# 清空旧的 work 库
if {[file exists work]} { catch {vdel -all}; catch {file delete -force work} }
vlib work
vmap work work

# 编译当前目录下所有 Verilog 文件
vlog +acc *.v

# 查看编译结果
vdir work

# 启动仿真
vsim -gui -t ns -voptargs=+acc work.sevenSeg

# 添加波形（原内容不变）
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
add wave -radix bin sim:/sevenSeg/Sa
add wave -radix bin sim:/sevenSeg/Sb
add wave -radix bin sim:/sevenSeg/Sc
add wave -radix bin sim:/sevenSeg/Sd
add wave -radix bin sim:/sevenSeg/Se
add wave -radix bin sim:/sevenSeg/Sf
add wave -radix bin sim:/sevenSeg/Sg

restart -f
force -freeze sim:/sevenSeg/digit 4'h0 0ns
for {set i 1} {$i < 16} {incr i} {
    set t [expr {$i * 20}]
    force -freeze sim:/sevenSeg/digit [format "4'h%X" $i] ${t}ns
}
run 340 ns
wave zoom full
# -------- end --------
