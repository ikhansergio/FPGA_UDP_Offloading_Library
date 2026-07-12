
**OVER_SAMPLING** - Experimental feature.
	This feature was introduced due to rare but fatal design errors 
	that occur in process of developing the RGMII interface.
	In some PCB designs, the RGMII_RXC clock from the PHY was connected to the CLK_n clock pin of the Xilinx FPGA,
	which cannot be used as a clock input in LVCMOS mode.
	If OVER_SAMPLING = "YES," the RGMII_RXC signal from the PHY is used not as a clock, but as another data line.
	The clock is an internal 625 MHz signal, received from the PLL inside the FPGA.
	The 625 MHz clock is completely asynchronous to the RGMII_RXC clock.
	The optimal eye diagram position is determined by the RGMII_RXC signal's edge positions.
	Received data is fed into an Elastic FIFO, from which the data stream can be read by a local clock.


**The module assumes that the input data has an edge-aligned structure with respect to RXC. If the data is not edge-aligned with respect to RXC, it must be aligned using delays within the PHY or within the FPGA.**

Valid values:
*      "YES" or "NO"

This feature was tested with Xilinx Spartan 7 and Artix 7 Devices with speed grade of -2. The solution posibly works at a resampling frequency below 625 MHz,
but it has not yet been tested.


# Operating principle.

The module analyzes the RXC signal, attempting to detect rising and falling edges.
Since RXC is completely asynchronous with respect to the local 625 MHz clock, several scenarios are possible when detecting edges.

**Case A:** 
The rising and falling edges of the 625 MHz clock signal coincide with the high level of the RXC signal.

![RGMII_RX_OverSampler_CaseA](/docs/WaveDrom/generated/RGMII_RX_OverSampler_CaseA.svg)

**Case B:** 
The rising edge of the 625 MHz clock signal coincides with the low level of the RXC signal, and the falling edge coincides with the high level.

![RGMII_RX_OverSampler_CaseB](/docs/WaveDrom/generated/RGMII_RX_OverSampler_CaseB.svg)


Depending on the situation, the module's logic determines the optimal point in time from which to retrieve the latched data.
