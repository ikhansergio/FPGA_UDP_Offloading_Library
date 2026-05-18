# AXISx8_RGMII_BRIDGE

AXISx8_RGMII_BRIDGE - Verilog library implementing 1000Base-T Ethernet PHY interfacing via RGMII interface.
# Parameters:
RX_ARCH - Supported architectures for RX path.

Valid values:
*      "XLX_ULTRASCALE", - Xilinx ULTRASCALE FPGAs
*      "XLX_SERIES7", - Xilinx 7 Series FPGAs
*      "DEFAULT_LOGIC",  - implementation on FPGA fabric
TX_ARCH - Supported architectures for TX path.

Valid values:
*      "XLX_ULTRASCALE", - Xilinx ULTRASCALE FPGAs
*      "XLX_SERIES7", - Xilinx 7 Series FPGAs
*      "DEFAULT_LOGIC",  - implementation on FPGA fabric
OVER_SAMPLING - Experimental feature.
	This feature was introduced due to rare but fatal design errors 
	that occur in process of developing the RGMII interface.
	In some designs, the RGMII_RXC clock from the PHY was connected to the CLK_n clock pin of the Xilinx FPGA,
	which cannot be used as a clock input in LVCMOS mode.