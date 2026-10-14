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

module AXISx8_To_GMII_MII_Tx
(
input   wire         GMII_MII_MODE_SELECT  ,
input   wire         GMII_TXCLK            ,
   
output  reg          GMII_TX_EN=0          ,
output  reg          GMII_TXERR=0          ,
output  reg  [8-1:0] GMII_TXD=0            ,

output  reg          GMII_TX_COL=0         ,
output  reg          GMII_TX_CRS=0         ,

output reg  		 Sink_TREADY=0         ,
input  wire          Sink_TVALID           ,
input  wire          Sink_TERROR           ,
input  wire          Sink_TFIRST           ,
input  wire          Sink_TLAST            ,
input  wire  [8-1:0] Sink_TDATA            ,
input  wire  [2-1:0] Sink_TUSER        
);

reg [3:0] MII_Hi_Data=0;

always @(posedge GMII_TXCLK)
begin
MII_Hi_Data <= Sink_TDATA[7:4]; 
if (GMII_MII_MODE_SELECT)
    begin
	Sink_TREADY 			        <= 1'b1;
	GMII_TX_EN   			        <= Sink_TVALID;
	GMII_TXERR				        <= Sink_TERROR;
	GMII_TXD				        <= Sink_TDATA;
	{GMII_TX_CRS,GMII_TX_COL} 	    <= Sink_TUSER;
	end
	else
	begin
	Sink_TREADY <= !Sink_TREADY;
	
	if (Sink_TREADY) GMII_TX_EN		             <= Sink_TVALID;
	if (Sink_TREADY) GMII_TXERR		             <= Sink_TERROR;
	if (Sink_TREADY) GMII_TXD		             <= {4'h0, Sink_TDATA [3:0]}; 
		else if (!Sink_TREADY) GMII_TXD		     <= {4'h0, MII_Hi_Data [3:0]}; 
	
	if (Sink_TREADY) {GMII_TX_CRS,GMII_TX_COL}   <= Sink_TUSER;
	
	end
end

endmodule
