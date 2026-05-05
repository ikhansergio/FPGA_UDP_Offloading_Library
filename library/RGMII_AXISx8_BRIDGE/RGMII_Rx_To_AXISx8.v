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

module RGMII_Rx_To_AXISx8 
#(
parameter ARCH = "DEFAULT_LOGIC",
parameter OVER_SAMPLING = "NO"
)
(
input   wire            CLK625MHZ,

output  wire            RGMII_LINK_UP,
output  wire            RGMII_DUPLEX ,
output  wire  [2-1:0]   RGMII_SPEED  ,

input   wire            RGMII_RXC,
input   wire            RGMII_RX_CTL,
input   wire [4-1:0]    RGMII_RXD,

output  wire            Source_CLK,
output  reg             Source_TVALID = 1'b0,
output  reg             Source_TERROR = 1'b0,
output  reg             Source_TFIRST = 1'b0,
output  reg             Source_TLAST  = 1'b0,
output  reg  [8-1:0]    Source_TDATA  = 1'b0
);

wire wRGMII_Rx_ValFlag;
wire wRGMII_ResetPulse;

reg [2:0] InBandStatusCounter=0;
reg [3:0] InBandStatusData=1'b0;

wire          wRGMII_RX_CTL_Q1;
wire          wRGMII_RX_CTL_Q2;
wire [8-1:0]  wRGMII_DATA;

reg          RGMII_dSoF=1'b0;
reg          RGMII_dVAL=1'b0;
reg          RGMII_dErr=1'b0;
reg [8-1:0]  RGMII_DATA=1'b0;

(* KEEP_HIERARCHY = "TRUE" *)
RGMII_RX_PHY
#(.ARCH(ARCH),.OVER_SAMPLING(OVER_SAMPLING)) 
RGMII_RX_PHY_inst
(
.CLK625MHZ              (CLK625MHZ              ),

.RGMII_LINK_UP          (RGMII_LINK_UP          ),
.RGMII_DUPLEX           (RGMII_DUPLEX           ),
.RGMII_SPEED            (RGMII_SPEED            ),

.RGMII_RXC              (RGMII_RXC              ),
.RGMII_RX_CTL           (RGMII_RX_CTL           ),
.RGMII_RXD              (RGMII_RXD              ),

.RGMII_RX_dCLK          (Source_CLK             ),
.RGMII_Rx_ValFlag       (wRGMII_Rx_ValFlag      ),
.RGMII_Rx_Reset         (wRGMII_ResetPulse      ),
.RGMII_RX_CTL_Q1        (wRGMII_RX_CTL_Q1       ),
.RGMII_RX_CTL_Q2        (wRGMII_RX_CTL_Q2       ),
.RGMII_RX_DATA_Q        (wRGMII_DATA            )
);

reg RGMII_START_Condition=0;
reg RGMII_Rx_ValFlag=0;
always @(posedge Source_CLK)
begin
RGMII_START_Condition <= wRGMII_ResetPulse;
RGMII_Rx_ValFlag<=wRGMII_Rx_ValFlag;

if (RGMII_SPEED[1]==1'b1) 
begin
    RGMII_dSoF          <= (wRGMII_RX_CTL_Q1&&RGMII_START_Condition);
end else if (RGMII_SPEED[1]==1'b0) 
begin
    if  (wRGMII_RX_CTL_Q1&&RGMII_START_Condition) RGMII_dSoF  <= 1'b1;
        else if (RGMII_Rx_ValFlag==1) RGMII_dSoF  <= 1'b0;
end


if (RGMII_SPEED[1]==1'b1) 
begin
    RGMII_dVAL          <= wRGMII_RX_CTL_Q1;
    RGMII_dErr          <= wRGMII_RX_CTL_Q2;
    RGMII_DATA[7:0]     <= wRGMII_DATA[7:0];
end else if (RGMII_SPEED[1]==1'b0) 
begin
    if (wRGMII_Rx_ValFlag==0)
    begin
        RGMII_dVAL  <= wRGMII_RX_CTL_Q1;
        RGMII_dErr  <= RGMII_dErr;
        RGMII_DATA[3:0]  <= wRGMII_DATA[3:0];
    end 
    else if (wRGMII_Rx_ValFlag==1)
    begin
        RGMII_dVAL  <= RGMII_dVAL;
        RGMII_dErr  <= wRGMII_RX_CTL_Q1;
        RGMII_DATA[7:4]     <= wRGMII_DATA[3:0];
    end
end

    Source_TLAST            <= RGMII_dVAL&&RGMII_Rx_ValFlag&&!wRGMII_RX_CTL_Q1;
    Source_TFIRST           <= RGMII_dVAL&&RGMII_Rx_ValFlag&&RGMII_dSoF;
    Source_TVALID           <= RGMII_dVAL&&RGMII_Rx_ValFlag;
    if (RGMII_dVAL&&RGMII_Rx_ValFlag)   Source_TDATA <= RGMII_DATA;
        else if (RGMII_dVAL)   Source_TDATA <= Source_TDATA;
            else Source_TDATA <= 0;
    if (wRGMII_ResetPulse)Source_TERROR <= 1'b0; else Source_TERROR <= (RGMII_dVAL^RGMII_dErr)&&RGMII_Rx_ValFlag||Source_TERROR;
end

endmodule

