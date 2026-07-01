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

module RGMII_RX_PHY
#(
parameter ARCH = "DEFAULT_LOGIC"                ,
parameter RX_CLK_BUFF_SCH_TYPE=1		        ,
parameter OVER_SAMPLING = "NO"
)
(
input   wire          CLK625MHZ                 ,

output  reg           RGMII_LINK_UP = 1'b0      ,
output  reg           RGMII_DUPLEX  = 1'b0      ,
output  reg  [2-1:0]  RGMII_SPEED   = 1'b0      ,

input   wire          RGMII_RXC                 ,
input   wire          RGMII_RX_CTL              ,
input   wire [4-1:0]  RGMII_RXD                 ,

output  wire          RGMII_RX_dCLK,
output  wire          RGMII_Rx_ValFlag          ,
output  wire          RGMII_Rx_Reset            ,
output  wire          RGMII_RX_CLK_EN           ,
output  reg           RGMII_RX_CTL_Q1 = 1'b0    ,
output  reg           RGMII_RX_CTL_Q2 = 1'b0    ,
output  reg  [8-1:0]  RGMII_RX_DATA_Q = 1'b0
);

wire          wRGMII_RX_dCLK;
wire          wRGMII_RX_CLK_EN;
wire          wRGMII_RX_CTL_Q1;
wire          wRGMII_RX_CTL_Q2;
wire [8-1:0]  wRGMII_RX_DATA_Q;

assign RGMII_RX_dCLK = wRGMII_RX_dCLK;

generate
if (OVER_SAMPLING == "YES") 
begin
RGMII_OverSampler 
#(
.ARCH(ARCH),
.OVER_SAMPLING(OVER_SAMPLING),
.RX_CLK_BUFF_SCH_TYPE(0),
.OPPOSITE_EDGE_LATCH_MODE("NO")
)RGMII_OverSampler_inst
(
.CLK625MHZ            (CLK625MHZ            ),

.RGMII_RXC            (RGMII_RXC            ),
.RGMII_RX_CTL         (RGMII_RX_CTL         ),
.RGMII_RXD            (RGMII_RXD            ),

.RGMII_RX_CLK         (wRGMII_RX_dCLK       ),
.RGMII_RX_CLK_EN      (wRGMII_RX_CLK_EN     ),
.RGMII_RX_CTL_Q1      (wRGMII_RX_CTL_Q1     ),
.RGMII_RX_CTL_Q2      (wRGMII_RX_CTL_Q2     ),
.RGMII_RX_DATA_Q      (wRGMII_RX_DATA_Q     )

);
end
else 
begin
(* KEEP_HIERARCHY = "TRUE" *)
RGMII_IDDR_WRAPPER 
#(
.ARCH(ARCH),
.OVER_SAMPLING(OVER_SAMPLING),
.RX_CLK_BUFF_SCH_TYPE(RX_CLK_BUFF_SCH_TYPE),
.OPPOSITE_EDGE_LATCH_MODE("NO")
)  RGMII_IDDR_WRAPPER_INST
(
.CLK625MHZ          (CLK625MHZ      ),

.RGMII_RXC          (RGMII_RXC      ),
.RGMII_RX_CTL       (RGMII_RX_CTL   ),
.RGMII_RXD          (RGMII_RXD      ),

.RGMII_RX_CLK         (wRGMII_RX_dCLK    ),
.RGMII_RX_CTL_Q1      (wRGMII_RX_CTL_Q1    ),
.RGMII_RX_CTL_Q2      (wRGMII_RX_CTL_Q2    ),
.RGMII_RX_DATA_Q      (wRGMII_RX_DATA_Q    )
);
assign wRGMII_RX_CLK_EN =1'b1;
end
endgenerate

reg [2:0] InBandStatusCounter=0;
reg [3:0] InBandStatusData=1'b0;

// if there are no valid data 4 clock ticks  packet is finished 
reg [3:0] NoRxDataState=0;

always @(posedge wRGMII_RX_dCLK)
begin
if (wRGMII_RX_CLK_EN) 
begin

if (wRGMII_RX_CTL_Q1) InBandStatusCounter<=3'h7; 
    else InBandStatusCounter <= InBandStatusCounter-1'b1;

if (InBandStatusCounter==3'h4) InBandStatusData <= wRGMII_RX_DATA_Q ;
 
if (InBandStatusCounter==3'h0) RGMII_LINK_UP <=InBandStatusData[0];
if (InBandStatusCounter==3'h0) RGMII_SPEED[0]<=InBandStatusData[1];
if (InBandStatusCounter==3'h0) RGMII_SPEED[1]<=InBandStatusData[2];
if (InBandStatusCounter==3'h0) RGMII_DUPLEX  <=InBandStatusData[3];
end
end

reg RGMII_Rx_LS_DivFlag=1'b1;


always @(posedge wRGMII_RX_dCLK)
begin
if (wRGMII_RX_CLK_EN) 
begin

NoRxDataState[3:0] <= {wRGMII_RX_CTL_Q1,NoRxDataState[3:1]};

if (RGMII_SPEED[1]==1'b1) RGMII_Rx_LS_DivFlag<=1;
    else if ((NoRxDataState==0)&&wRGMII_RX_CTL_Q1) RGMII_Rx_LS_DivFlag<=0;
        else RGMII_Rx_LS_DivFlag<=~RGMII_Rx_LS_DivFlag;
end        
end
assign RGMII_Rx_Reset = (NoRxDataState==0);    

assign  RGMII_Rx_ValFlag    = RGMII_Rx_LS_DivFlag ;// &&  wRGMII_RX_CLK_EN ;

always @(posedge wRGMII_RX_dCLK)
begin
if (wRGMII_RX_CLK_EN)RGMII_RX_DATA_Q <= wRGMII_RX_DATA_Q;
if (wRGMII_RX_CLK_EN)RGMII_RX_CTL_Q1 <= wRGMII_RX_CTL_Q1;
if (wRGMII_RX_CLK_EN)RGMII_RX_CTL_Q2 <= wRGMII_RX_CTL_Q2;
end

assign RGMII_RX_CLK_EN = wRGMII_RX_CLK_EN;

endmodule
