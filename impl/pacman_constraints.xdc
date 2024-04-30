## Clock signal 125 MHz
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {clk}]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 6} [get_ports { clk }];

##Reset button
set_property -dict { PACKAGE_PIN J2   IOSTANDARD LVCMOS33 } [get_ports { rst }]; #IO_L4P_T0_35 Sch=btn[0]

##HDMI Tx
set_property -dict { PACKAGE_PIN T14   IOSTANDARD TMDS_33  } [get_ports { clk_n }]; #IO_L11N_T1_SRCC_35 Sch=hdmi_tx_clk_n
set_property -dict { PACKAGE_PIN R14   IOSTANDARD TMDS_33  } [get_ports { clk_p }]; #IO_L11P_T1_SRCC_35 Sch=hdmi_tx_clk_p
set_property -dict { PACKAGE_PIN T15   IOSTANDARD TMDS_33  } [get_ports { data_n[0] }]; #IO_L12N_T1_MRCC_35 Sch=hdmi_tx_d_n[0]
set_property -dict { PACKAGE_PIN R15   IOSTANDARD TMDS_33  } [get_ports { data_p[0] }]; #IO_L12P_T1_MRCC_35 Sch=hdmi_tx_d_p[0]
set_property -dict { PACKAGE_PIN R17   IOSTANDARD TMDS_33  } [get_ports { data_n[1] }]; #IO_L10N_T1_AD11N_35 Sch=hdmi_tx_d_n[1]
set_property -dict { PACKAGE_PIN R16   IOSTANDARD TMDS_33  } [get_ports { data_p[1] }]; #IO_L10P_T1_AD11P_35 Sch=hdmi_tx_d_p[1]
set_property -dict { PACKAGE_PIN P16   IOSTANDARD TMDS_33  } [get_ports { data_n[2] }]; #IO_L14N_T2_AD4N_SRCC_35 Sch=hdmi_tx_d_n[2]
set_property -dict { PACKAGE_PIN N15   IOSTANDARD TMDS_33  } [get_ports { data_p[2] }]; #IO_L14P_T2_AD4P_SRCC_35 Sch=hdmi_tx_d_p[2]
##set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_hpdn }]; #IO_0_34 Sch=hdmi_tx_hpdn
##set_property -dict { PACKAGE_PIN R11   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_cec }]; #IO_L19N_T3_VREF_35 Sch=hdmi_tx_cec

#LEDs showing Ghost state
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports chase_led]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports scatter_led]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports retreat_led]


#LEDs to register the right, left, up, and down inputs
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports led_right]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports led_left]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33} [get_ports led_up]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports led_down]

#Input Pins for external joystick buttons
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports left_raw]
set_property -dict {PACKAGE_PIN R5 IOSTANDARD LVCMOS33} [get_ports right_raw]
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports down_raw]
set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVCMOS33} [get_ports up_raw]
#******
#changed L/R/U/D (pins P5/R5/R6/T6) to onboard switches for testing purposes
#set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports left_raw]
#set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports right_raw]
#set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports down_raw]
#set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports up_raw]
#******

#On board button for score counter
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
