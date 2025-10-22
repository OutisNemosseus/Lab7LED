# Start simulation from beginning
vsim -gui work.top_board_adder4

# Add all waves to waveform diagram
add wave *

# Test case A=0, B=0
force A 0000
force B 0000
run 10

# Test case A=0, B=1
force A 0000
force B 0001
run 10

# Test case A=0, B=2
force A 0000
force B 0010
run 10
