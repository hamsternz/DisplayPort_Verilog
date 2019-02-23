##Clock Signal
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports clk100]

set_property CFGBVS VCCO [current_design]

##Display Port
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVDS_25} [get_ports dp_tx_auxch_tx_n]
set_property -dict {PACKAGE_PIN AA9 IOSTANDARD LVDS_25} [get_ports dp_tx_auxch_tx_p]
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVDS_25} [get_ports dp_tx_auxch_rx_n]
set_property -dict {PACKAGE_PIN AA10 IOSTANDARD LVDS_25} [get_ports dp_tx_auxch_rx_p]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports dp_tx_hp_detect]
set_property -dict {PACKAGE_PIN F6} [get_ports dp_refclk_p]
set_property -dict {PACKAGE_PIN E6} [get_ports dp_refclk_n]
set_property -dict {PACKAGE_PIN F10} [get_ports mgtrefclk1_p]
set_property -dict {PACKAGE_PIN E10} [get_ports mgtrefclk1_n]

set_property -dict {PACKAGE_PIN B4} [get_ports {dp_tx_lane_p[0]}]
set_property -dict {PACKAGE_PIN A4}  [get_ports {dp_tx_lane_n[0]}]

set_property -dict {PACKAGE_PIN D5} [get_ports {dp_tx_lane_p[1]}]
set_property -dict {PACKAGE_PIN C5}  [get_ports {dp_tx_lane_n[1]}]


# DEBUG on JA
set_property -dict {PACKAGE_PIN AB22 IOSTANDARD LVCMOS33} [get_ports {debug[0]}]
set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS33} [get_ports {debug[1]}]
set_property -dict {PACKAGE_PIN AB20 IOSTANDARD LVCMOS33} [get_ports {debug[2]}]
set_property -dict {PACKAGE_PIN AB18 IOSTANDARD LVCMOS33} [get_ports {debug[3]}]
set_property -dict {PACKAGE_PIN Y21 IOSTANDARD LVCMOS33} [get_ports {debug[4]}]
set_property -dict {PACKAGE_PIN AA21 IOSTANDARD LVCMOS33} [get_ports {debug[5]}]
set_property -dict {PACKAGE_PIN AA20 IOSTANDARD LVCMOS33} [get_ports {debug[6]}]
set_property -dict {PACKAGE_PIN AA18 IOSTANDARD LVCMOS33} [get_ports {debug[7]}]


set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS25} [get_ports {LED[0]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS25} [get_ports {LED[1]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS25} [get_ports {LED[2]}]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS25} [get_ports {LED[3]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS25} [get_ports {LED[4]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS25} [get_ports {LED[5]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS25} [get_ports {LED[6]}]
set_property -dict {PACKAGE_PIN Y13 IOSTANDARD LVCMOS25} [get_ports {LED[7]}]


## Buttons
#set_property -dict { PACKAGE_PIN B22 IOSTANDARD LVCMOS33 } [get_ports { btnc }]; #IO_L20N_T3_16 Sch=btnc
#set_property -dict { PACKAGE_PIN D22 IOSTANDARD LVCMOS33 } [get_ports { btnd }]; #IO_L22N_T3_16 Sch=btnd
#set_property -dict { PACKAGE_PIN C22 IOSTANDARD LVCMOS33 } [get_ports { btnl }]; #IO_L20P_T3_16 Sch=btnl
#set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS33 } [get_ports { btnr }]; #IO_L6P_T0_16 Sch=btnr
#set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS33 } [get_ports { btnu }]; #IO_0_16 Sch=btnu
#set_property -dict { PACKAGE_PIN G4  IOSTANDARD LVCMOS33 } [get_ports { cpu_resetn }]; #IO_L12N_T1_MRCC_35 Sch=cpu_resetn


##Switches
set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS25} [get_ports {sw[0]}]
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS25} [get_ports {sw[1]}]
set_property -dict {PACKAGE_PIN G21 IOSTANDARD LVCMOS25} [get_ports {sw[2]}]
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS25} [get_ports {sw[3]}]
#set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS25} [get_ports {sw[4]}]
#set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS25} [get_ports {sw[5]}]
#set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS25} [get_ports {sw[6]}]
#set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS25} [get_ports {sw[7]}]



#create_clock -period 7.407 -name i_tx0/I -waveform {0.000 3.704} [get_pins i_tx0/gtpe2_i/TXOUTCLK]
#create_clock -period 7.407 -name i_tx0/ref_clk -waveform {0.000 3.704} [get_pins i_tx0/gtpe2_i/TXOUTCLKFABRIC]



create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk100]
create_clock -period 7.407 -name dp_refclk -waveform {0.000 3.704} -add [get_ports dp_refclk_p]
create_clock -period 7.407 -name dp_refclk2 -waveform {0.000 3.704} -add [get_ports mgtrefclk1_p]
