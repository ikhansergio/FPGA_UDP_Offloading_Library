
set_property IOSTANDARD LVCMOS33 [get_ports EtheReset]
set_property PACKAGE_PIN L14 [get_ports EtheReset]

set_property IOSTANDARD LVCMOS33 [get_ports CLK_100MHZ]
set_property PACKAGE_PIN N12 [get_ports CLK_100MHZ]

set_property PACKAGE_PIN K13 [get_ports {Eth_TXD[0]}]
set_property PACKAGE_PIN J15 [get_ports {Eth_TXD[1]}]
set_property PACKAGE_PIN K14 [get_ports {Eth_TXD[2]}]
set_property PACKAGE_PIN K15 [get_ports {Eth_TXD[3]}]
set_property PACKAGE_PIN L15 [get_ports Eth_TX_CTL]
set_property PACKAGE_PIN L13 [get_ports Eth_TXC]

set_property IOSTANDARD LVCMOS33 [get_ports {Eth_TXD[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Eth_TXD[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Eth_TXD[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Eth_TXD[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports Eth_TX_CTL]
set_property IOSTANDARD LVCMOS33 [get_ports Eth_TXC]


set_property PACKAGE_PIN R11 [get_ports {Eth_RXD[0]}]
set_property PACKAGE_PIN R12 [get_ports {Eth_RXD[1]}]
set_property PACKAGE_PIN R13 [get_ports {Eth_RXD[2]}]
set_property PACKAGE_PIN R14 [get_ports {Eth_RXD[3]}]
set_property PACKAGE_PIN R10 [get_ports Eth_RX_CTL]
set_property PACKAGE_PIN P14 [get_ports Eth_RXC]

set_property IOSTANDARD LVCMOS33 [get_ports {Eth_RXD[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Eth_RXD[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Eth_RXD[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Eth_RXD[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports Eth_RX_CTL]
set_property IOSTANDARD LVCMOS33 [get_ports Eth_RXC]


set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_MODE SPIx1 [current_design]

set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR no [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 1 [current_design]
set_property BITSTREAM.CONFIG.M1PIN PULLDOWN [current_design]
set_property BITSTREAM.CONFIG.M2PIN PULLDOWN [current_design]
set_property BITSTREAM.CONFIG.M0PIN PULLUP [current_design]

set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]

set_property BITSTREAM.CONFIG.UNUSEDPIN PULLUP [current_design]

#set_property BITSTREAM.CONFIG.SPI_FALL_EDGE no [current_design]


#set_property BITSTREAM.CONFIG.PERSIST yes [current_design]
set_property BITSTREAM.CONFIG.CCLKPIN PULLUP [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS False [current_design]
set_property BITSTREAM.CONFIG.PROGPIN PULLUP [current_design]

