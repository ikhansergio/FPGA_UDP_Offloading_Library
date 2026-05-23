Vivado 2023.1 is used

A simple UDP LoopBack example. Implemented on a custom Artix 7 board. The board uses the Microchip KSZ9031RNX PHY, connected to the HR port by the RGMII interface. No manipulation of the MDIO registers in the PHY was required. IDELAYE2 primitives were also not used. Timing constraints were met by default settings.
ARP and PING support has been implemented.

To create a project, run the command Tools->Run Tcl Script... and select "_Prj_Create.tcl" script
