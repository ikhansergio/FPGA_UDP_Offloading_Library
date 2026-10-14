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

module AXISx8_GMII_MII_BRIDGE
(
input  wire          GMII_MII_MODE_SELECT   ,         

input  wire          GMII_RXCLK             ,
input  wire          GMII_RXDV              ,
input  wire          GMII_RXERR             ,
input  wire [8-1:0]  GMII_RXD               ,
input  wire          GMII_RX_COL            ,
input  wire          GMII_RX_CRS            ,

input  wire          GMII_TXCLK             ,
output wire          GMII_TX_EN             ,
output wire          GMII_TXERR             ,
output wire [8-1:0]  GMII_TXD               ,   
output wire          GMII_TX_COL            ,
output wire          GMII_TX_CRS            ,

output wire  		 Sink_TREADY             ,
input  wire          Sink_TVALID            ,
input  wire          Sink_TERROR            ,
input  wire          Sink_TFIRST            ,
input  wire          Sink_TLAST             ,
input  wire  [8-1:0] Sink_TDATA             ,
input  wire  [2-1:0] Sink_TUSER             ,

output wire          Source_TVALID          ,
output wire          Source_TERROR          ,
output wire          Source_TFIRST          ,
output wire          Source_TLAST           ,
output wire  [8-1:0] Source_TDATA    
);


(* KEEP_HIERARCHY = "TRUE" *)
GMII_MII_Rx_To_AXISx8		GMII_MII_Rx_To_AXISx8_inst
(
.GMII_MII_MODE_SELECT    (GMII_MII_MODE_SELECT	),
.GMII_RXCLK              (GMII_RXCLK    		),   
.GMII_RXDV               (GMII_RXDV				),
.GMII_RXERR              (GMII_RXERR			),
.GMII_RXD                (GMII_RXD				),

.GMII_COL                (GMII_RX_COL           ),
.GMII_CRS                (GMII_RX_CRS           ),

.Source_TVALID           (Source_TVALID         ),
.Source_TERROR           (Source_TERROR         ),
.Source_TFIRST           (Source_TFIRST         ),
.Source_TLAST            (Source_TLAST          ),
.Source_TDATA            (Source_TDATA          )
);

(* KEEP_HIERARCHY = "TRUE" *)
AXISx8_To_GMII_MII_Tx   AXISx8_To_GMII_MII_Tx_inst
(
.GMII_MII_MODE_SELECT  (GMII_MII_MODE_SELECT    ),
.GMII_TXCLK            (GMII_TXCLK               ),
   
.GMII_TX_EN            (GMII_TX_EN              ),
.GMII_TXERR            (GMII_TXERR              ),
.GMII_TXD              (GMII_TXD                ),

.GMII_TX_COL           (GMII_TX_COL             ),
.GMII_TX_CRS           (GMII_TX_CRS             ),

.Sink_TREADY           (Sink_TREADY             ),
.Sink_TVALID           (Sink_TVALID             ),
.Sink_TERROR           (Sink_TERROR             ),
.Sink_TFIRST           (Sink_TFIRST             ),
.Sink_TLAST            (Sink_TLAST              ),
.Sink_TDATA            (Sink_TDATA              ),
.Sink_TUSER            (Sink_TUSER              )
);

endmodule