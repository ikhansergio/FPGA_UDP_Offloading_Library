# Test

# SDC constraint for the KSZ9031 RGMII RX interface:
![RGMII RX](docs/WaveDrom/generated/KSZ9031_RGMII_RX.svg)

# SDC constraint for the KSZ9031 RGMII TX interface:
Generate the clock signals CLK_125MHZ and CLK_125MHZ_90 (a copy of CLK_125MHZ phase-shifted by 90 degrees) based on the reference signal CLK_100MHZ supplied by the board:
```
create_clock -period 10.000 -name CLK_100MHZ -waveform {0.000 5.000} [get_ports CLK_100MHZ]

create_generated_clock -name CLK_125MHZ    -source [get_pins Sys_Clk_PLL_inst/inst/mmcm_adv_inst/CLKIN1] -master_clock [get_clocks CLK_100MHZ] [get_pins Sys_Clk_PLL_inst/inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name CLK_125MHZ_90 -source [get_pins Sys_Clk_PLL_inst/inst/mmcm_adv_inst/CLKIN1] -master_clock [get_clocks CLK_100MHZ] [get_pins Sys_Clk_PLL_inst/inst/mmcm_adv_inst/CLKOUT1]
```

Generate the RGMII_TX_CLK_90 signal (a version of the CLK_125MHZ_90 signal at the FPGA output pin):
```
create_generated_clock -name RGMII_TX_CLK_90 -source [get_pins Sys_Clk_PLL_inst/inst/clk_out2] -multiply_by 1 [get_ports Eth_TXC]
```
The output delay for TXD is constrained for 1.0ns setup and 1.0ns hold time:
```
set_output_delay -clock RGMII_TX_CLK_90 -min -1.0 [get_ports {Eth_TXD[0] Eth_TXD[1] Eth_TXD[2] Eth_TXD[3] Eth_TX_CTL}] -add_delay
set_output_delay -clock RGMII_TX_CLK_90 -max 1.00 [get_ports {Eth_TXD[0] Eth_TXD[1] Eth_TXD[2] Eth_TXD[3] Eth_TX_CTL}] -add_delay
set_output_delay -clock RGMII_TX_CLK_90 -clock_fall -min -1.0 [get_ports {Eth_TXD[0] Eth_TXD[1] Eth_TXD[2] Eth_TXD[3] Eth_TX_CTL}] -add_delay
set_output_delay -clock RGMII_TX_CLK_90 -clock_fall -max 1.00 [get_ports {Eth_TXD[0] Eth_TXD[1] Eth_TXD[2] Eth_TXD[3] Eth_TX_CTL}] -add_delay
```
False path constraints to exclude cross-edge timing analysis:
```
set_false_path -rise_from [get_clocks CLK_125MHZ] -fall_to [get_clocks RGMII_TX_CLK_90] -setup
set_false_path -fall_from [get_clocks CLK_125MHZ] -rise_to [get_clocks RGMII_TX_CLK_90] -setup
set_false_path -rise_from [get_clocks CLK_125MHZ] -rise_to [get_clocks RGMII_TX_CLK_90] -hold
set_false_path -fall_from [get_clocks CLK_125MHZ] -fall_to [get_clocks RGMII_TX_CLK_90] -hold
```
![RGMII TX](docs/WaveDrom/generated/KSZ9031_RGMII_TX.svg)
