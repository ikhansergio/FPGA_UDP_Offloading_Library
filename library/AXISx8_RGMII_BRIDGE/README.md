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
	In some PCB designs, the RGMII_RXC clock from the PHY was connected to the CLK_n clock pin of the Xilinx FPGA,
	which cannot be used as a clock input in LVCMOS mode.
	If OVER_SAMPLING = "YES," the RGMII_RXC signal from the PHY is used not as a clock, but as another data line.
	The clock is an internal 625 MHz signal, received from the PLL inside the FPGA.
	The 625 MHz clock is completely asynchronous to the RGMII_RXC clock.
	The optimal eye diagram position is determined by the RGMII_RXC signal's edge positions.
	Received data is fed into an Elastic FIFO, from which the data stream can be read by a local 125 MHz clock.

Valid values:
*      "YES" or "NO"

# [[...]](docs/RGMII_OVER_SAMPLING.md) -> OVER_SAMPLING mode description.

**RX_CLK_BUFF_SCH_TYPE** - Possible methods for connecting clock buffers.
	For XLX_SERIES7 devices, there are several ways to connect the clock to the IDDR primitive.
	The IDDR primitive can be connected via BUFIO, BUFR, or BUFG.
	Each method has its pros and cons.
	Each connection type has its own differences in the length of the clock signal path from the pin to the IDDR register.
	For example: Working with the [Microchip KSZ9031RNX](https://www.microchip.com/en-us/product/KSZ9031) PHY, which has a default RXC signal delay of 1.2n after reset,
	experimentation revealed the following:

>[!NOTE]
>On Spartan 7 devices in pair with Microchip KSZ9031RNX PHY, connected to the HR port by the RGMII interface, schemes 1, 2, 3, 4 proved to be optimal in terms of timing. These schemes use BUFIO and BUFR to connect the clock to the IDDR primitive.No manipulation of the MDIO registers in the PHY was required. IDELAYE2 primitives were also not used. Timing constraints were met by default settings.
>
>On Zynq 7000 and Artix 7 devices in pair with Microchip KSZ9031RNX PHY, connected to the HR port by the RGMII interface, only schemes 3, 4 proved to be optimal in terms of timing. This scheme uses BUFR to connect the clock to the IDDR primitive. Also, no manipulation of the MDIO registers in the PHY was required. IDELAYE2 primitives were also not used. Timing constraints were met by default settings.

Valid values:
*      0, 1, 2, 3, 4, 5, 6

	| RX_CLK_BUFF_SCH_TYPE | CLK_IDDR | CLK_FABRIC |
	| :---: | :---: | :---: |
	| 0 | AUTO | AUTO |
	| 1 | BUFIO | BUFR |
	| 2 | BUFIO | BUFG |
	| 3 | BUFR | BUFR |
	| 4 | BUFR | BUFG |
	| 5 | BUFG | BUFR |
	| 6 | BUFG | BUFG |

	Xilinx Ultrascale devices do not have BUFIO and BUFR primitives, so this parameter has no meaning for these devices.

**RGMII_TXC_FRONT_POSITION** - The position of the TXC clock signal edge relative to the TX_Data eye diagram.
This parameter is needed only for control purposes, to exclude conflicting parameters. The user must specify how the TXC edge should be formed in relation to the eye diagram.

Valid values:
*      "EDGE_ALIGNED" or "CENTER_ALIGNED"

**RGMII_TXD_REFERENCE_CLK** - A clock generator, used to generate data on the TXD bus.

Valid values:
*      "REFERENCE_PHY_RXC", "REFERENCE_125MHz"

**RGMII_TXC_REFERENCE_CLK** - A clock generator used to generate the TXC signal.

Valid values:
*      "REFERENCE_PHY_RXC", "REFERENCE_125MHz", "REFERENCE_125MHz_90"

> [!IMPORTANT]
> If the REFERENCE_PHY_RXC parameter is used, it is assumed that the user uses the PHY's RXC clock output to generate TXD data and the TXC clock. Depending on the PHY speed, the PHY automatically switches frequencies between 125 MHz, 25 MHz, and 2.5 MHz. With this configuration, the RGMII_TXC_FRONT_POSITION parameter must be set to "EDGE_ALIGNED." 
>
> If the REFERENCE_125MHz parameter is used, it is assumed that the user is using a local frequency of 125 MHz obtained from a crystal oscillator or PLL. Depending on the PHY speed, AXISx8_RGMII_BRIDGE automatically calculates the frequency division factors and controls the Sink_PHY_TREADY signal.

**Valid combinations:**

| The source clock used | RGMII_TXD_REFERENCE_CLK | RGMII_TXC_REFERENCE_CLK | RGMII_TXC_FRONT_POSITION |
| :--- | :---: | :---: | :---: |
| REFERENCE PHY RXC | "REFERENCE_PHY_RXC"  | "REFERENCE_PHY_RXC"  | "EDGE_ALIGNED"  |
| Local 125 MHz for TXD and TXC| "REFERENCE_125MHz" | "REFERENCE_125MHz" | "EDGE_ALIGNED" |
| Local 125 MHz for TXD and 125 MHz 90 degrees shifted for TXC | "REFERENCE_125MHz" | "REFERENCE_125MHz_90" | "CENTER_ALIGNED" |

	
# [[...]](docs/KSZ9031_Def_Constraint.md) -> SDC constraint example for the KSZ9031 in default mode.
