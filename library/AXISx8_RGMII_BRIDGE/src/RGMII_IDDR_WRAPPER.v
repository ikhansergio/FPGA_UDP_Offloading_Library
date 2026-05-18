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

module RGMII_IDDR_WRAPPER
#(
parameter ARCH = "DEFAULT_LOGIC"        ,
parameter RX_CLK_BUFF_SCH_TYPE=1		,
parameter OVER_SAMPLING = "NO"          ,
parameter OPPOSITE_EDGE_LATCH_MODE = "NO"
)
(
input                CLK625MHZ,

input  wire          RGMII_RXC,
input  wire          RGMII_RX_CTL,
input  wire [4-1:0]  RGMII_RXD,

output wire          RGMII_RX_CLK,
output wire          RGMII_RX_CLK_Q1,
output wire          RGMII_RX_CLK_Q2,
output wire          RGMII_RX_CTL_Q1,
output wire          RGMII_RX_CTL_Q2,
output wire [8-1:0]  RGMII_RX_DATA_Q
);

wire        wRGMII_RX_CLK;
wire        wRGMII_RX_CLK_Q1;
wire        wRGMII_RX_CLK_Q2;
wire        wRGMII_RX_CTL_Q1;
wire        wRGMII_RX_CTL_Q2;
wire [7:0]  wRGMII_RX_DATA_Q;

(* KEEP_HIERARCHY = "TRUE" *)
RGMII_IDDR 
#(
.ARCH(ARCH),
.OVER_SAMPLING(OVER_SAMPLING),
.RX_CLK_BUFF_SCH_TYPE(RX_CLK_BUFF_SCH_TYPE)
)  RGMII_IDDR_INST
(
.CLK625MHZ          (CLK625MHZ),
.RGMII_RXC          (RGMII_RXC      ),
.RGMII_RX_CTL       (RGMII_RX_CTL   ),
.RGMII_RXD          (RGMII_RXD      ),

.RGMII_RX_CLK         (wRGMII_RX_CLK       ),
.RGMII_RX_CLK_Q1      (wRGMII_RX_CLK_Q1    ),
.RGMII_RX_CLK_Q2      (wRGMII_RX_CLK_Q2    ),
.RGMII_RX_CTL_Q1      (wRGMII_RX_CTL_Q1    ),
.RGMII_RX_CTL_Q2      (wRGMII_RX_CTL_Q2    ),
.RGMII_RX_DATA_Q      (wRGMII_RX_DATA_Q    )
);
 
generate 
if (OPPOSITE_EDGE_LATCH_MODE == "YES") 
    begin
    
    reg        rRGMII_RX_CLK_Q2;
    reg        rRGMII_RX_CTL_Q2;
    reg [3:0]  rRGMII_RX_DATA_Q;

    always @(posedge wRGMII_RX_CLK)
    begin 
    rRGMII_RX_CLK_Q2        <= wRGMII_RX_CLK_Q2;
    rRGMII_RX_CTL_Q2        <= wRGMII_RX_CTL_Q2;
    rRGMII_RX_DATA_Q        <= wRGMII_RX_DATA_Q[7:4];
    end    

    assign RGMII_RX_CLK        = wRGMII_RX_CLK;
    
    assign RGMII_RX_CLK_Q1     = rRGMII_RX_CLK_Q2;
    assign RGMII_RX_CLK_Q2     = wRGMII_RX_CLK_Q1;
    assign RGMII_RX_CTL_Q1     = rRGMII_RX_CTL_Q2;
    assign RGMII_RX_CTL_Q2     = wRGMII_RX_CTL_Q1;
    assign RGMII_RX_DATA_Q     = {wRGMII_RX_DATA_Q[3:0],rRGMII_RX_DATA_Q};
    end    
else      
    begin
    assign RGMII_RX_CLK        = wRGMII_RX_CLK;
    
    assign RGMII_RX_CLK_Q1     = wRGMII_RX_CLK_Q1;
    assign RGMII_RX_CLK_Q2     = wRGMII_RX_CLK_Q2;
    assign RGMII_RX_CTL_Q1     = wRGMII_RX_CTL_Q1;
    assign RGMII_RX_CTL_Q2     = wRGMII_RX_CTL_Q2;
    assign RGMII_RX_DATA_Q     = wRGMII_RX_DATA_Q;
    
    end    
	 
endgenerate

endmodule
