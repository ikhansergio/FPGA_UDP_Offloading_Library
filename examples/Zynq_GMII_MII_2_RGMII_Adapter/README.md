**Zynq_GMII_MII_2_RGMII_Adapter Project** - An example project that demonstrates how to use a library to convert a Zynq system's GMII/MII interface (via EMIO) into an RGMII interface.

If the 90-degree phase shift in the TXC output clock is implemented using a PLL, then 125 MHz clock signals with phases of 0 and 90 degrees must be supplied to the RGMII_TXD_REFERENCE and RGMII_TXC_REFERENCE inputs.

Specify: 
*     RGMII_TXD_REFERENCE_CLK = "REFERENCE_125MHz"
      RGMII_TXC_REFERENCE_CLK = "REFERENCE_125MHz_90"
  
<div align="center" > <img src="/docs/Drawio/generated/Example_Project_Zynq_GMII_MII_2_RGMII_Adapter_External_PLL.svg" width="50%"/> </div>

If the Ethernet PHY does not require a 90-degree phase shift on the TXC clock or if this clock shift is instead implemented via an ODELAY primitive or by increasing the trace length on the PCB - then an external PLL is not required. The RXC signal, provided by the PHY, can be used as the clock source. To achieve this, connect RGMII_RXC_OUT to both the RGMII_TXD_REFERENCE and RGMII_TXC_REFERENCE inputs. 

Specify: 

*     RGMII_TXD_REFERENCE_CLK = "REFERENCE_PHY_RXC"
      RGMII_TXC_REFERENCE_CLK = "REFERENCE_PHY_RXC"

<div align="center" > <img src="/docs/Drawio/generated/Example_Project_Zynq_GMII_MII_2_RGMII_Adapter_RXC_LoopBack.svg" width="50%"/> </div>
