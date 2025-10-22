vlib work
vlog fig286.sv tb_fig286.sv
vsim -voptargs=+acc tb_fig286
add wave -radix binary sim:/tb_fig286/A
add wave -radix binary sim:/tb_fig286/B
add wave -radix binary sim:/tb_fig286/C
add wave -radix binary sim:/tb_fig286/D
add wave -radix binary sim:/tb_fig286/Y
run 170 ns
