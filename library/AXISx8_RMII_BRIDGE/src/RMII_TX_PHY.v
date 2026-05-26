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

module RMII_TX_PHY
//#(
//parameter ARCH = "DEFAULT_LOGIC",
//parameter RGMII_InBandStatusEnabled = 0,
//parameter RGMII_TXC_FRONT_POSITION = "EDGE_ALIGNED"     ,   // EDGE_ALIGNED , CENTER_ALIGNED
//parameter RGMII_TXD_REFERENCE_CLK  = "REFERENCE_PHY_RXC",   // REFERENCE_PHY_RXC, REFERENCE_125MHz,
//parameter RGMII_TXC_REFERENCE_CLK  = "REFERENCE_PHY_RXC"    // REFERENCE_PHY_RXC, REFERENCE_125MHz, REFERENCE_125MHz_90, REFERENCE_250MHz,    
//)
(
input  wire           RMII_LINK_UP         ,
input  wire  [1-1:0]  RMII_SPEED           ,

input  wire           RMII_TxClockSync     ,

input   wire          RMII_REFERENCE_CLK50 ,

input   wire          Sink_PHY_TVALID      ,
input   wire [8-1:0]  Sink_PHY_TDATA       ,
output  reg           Sink_PHY_TREADY =1'b1,

output  wire          RMII_TX_EN           ,
output  wire [2-1:0]  RMII_TXD
);
(* KEEP = "TRUE" *) reg             RMII_SPEED_Flag     =0;
(* KEEP = "TRUE" *) reg             RMII_LINK_UP_Flag   =0;
(* KEEP = "TRUE" *) reg  [6-1:0]    SpeedCounter=3;

(* KEEP = "TRUE" *) wire [6-1:0]    wSpeedCounterThresold;


assign wSpeedCounterThresold = (RMII_SPEED_Flag == 1) ?  6'd3 : 6'd39 ;
          
always @(posedge RMII_REFERENCE_CLK50)
begin
// fixing the interface speed and link state during transmission
if (Sink_PHY_TVALID==0) RMII_SPEED_Flag     <= RMII_SPEED;
if (Sink_PHY_TVALID==0) RMII_LINK_UP_Flag   <= RMII_LINK_UP;

if (RMII_TxClockSync) SpeedCounter<=wSpeedCounterThresold;
    else if (SpeedCounter==0) SpeedCounter<=wSpeedCounterThresold;
        else SpeedCounter <= SpeedCounter - 1'b1; 
        

if (RMII_TxClockSync) Sink_PHY_TREADY<=1'b0;
    else if ((SpeedCounter==1)) Sink_PHY_TREADY<=1'b1;
        else if ((SpeedCounter!=1)) Sink_PHY_TREADY<=1'b0;
end

(* KEEP = "TRUE" *) reg          PHY_TVALID=0;
(* KEEP = "TRUE" *) reg [8-1:0]  PHY_TDATA =0;

(* KEEP = "TRUE" *) reg [4-1:0]  PHY_TVALID_SHIFT =0;
(* KEEP = "TRUE" *) reg [4-1:0]  PHY_TDATA_SHIFT1 =0;
(* KEEP = "TRUE" *) reg [4-1:0]  PHY_TDATA_SHIFT0 =0;

always @(posedge RMII_REFERENCE_CLK50)
begin
if (Sink_PHY_TREADY) 
    begin
    PHY_TVALID<=Sink_PHY_TVALID;
    if (Sink_PHY_TVALID) PHY_TDATA <=Sink_PHY_TDATA ;
        else  PHY_TDATA <=0 ;
    end
if (Sink_PHY_TREADY) 
    begin
    if (RMII_LINK_UP_Flag) PHY_TVALID_SHIFT <= {4{PHY_TVALID}};
    if (RMII_LINK_UP_Flag) PHY_TDATA_SHIFT1 <= {PHY_TDATA[7],PHY_TDATA[5],PHY_TDATA[3],PHY_TDATA[1]};
    if (RMII_LINK_UP_Flag) PHY_TDATA_SHIFT0 <= {PHY_TDATA[6],PHY_TDATA[4],PHY_TDATA[2],PHY_TDATA[0]};
    end else 
        begin
        if ((RMII_SPEED_Flag==1)||(SpeedCounter==0)||(SpeedCounter==10)||(SpeedCounter==20)||(SpeedCounter==30))
            begin
            PHY_TVALID_SHIFT[3:0] <= {1'b0,PHY_TVALID_SHIFT[3:1]};
            PHY_TDATA_SHIFT1[3:0] <= {1'b0,PHY_TDATA_SHIFT1[3:1]};
            PHY_TDATA_SHIFT0[3:0] <= {1'b0,PHY_TDATA_SHIFT0[3:1]};
            end
        end
end          

(* KEEP = "TRUE" *) (* IOB = "TRUE" *)  reg         RMII_TX_EN_REG=0;
(* KEEP = "TRUE" *) (* IOB = "TRUE" *)  reg [1:0]   RMII_TXD_REG  =0;
//  !!! negedge CLK for output timing 
always @(negedge RMII_REFERENCE_CLK50)
begin
RMII_TX_EN_REG  <=  PHY_TVALID_SHIFT[0];
RMII_TXD_REG    <= {PHY_TDATA_SHIFT1[0],PHY_TDATA_SHIFT0[0]};
end 

assign RMII_TX_EN = RMII_TX_EN_REG;
assign RMII_TXD   = RMII_TXD_REG;

endmodule