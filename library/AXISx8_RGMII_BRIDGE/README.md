# AXISx8_RGMII_BRIDGE

AXISx8_RGMII_BRIDGE - Verilog library implementing 1000Base-T Ethernet PHY interfacing via RGMII interface.
# Parameters:
**RX_ARCH** - Supported architectures for RX path.

Valid values:
*     "XLX_ULTRASCALE", - Xilinx ULTRASCALE FPGAs
      "XLX_SERIES7", - Xilinx 7 Series FPGAs
      "DEFAULT_LOGIC",  - implementation on FPGA fabric

**TX_ARCH** - Supported architectures for TX path.

Valid values:
*     "XLX_ULTRASCALE", - Xilinx ULTRASCALE FPGAs
      "XLX_SERIES7", - Xilinx 7 Series FPGAs
      "DEFAULT_LOGIC",  - implementation on FPGA fabric

**OVER_SAMPLING** - Experimental feature.
	This feature was introduced due to rare but fatal design errors 
	that occur in process of developing the RGMII interface.
	In some designs, the RGMII_RXC clock from the PHY was connected to the CLK_n clock pin of the Xilinx FPGA,
	which cannot be used as a clock input in LVCMOS mode.
	If OVER_SAMPLING = "YES," the RGMII_RXC signal from the PHY is used not as a clock, but as another data line.
	The clock is an internal 625 MHz signal, received from the PLL inside the FPGA.
	The 625 MHz clock is completely asynchronous to the RGMII_RXC clock.
	The optimal eye diagram position is determined by the RGMII_RXC signal's edge positions.
	Received data is fed into an Elastic FIFO, from which the data stream can be read by a local 125 MHz clock.

Valid values:
*      "YES" or "NO"

**RX_CLK_BUFF_SCH_TYPE** - Possible methods for connecting clock buffers.
	For XLX_SERIES7 devices, there are several ways to connect the clock to the IDDR primitive.
	The IDDR primitive can be connected via BUFIO, BUFR, or BUFG.
	Each method has its pros and cons.
	Each connection type has its own differences in the length of the clock signal path from the pin to the IDDR register.
	For example: Working with the [Microchip KSZ9031RNX](https://www.microchip.com/en-us/product/KSZ9031) PHY, which has a default RXC signal delay of 1.2n after reset,
	experimentation revealed the following:

		On Spartan 7 devices, when connecting the RGMII to the HR port, schemes 0 and 3 proved to be optimal in terms of timing.
		These schemes use BUFIO and BUFR to connect the clock to the IDDR primitive.
		No manipulation of the MDIO registers in the PHY was required.
		IDELAYE2 primitives were also not used.
		Timing constraints were met by default settings.
	
		On Zynq 7000 devices, when connecting the RGMII to the HR port, only scheme 3 proved to be optimal in terms of timing.
		This scheme uses BUFR to connect the clock to the IDDR primitive.
		Also, no manipulation of the MDIO registers in the PHY was required.
		IDELAYE2 primitives were also not used.
		Timing constraints were met by default settings.

**RGMII_TXC_FRONT_POSITION** - The position of the TXC clock signal edge relative to the TX_Data eye diagram.
This parameter is needed only for control purposes, to exclude conflicting parameters. The user must specify how the TXC edge should be formed in relation to the eye diagram.

Valid values:
*      "EDGE_ALIGNED" or "CENTER_ALIGNED"

