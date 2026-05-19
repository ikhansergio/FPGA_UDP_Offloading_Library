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

module EthernetTxFrameFCSinsertion_x8
#(
parameter INIT_FF = 1,
parameter INPUT_REVERCEORDER = 1,
parameter INPUT_INVERCE = 0
)
(
	input              clk,

	output  wire       FCSinsertion_Sink_Rdy, 
	input   wire       FCSinsertion_Sink_Val, 
	input   wire       FCSinsertion_Sink_Err, 
	input   wire       FCSinsertion_Sink_EoF, 
	input   wire [7:0] FCSinsertion_Sink_Dat,
	
	input   wire       FCSinsertion_Source_Rdy,
	output 	reg        FCSinsertion_Source_Val=0,
	output 	reg        FCSinsertion_Source_Err=0,
	output 	reg        FCSinsertion_Source_EoF=0,
    output  reg [7:0]  FCSinsertion_Source_Dat=0
 );
 
`include "nextCRC32_D8_fcs.v"

assign FCSinsertion_Sink_Rdy = FCSinsertion_Source_Rdy;

reg  [31:0] crc;
wire [31:0] wCRC_out;
wire [7:0] wReverseBitOrder;
wire [7:0] wInverce;

wire [7:0] wINIT_Value;
assign wINIT_Value =   (INIT_FF) ?  8'hFF : 8'h00 ;
         
generate
   genvar j;
   
   for (j = 0;j < 32; j = j + 1) 
		begin : LOGIC_CRC_INVERSE0  
		assign wCRC_out[j] = ~crc[(32-1) - j];
		end
     
	if (INPUT_REVERCEORDER) 
	for (j = 0;j < 8;  j = j + 1) 
		begin : LOGIC_INPUT_REVERCEORDER_Y  
		assign wReverseBitOrder[j] = FCSinsertion_Sink_Dat[(8-1) - j]; 
		end
    else for (j = 0;j < 8;  j = j + 1) 
		begin : LOGIC_INPUT_REVERCEORDER_N  
		assign wReverseBitOrder[j] = FCSinsertion_Sink_Dat[j]; 
		end
   
	if (INPUT_INVERCE) 
	for (j = 0;j < 8;  j = j + 1) 
	begin : LOGIC_INPUT_INVERCE_Y
		assign wInverce[j] = ~wReverseBitOrder[ j]; 
	end
    else for (j = 0;j < 8;  j = j + 1)
		begin : LOGIC_INPUT_INVERCE_N
		assign wInverce[j] =  wReverseBitOrder[ j]; 
		end
endgenerate

// Counter for Valid extension
reg [2:0]FCS_ValCounter=0;

always @(posedge clk)
begin 
if (FCSinsertion_Sink_Val&&FCSinsertion_Source_Rdy) crc <= nextCRC32_D8(wInverce,crc);
    else if (FCSinsertion_Source_Rdy) crc <= {crc[23:0],wINIT_Value};
        
if (FCSinsertion_Sink_Val&FCSinsertion_Sink_EoF&FCSinsertion_Source_Rdy) FCS_ValCounter<=4;
    else if (FCS_ValCounter==0)  FCS_ValCounter<=FCS_ValCounter; 
        else if (FCSinsertion_Source_Rdy)  FCS_ValCounter<=FCS_ValCounter-1;

if (FCSinsertion_Source_Rdy) FCSinsertion_Source_Val<=FCSinsertion_Sink_Val||(FCS_ValCounter!=0);                 
if (FCSinsertion_Source_Rdy&&FCSinsertion_Sink_Val) FCSinsertion_Source_Dat<=FCSinsertion_Sink_Dat; else if (FCSinsertion_Source_Rdy) FCSinsertion_Source_Dat<=wCRC_out[7:0];    
if (FCSinsertion_Source_Rdy&&FCSinsertion_Sink_Val) FCSinsertion_Source_Err<=FCSinsertion_Sink_Err; else if (FCSinsertion_Source_Rdy) FCSinsertion_Source_Err<=1'b0; 

if (FCSinsertion_Source_Rdy) FCSinsertion_Source_EoF <= (FCS_ValCounter==1);
end 

endmodule