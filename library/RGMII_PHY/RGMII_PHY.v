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

module RGMII_PHY
#(
parameter RX_ARCH = "DEFAULT_LOGIC",
parameter TX_ARCH = "DEFAULT_LOGIC",
parameter OVER_SAMPLING = "NO",
parameter RGMII_TXC_FRONT_POSITION = "EDGE_ALIGNED",        // EDGE_ALIGNED , CENTER_ALIGNED
parameter RGMII_TXD_REFERENCE_CLK  = "REFERENCE_PHY_RXC",   // REFERENCE_PHY_RXC, REFERENCE_125MHz,
parameter RGMII_TXC_REFERENCE_CLK  = "REFERENCE_PHY_RXC"    // REFERENCE_PHY_RXC, REFERENCE_125MHz, REFERENCE_125MHz_90, REFERENCE_250MHz,    
)
(
input   wire          CLK625MHZ,

output  wire          RGMII_LINK_UP,
output  wire          RGMII_DUPLEX,
output  wire  [2-1:0] RGMII_SPEED,

input   wire          RGMII_RXC,
input   wire          RGMII_RX_CTL,
input   wire [4-1:0]  RGMII_RXD,
output  wire          RGMII_TXC,
output  wire          RGMII_TX_CTL,
output  wire [4-1:0]  RGMII_TXD,

output wire           Source_CLK    ,
output wire           Source_TVALID ,
output wire           Source_TERROR ,
output wire           Source_TFIRST ,
output wire           Source_TLAST  ,
output wire  [8-1:0]  Source_TDATA  ,

input   wire          RGMII_TxClockSync,
input   wire          RGMII_TXC_REFERENCE,
input   wire          RGMII_TXD_REFERENCE,
input   wire          Sink_TVALID,
input   wire          Sink_TERROR,
output  wire          Sink_TREADY,
input   wire [8-1:0]  Sink_TDATA
);


(* KEEP_HIERARCHY = "TRUE" *)
RGMII_Rx_To_AXISx8  
#(
.ARCH(RX_ARCH),
.OVER_SAMPLING(OVER_SAMPLING)
)  RGMII_Rx_To_AXISx8_Inst  
(
.CLK625MHZ                  (CLK625MHZ),

.RGMII_LINK_UP              (RGMII_LINK_UP),
.RGMII_DUPLEX               (RGMII_DUPLEX),
.RGMII_SPEED                (RGMII_SPEED),

.RGMII_RXC                  (RGMII_RXC),
.RGMII_RX_CTL               (RGMII_RX_CTL),
.RGMII_RXD                  (RGMII_RXD),

.Source_CLK                 (Source_CLK   ),
.Source_TVALID              (Source_TVALID),
.Source_TERROR              (Source_TERROR),
.Source_TFIRST              (Source_TFIRST),
.Source_TLAST               (Source_TLAST ),
.Source_TDATA               (Source_TDATA)
);



(* KEEP_HIERARCHY = "TRUE" *)
RGMII_TX_PHY 
#(
.ARCH(TX_ARCH),
.RGMII_TXC_FRONT_POSITION(RGMII_TXC_FRONT_POSITION),
.RGMII_TXC_REFERENCE_CLK(RGMII_TXC_REFERENCE_CLK),
.RGMII_TXD_REFERENCE_CLK(RGMII_TXD_REFERENCE_CLK)
)  
RGMII_TX_PHY_INST
(
.RGMII_LINK_UP              (RGMII_LINK_UP              ),
.RGMII_SPEED                (RGMII_SPEED                ),

.RGMII_TxClockSync          (RGMII_TxClockSync          ),

.RGMII_TXC_REFERENCE        (RGMII_TXC_REFERENCE        ),
.RGMII_TXD_REFERENCE        (RGMII_TXD_REFERENCE        ),
.RGMII_TX_VAL               (Sink_TVALID                ),
.RGMII_TX_Err               (Sink_TERROR                ),
.RGMII_TX_DAT               (Sink_TDATA                 ),
.RGMII_TX_RDY               (Sink_TREADY                ),

.RGMII_TXC                  (RGMII_TXC                  ),
.RGMII_TX_CTL               (RGMII_TX_CTL               ),
.RGMII_TXD                  (RGMII_TXD                  )
);






endmodule