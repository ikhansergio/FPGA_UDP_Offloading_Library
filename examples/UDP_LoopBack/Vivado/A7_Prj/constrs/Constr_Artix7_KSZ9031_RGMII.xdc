
create_clock -period 8.000 -name rgmii_Virtual -waveform {0.000 4.000}

create_clock -period 8.000 -name Eth_RXC -waveform {1.200 5.200} [get_ports Eth_RXC]

set_input_delay -clock rgmii_Virtual -min -add_delay -0.600 [get_ports {Eth_RX_CTL {Eth_RXD[3]} {Eth_RXD[2]} {Eth_RXD[1]} {Eth_RXD[0]}}]
set_input_delay -clock rgmii_Virtual -max -add_delay 0.600 [get_ports {Eth_RX_CTL {Eth_RXD[3]} {Eth_RXD[2]} {Eth_RXD[1]} {Eth_RXD[0]}}]
set_input_delay -clock rgmii_Virtual -clock_fall -min -add_delay -0.600 [get_ports {Eth_RX_CTL {Eth_RXD[3]} {Eth_RXD[2]} {Eth_RXD[1]} {Eth_RXD[0]}}]
set_input_delay -clock rgmii_Virtual -clock_fall -max -add_delay 0.600 [get_ports {Eth_RX_CTL {Eth_RXD[3]} {Eth_RXD[2]} {Eth_RXD[1]} {Eth_RXD[0]}}]

set_false_path -setup -fall_from [get_clocks rgmii_Virtual] -rise_to [get_clocks Eth_RXC]
set_false_path -setup -rise_from [get_clocks rgmii_Virtual] -fall_to [get_clocks Eth_RXC]
set_false_path -hold -fall_from [get_clocks rgmii_Virtual] -fall_to [get_clocks Eth_RXC]
set_false_path -hold -rise_from [get_clocks rgmii_Virtual] -rise_to [get_clocks Eth_RXC]


