## HDMI out constraints file. Can be used in Arty-Z7-20, Pynq-Z1, and Pynq-Z2 since they share the same pinout

## Clock signal 125 MHz
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {clk}]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 6} [get_ports { clk }];

#reset mapped in other constraints file
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

set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports chaseLED]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports scatterLED]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports RetreatLED]
