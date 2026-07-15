`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
//MIT License

//Copyright (c) 2026 Sergio Batu    ikhan.sergio@gmail.com

//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
////////////////////////////////////////////////////////////////////////////////

// RGMII_SPEED==2'b00   10   Mhz
// RGMII_SPEED==2'b01   100  Mhz
// RGMII_SPEED==2'b10   1000 Mhz
// RGMII_SPEED==2'b11   Reserved

// ARCH - Supported architectures:
// "XLX_ULTRASCALE",   - Xilinx ULTRASCALE FPGAs
// "XLX_SERIES7",      - Xilinx 7 Series FPGAs
// "ALT_Cyclone10LP",  - Altera Cyclone10LP Series FPGAs
// "DEFAULT_LOGIC",    - implementation on FPGA fabric

module AXISx8_RGMII_BRIDGE
#(
parameter RX_ARCH = "DEFAULT_LOGIC" ,                       // "XLX_SERIES7", XLX_ULTRASCALE, "DEFAULT_LOGIC"
parameter TX_ARCH = "DEFAULT_LOGIC" ,                       // "XLX_SERIES7", XLX_ULTRASCALE, "DEFAULT_LOGIC"
parameter OVER_SAMPLING = "NO"      ,                       // "YES" or "NO"
parameter RX_CLK_BUFF_SCH_TYPE=1    ,                       
parameter RGMII_TXC_FRONT_POSITION = "EDGE_ALIGNED",        // EDGE_ALIGNED , CENTER_ALIGNED
parameter RGMII_TXD_REFERENCE_CLK  = "REFERENCE_PHY_RXC",   // REFERENCE_PHY_RXC, REFERENCE_125MHz
parameter RGMII_TXC_REFERENCE_CLK  = "REFERENCE_PHY_RXC"    // REFERENCE_PHY_RXC, REFERENCE_125MHz, REFERENCE_125MHz_90, REFERENCE_250MHz    
)
(
input   wire          CLK625MHZ             ,               // Used in OVER_SAMPLING mode. If not used - > tie to 1'b0.

output  wire          RGMII_LINK_UP         ,               // PHY InBand Status. Link is Up.
output  wire          RGMII_DUPLEX          ,               // PHY InBand Status. Duplex is enabled.
output  wire  [2-1:0] RGMII_SPEED           ,               // PHY InBand Status. Ethernet PHY speed.

input   wire          RGMII_TxClockSync     ,               // Low speed TxClock synchronization. Look description. If not used - > tie to 1'b0.
input   wire          RGMII_TXC_REFERENCE   ,               // Reference CLK for RGMII TXC signal
input   wire          RGMII_TXD_REFERENCE   ,               // Reference CLK for RGMII TXD signal

input   wire          RGMII_RXC             ,
input   wire          RGMII_RX_CTL          ,
input   wire [4-1:0]  RGMII_RXD             ,
output  wire          RGMII_TXC             ,
output  wire          RGMII_TX_CTL          ,
output  wire [4-1:0]  RGMII_TXD             ,

output wire           Source_PHY_CLK        ,
output wire           Source_PHY_TVALID     ,
output wire           Source_PHY_TERROR     ,
output wire           Source_PHY_TFIRST     ,
output wire           Source_PHY_TLAST      ,
output wire  [8-1:0]  Source_PHY_TDATA      ,

input  wire           Sink_PHY_TVALID       ,
input  wire           Sink_PHY_TERROR       ,
output wire           Sink_PHY_TREADY       ,
input  wire  [8-1:0]  Sink_PHY_TDATA
);

(* KEEP_HIERARCHY = "TRUE" *)
RGMII_Rx_To_AXISx8  
#(
.ARCH(RX_ARCH),
.OVER_SAMPLING(OVER_SAMPLING),
.RX_CLK_BUFF_SCH_TYPE(RX_CLK_BUFF_SCH_TYPE)
)  RGMII_Rx_To_AXISx8_Inst  
(
.CLK625MHZ                  (CLK625MHZ          ),

.RGMII_LINK_UP              (RGMII_LINK_UP      ),
.RGMII_DUPLEX               (RGMII_DUPLEX       ),
.RGMII_SPEED                (RGMII_SPEED        ),

.RGMII_RXC                  (RGMII_RXC          ),
.RGMII_RX_CTL               (RGMII_RX_CTL       ),
.RGMII_RXD                  (RGMII_RXD          ),

.Source_CLK                 (Source_PHY_CLK     ),
.Source_TVALID              (Source_PHY_TVALID  ),
.Source_TERROR              (Source_PHY_TERROR  ),
.Source_TFIRST              (Source_PHY_TFIRST  ),
.Source_TLAST               (Source_PHY_TLAST   ),
.Source_TDATA               (Source_PHY_TDATA   )
);

(* KEEP_HIERARCHY = "TRUE" *)
RGMII_TX_PHY 
#(
.ARCH(TX_ARCH),
.RGMII_TXC_FRONT_POSITION(RGMII_TXC_FRONT_POSITION  ),
.RGMII_TXC_REFERENCE_CLK(RGMII_TXC_REFERENCE_CLK    ),
.RGMII_TXD_REFERENCE_CLK(RGMII_TXD_REFERENCE_CLK    )
)  
RGMII_TX_PHY_INST
(
.RGMII_LINK_UP              (RGMII_LINK_UP              ),
.RGMII_SPEED                (RGMII_SPEED                ),

.RGMII_TxClockSync          (RGMII_TxClockSync          ),

.RGMII_TXC_REFERENCE        (RGMII_TXC_REFERENCE        ),
.RGMII_TXD_REFERENCE        (RGMII_TXD_REFERENCE        ),
.RGMII_TX_VAL               (Sink_PHY_TVALID            ),
.RGMII_TX_Err               (Sink_PHY_TERROR            ),
.RGMII_TX_DAT               (Sink_PHY_TDATA             ),
.RGMII_TX_RDY               (Sink_PHY_TREADY            ),

.RGMII_TXC                  (RGMII_TXC                  ),
.RGMII_TX_CTL               (RGMII_TX_CTL               ),
.RGMII_TXD                  (RGMII_TXD                  )
);

endmodule