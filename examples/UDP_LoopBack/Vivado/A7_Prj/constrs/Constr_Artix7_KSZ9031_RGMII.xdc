create_clock -period 10.000 -name CLK_100MHZ -waveform {0.000 5.000} [get_ports CLK_100MHZ]

create_clock -period 8.000 -name RGMII_VIRT  -waveform {0.000 4.000}

create_clock -period 8.000 -name RGMII_RXC -waveform {1.200 5.200} [get_ports RGMII_RXC]

set_input_delay -clock RGMII_VIRT  -min -add_delay -0.60 [get_ports {RGMII_RX_CTL {RGMII_RXD[3]} {RGMII_RXD[2]} {RGMII_RXD[1]} {RGMII_RXD[0]}}]
set_input_delay -clock RGMII_VIRT  -max -add_delay 0.600 [get_ports {RGMII_RX_CTL {RGMII_RXD[3]} {RGMII_RXD[2]} {RGMII_RXD[1]} {RGMII_RXD[0]}}]
set_input_delay -clock RGMII_VIRT  -clock_fall -min -add_delay -0.60 [get_ports {RGMII_RX_CTL {RGMII_RXD[3]} {RGMII_RXD[2]} {RGMII_RXD[1]} {RGMII_RXD[0]}}]
set_input_delay -clock RGMII_VIRT  -clock_fall -max -add_delay 0.600 [get_ports {RGMII_RX_CTL {RGMII_RXD[3]} {RGMII_RXD[2]} {RGMII_RXD[1]} {RGMII_RXD[0]}}]

set_false_path -setup -fall_from [get_clocks RGMII_VIRT ] -rise_to [get_clocks RGMII_RXC]
set_false_path -setup -rise_from [get_clocks RGMII_VIRT ] -fall_to [get_clocks RGMII_RXC]
set_false_path -hold -fall_from [get_clocks RGMII_VIRT ] -fall_to [get_clocks RGMII_RXC]
set_false_path -hold -rise_from [get_clocks RGMII_VIRT ] -rise_to [get_clocks RGMII_RXC]

create_generated_clock -name CLK_125MHZ    -source [get_pins Sys_Clk_PLL_inst/inst/mmcm_adv_inst/CLKIN1] -master_clock [get_clocks CLK_100MHZ] [get_pins Sys_Clk_PLL_inst/inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name CLK_125MHZ_90 -source [get_pins Sys_Clk_PLL_inst/inst/mmcm_adv_inst/CLKIN1] -master_clock [get_clocks CLK_100MHZ] [get_pins Sys_Clk_PLL_inst/inst/mmcm_adv_inst/CLKOUT1]

create_generated_clock -name RGMII_TX_CLK_90 -source [get_pins Sys_Clk_PLL_inst/inst/clk_out2] -multiply_by 1 [get_ports RGMII_TXC]

set_output_delay -clock RGMII_TX_CLK_90 -min -1.0 [get_ports {RGMII_TXD[0] RGMII_TXD[1] RGMII_TXD[2] RGMII_TXD[3] RGMII_TXC_CTL}] -add_delay
set_output_delay -clock RGMII_TX_CLK_90 -max 1.00 [get_ports {RGMII_TXD[0] RGMII_TXD[1] RGMII_TXD[2] RGMII_TXD[3] RGMII_TXC_CTL}] -add_delay
set_output_delay -clock RGMII_TX_CLK_90 -clock_fall -min -1.0 [get_ports {RGMII_TXD[0] RGMII_TXD[1] RGMII_TXD[2] RGMII_TXD[3] RGMII_TXC_CTL}] -add_delay
set_output_delay -clock RGMII_TX_CLK_90 -clock_fall -max 1.00 [get_ports {RGMII_TXD[0] RGMII_TXD[1] RGMII_TXD[2] RGMII_TXD[3] RGMII_TXC_CTL}] -add_delay

set_false_path -rise_from [get_clocks CLK_125MHZ] -fall_to [get_clocks RGMII_TX_CLK_90] -setup
set_false_path -fall_from [get_clocks CLK_125MHZ] -rise_to [get_clocks RGMII_TX_CLK_90] -setup
set_false_path -rise_from [get_clocks CLK_125MHZ] -rise_to [get_clocks RGMII_TX_CLK_90] -hold
set_false_path -fall_from [get_clocks CLK_125MHZ] -fall_to [get_clocks RGMII_TX_CLK_90] -hold