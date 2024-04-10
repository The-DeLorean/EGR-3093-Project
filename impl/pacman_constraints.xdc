
# clk input is from the 100 MHz oscillator on Boolean board
#create_clock -period 10.000 -name gclk [get_ports clk_100MHz]

#clock made in other constraints file
#set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {clk}]


# On-board Buttons
# change from pin J2 (BTN0) to pin V2 (SW0)
#set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports {rst}]

#LED's to register the right, left, up, and down inputs
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports led_right]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports led_left]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33} [get_ports led_up]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports led_down]

# Input Pins for external joystick buttons
# change L/R/U/D (pins P5/R5/R6/T6) to onboard buttons for testing purposes
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports left_raw]
set_property -dict {PACKAGE_PIN R5 IOSTANDARD LVCMOS33} [get_ports right_raw]
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports down_raw]
set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVCMOS33} [get_ports up_raw]

#On board button for score counter
# Change to switch (SW15) to let onboard buttons be L/R/U/D
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports score_raw]

# On-board 7-Segment display 0
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports {name_anode[0]}]
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports {name_anode[1]}]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports {name_anode[2]}]
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports {name_anode[3]}]
set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS33} [get_ports {name_segment[0]}]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS33} [get_ports {name_segment[1]}]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS33} [get_ports {name_segment[2]}]
set_property -dict {PACKAGE_PIN B7 IOSTANDARD LVCMOS33} [get_ports {name_segment[3]}]
set_property -dict {PACKAGE_PIN A7 IOSTANDARD LVCMOS33} [get_ports {name_segment[4]}]
set_property -dict {PACKAGE_PIN D6 IOSTANDARD LVCMOS33} [get_ports {name_segment[5]}]
set_property -dict {PACKAGE_PIN B5 IOSTANDARD LVCMOS33} [get_ports {name_segment[6]}]
set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVCMOS33} [get_ports {name_segment[7]}]

# On-board 7-Segment display 0
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33} [get_ports {score_anode[0]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {score_anode[1]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {score_anode[2]}]
set_property -dict {PACKAGE_PIN E4 IOSTANDARD LVCMOS33} [get_ports {score_anode[3]}]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports {score_segment[0]}]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {score_segment[1]}]
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports {score_segment[2]}]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports {score_segment[3]}]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports {score_segment[4]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {score_segment[5]}]
set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS33} [get_ports {score_segment[6]}]
set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVCMOS33} [get_ports {score_segment[7]}]
