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

module RMII_RX_PHY
(
input   wire          RMII_REFERENCE_CLK50 ,
input   wire          RMII_CRS_DV          ,
input   wire [2-1:0]  RMII_RXD			,

output  wire Test
);

(* KEEP = "TRUE" *)reg 	     	DV_FrameFlag=0;
(* KEEP = "TRUE" *)reg [2-1:0]  RMII_RXD_reg=0;
(* KEEP = "TRUE" *)reg [6-1:0]  GapCounter=0;

(* KEEP = "TRUE" *)reg 		 	SyncWaitFlag =0;
(* KEEP = "TRUE" *)reg [2-1:0]  DivCounter=0;

(* KEEP = "TRUE" *)reg FirstStrobe=0;

always @(posedge RMII_REFERENCE_CLK50)
begin
if (RMII_CRS_DV)  GapCounter<= 39;
	else if (GapCounter!=0) GapCounter<=GapCounter-1;

if (RMII_CRS_DV)  DV_FrameFlag<= 1;
	else if (GapCounter==0) DV_FrameFlag<= 0;
	
if (RMII_CRS_DV) RMII_RXD_reg <= RMII_RXD;
	else RMII_RXD_reg <= 0;
	
if (RMII_CRS_DV&&(RMII_RXD==0)&&(GapCounter==0))  SyncWaitFlag<= 1;
	else if (RMII_CRS_DV&&(RMII_RXD!=0)) SyncWaitFlag<= 0;	
	
if (RMII_CRS_DV&&(RMII_RXD!=0)&&(GapCounter==0))  DivCounter<= 3;
	else if (RMII_CRS_DV&&(RMII_RXD!=0)&&SyncWaitFlag)  DivCounter<= 3;
		else DivCounter<= DivCounter -1;
			
if (RMII_CRS_DV&&(RMII_RXD!=0)&&(GapCounter==0))  FirstStrobe<= 1;
	else if (RMII_CRS_DV&&(RMII_RXD!=0)&&SyncWaitFlag)  FirstStrobe<= 1;
		else if (DivCounter==0) FirstStrobe<= 0;
end


assign Test = (|RMII_RXD_reg) || FirstStrobe ||  (|DivCounter) ||  DV_FrameFlag;


endmodule
