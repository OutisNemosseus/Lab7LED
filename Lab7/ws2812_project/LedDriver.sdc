#=============================================================================
# Synopsys Design Constraints (SDC) File
# WS2812 LED Driver - Lab 6
#=============================================================================

#-----------------------------------------------------------------------------
# Clock Definition
# 50MHz clock on DE10-Lite
#-----------------------------------------------------------------------------
create_clock -name clk -period 20.000 [get_ports clk]

#-----------------------------------------------------------------------------
# Clock Uncertainty
#-----------------------------------------------------------------------------
derive_clock_uncertainty

#-----------------------------------------------------------------------------
# Input/Output Delays
# These are relaxed constraints since WS2812 timing is handled internally
#-----------------------------------------------------------------------------
set_input_delay -clock clk -max 5 [get_ports {red[*] green[*] blue[*] reset_n}]
set_input_delay -clock clk -min 0 [get_ports {red[*] green[*] blue[*] reset_n}]

set_output_delay -clock clk -max 5 [get_ports ws2812]
set_output_delay -clock clk -min 0 [get_ports ws2812]

#-----------------------------------------------------------------------------
# False Paths
# Switch inputs are asynchronous
#-----------------------------------------------------------------------------
set_false_path -from [get_ports {red[*] green[*] blue[*]}]
set_false_path -from [get_ports reset_n]
