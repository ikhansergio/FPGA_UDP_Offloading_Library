# AXISx8_UDP_Framing_AXISx32_Sink

AXISx8_UDP_Framing_AXISx32_Sink - Verilog library that implements UDP datagram generation from an AXISx32 stream. IP automatically adds the MAC header, IP4 header, and UDP header, and calculates all necessary checksums.

# Parameters:
ARCH - Supported architectures.

Valid values:
*      "XLX_ULTRASCALE", - Xilinx ULTRASCALE FPGAs
*      "XLX_SERIES7", - Xilinx 7 Series FPGAs
*      "DEFAULT_LOGIC",  - implementation on FPGA fabric

PADDING_INSERTION -  Inserts padding for frames shorter than 64 bytes.

Valid values:
*      "YES" or "NO"
  
UDP_CHECKSUM_CALK -  Supports calculation of UDP datagram header checksum.

Valid values:
*      "YES" or "NO"
  
BUFFER_COUNT_1K -  UDP buffer size. This parameter specifies how many 1024-byte RAM blocks are required to build the entire buffer. For example, if you need an 8192-byte buffer, specify 8.

Valid values:
*      0, 1, 2, 3, .., 14, 15, 16.

      0 - 512 bytes Distributed RAM for Xilinx Devices are used.
      1 - 1024 bytes Block RAM are used.
      2 - 2048 bytes Block RAM are used.
      ...
      16 - 16384 bytes Block RAM are used.  
ETHERNET_MTU -  The standard Ethernet Maximum Transmission Unit (MTU) .

Valid values:
*      64 .. 16384

