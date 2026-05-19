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

module EthernetRxFrameFCS_Check_x8
#(
parameter INIT_FF = 1,
parameter INPUT_REVERCEORDER = 1,
parameter INPUT_INVERCE = 0
)
(
	input              CLK,

	input   wire       FCS_Check_Sink_Val,
	input   wire       FCS_Check_Sink_MSK,  
	input   wire       FCS_Check_Sink_EoF,
	input   wire       FCS_Check_Sink_Err,  
	input   wire [7:0] FCS_Check_Sink_Dat,
	
	output 	reg        FCS_Check_Source_Val=0,
	output 	reg        FCS_Check_Source_EoF=0,
	output 	reg        FCS_Check_Source_Err=0,
    output  reg [7:0]  FCS_Check_Source_Dat=0
 );
 
 `include "nextCRC32_D8_fcs.v"
 
 //////////////////////////////////////////////////////////////////////////////////////
// find the beginning of a package 
reg  TLAST_DONE_FLAG=1;
wire FCS_Check_Sink_SoF;
always @(posedge CLK) begin if (FCS_Check_Sink_Val&&FCS_Check_Sink_EoF) TLAST_DONE_FLAG<=1; else if (FCS_Check_Sink_Val) TLAST_DONE_FLAG<=0; end
assign FCS_Check_Sink_SoF=TLAST_DONE_FLAG&&FCS_Check_Sink_Val;
//////////////////////////////////////////////////////////////////////////////////////
 
reg  [31:0] crc;
wire [31:0] wCRC_out;
wire [7:0] wReverseBitOrder;
wire [7:0] wInverce;

wire [7:0] wINIT_Value;
assign wINIT_Value =   (INIT_FF) ?  8'hFF : 8'h00 ;

reg [24-1:0]CRC_Delay0=0;
reg [16-1:0]CRC_Delay1=0;
reg [ 8-1:0]CRC_Delay2=0;

reg CRC_ErrorFlag0=0;     
reg CRC_ErrorFlag1=0;  
reg CRC_ErrorFlag2=0;  

reg CRC_ResetFlag=1;     
reg CRC_PacketRxBusy=0;                                         
                                                    
generate

   genvar j;
   
	for (j = 0;j < 32; j = j + 1) 
		begin : LOGIC_CRC_INVERSE0 
		assign wCRC_out[j] = ~crc[(32-1) - j]; 
		end
     
	if (INPUT_REVERCEORDER) 
	for (j = 0;j < 8;  j = j + 1) 
		begin : LOGIC_INPUT_REVERCEORDER_Y
		assign wReverseBitOrder[j] = FCS_Check_Sink_Dat[(8-1) - j]; 
		end
    else for (j = 0;j < 8;  j = j + 1) 
		begin : LOGIC_INPUT_REVERCEORDER_N  
		assign wReverseBitOrder[j] = FCS_Check_Sink_Dat[j]; 
		end
   
	if (INPUT_INVERCE) 
		for (j = 0;j < 8;  j = j + 1) 
		begin : LOGIC_CRC_INPUT_INVERCE_Y  
		assign wInverce[j] = ~wReverseBitOrder[ j]; 
		end
		else for (j = 0;j < 8;  j = j + 1) 
		begin : LOGIC_LOGIC_CRC_INPUT_INVERCE_N  
		assign wInverce[j] =  wReverseBitOrder[ j]; 
		end
endgenerate


always @(posedge CLK)
begin 
if (FCS_Check_Sink_SoF) CRC_PacketRxBusy<=1'b1;
    else if (FCS_Check_Sink_Val && FCS_Check_Sink_EoF) CRC_PacketRxBusy<=1'b0;


CRC_ResetFlag <= FCS_Check_Sink_Val && FCS_Check_Sink_EoF;


if (FCS_Check_Sink_Val) crc <= nextCRC32_D8(wInverce,crc);
    else if (CRC_ResetFlag) crc <= {wINIT_Value,wINIT_Value,wINIT_Value,wINIT_Value};
    
if (FCS_Check_Sink_Val) 
begin
CRC_Delay0[24-1:0]<= wCRC_out[32-1:8];
CRC_Delay1[16-1:0]<= CRC_Delay0[24-1:8];
CRC_Delay2[ 8-1:0]<= CRC_Delay1[16-1:8];
    
CRC_ErrorFlag0 <= !((wCRC_out  [ 8-1 :0]==FCS_Check_Sink_Dat));
CRC_ErrorFlag1 <= !((CRC_Delay0[ 8-1 :0]==FCS_Check_Sink_Dat)&&(!CRC_ErrorFlag0));
CRC_ErrorFlag2 <= !((CRC_Delay1[ 8-1 :0]==FCS_Check_Sink_Dat)&&(!CRC_ErrorFlag1));
FCS_Check_Source_Err <= (!((CRC_Delay2[ 8-1 :0]==FCS_Check_Sink_Dat)&&(!CRC_ErrorFlag2)))||FCS_Check_Sink_Err;
end 

FCS_Check_Source_Val<=FCS_Check_Sink_MSK;                 
if (FCS_Check_Sink_MSK) FCS_Check_Source_Dat<=FCS_Check_Sink_Dat;
    else if (CRC_PacketRxBusy==0) FCS_Check_Source_Dat<=0;    
FCS_Check_Source_EoF <= FCS_Check_Sink_EoF;
end 

endmodule