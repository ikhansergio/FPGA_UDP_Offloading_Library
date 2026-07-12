# AXISx8_UDP_Offloading_Engine

AXISx8_UDP_Offloading_Engine - Verilog library that implements the reception of Ethernet II packets, calculation of their CRC, MAC address control, IPv4 address control, UDP port control and control of checksums. ARP and ICMP PING functions are also implemented.
# Parameters:
**TxPortCount** - The number of AXI Stream ports used for data transmission via RGMII TX. AXISx8_UDP_Offloading_Engine has an internal scheduler for stream arbitration.

Valid values:
*      1, 2, 3, 4, 5 .. 9, 10

**NumberOf_RX_UDP_Ports** - The number of independent UDP ports used to receive UDP datagrams. Each port has an independent AXI Stream output.

Valid values:
*      1, 2, 3, 4, 5 .. 15, 16
 
**Has_ARP_Proc** - support for processing ARP requests.

Valid values:
*      "YES" or "NO"

**HasICMP_PING** - support for processing PING requests.

Valid values:
*      "YES" or "NO"

Block diagram :

<div align="center" > <img src="/docs/Drawio/generated/AXISx8_UDP_Offloading_Engine.svg" width="100%"/> </div>
