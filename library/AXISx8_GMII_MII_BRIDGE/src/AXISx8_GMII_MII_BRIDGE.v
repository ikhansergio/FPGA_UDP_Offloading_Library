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
input  wire         GMII_MII_MODE_SELECT  ,         
      
output wire         GMII_TXCLK,
output wire         GMII_RXCLK,

input  wire         GMII_CLK,

input  wire         GMII_RXDV,
input  wire         GMII_RXERR,
input  wire [8-1:0] GMII_RXD,

output wire         GMII_TX_EN,
output wire         GMII_TX_ERR,
output wire [8-1:0] GMII_TXD,   


output  wire         GMII_COL,
output  wire         GMII_CRS,

output wire          Source_TVALID         ,
output wire          Source_TERROR         ,
output wire          Source_TFIRST         ,
output wire          Source_TLAST          ,
output wire  [8-1:0] Source_TDATA    
);


(* KEEP_HIERARCHY = "TRUE" *)
GMII_MII_Rx_To_AXISx8		GMII_MII_Rx_To_AXISx8_inst
(
.GMII_MII_MODE_SELECT    (GMII_MII_MODE_SELECT	),
.GMII_RXCLK              (GMII_CLK				),   
.GMII_RXDV               (GMII_RXDV				),
.GMII_RXERR              (GMII_RXERR			),
.GMII_RXD                (GMII_RXD				),

.GMII_COL                (1'b0                  ),
.GMII_CRS                (1'b0                  ),

.Source_TVALID           (Source_TVALID         ),
.Source_TERROR           (Source_TERROR         ),
.Source_TFIRST           (Source_TFIRST         ),
.Source_TLAST            (Source_TLAST          ),
.Source_TDATA            (Source_TDATA          )
);





endmodule