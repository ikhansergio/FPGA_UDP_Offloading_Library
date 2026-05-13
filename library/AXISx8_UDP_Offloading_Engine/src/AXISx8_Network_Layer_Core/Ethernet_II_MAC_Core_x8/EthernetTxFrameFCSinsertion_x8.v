`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2025 11:25:51
// Design Name: 
// Module Name: EthernetTxFrameFCSinsertion
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

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
   
   for (j = 0;j < 32; j = j + 1) begin  assign wCRC_out[j] = ~crc[(32-1) - j]; end
     
   if (INPUT_REVERCEORDER) for (j = 0;j < 8;  j = j + 1) begin  assign wReverseBitOrder[j] = FCSinsertion_Sink_Dat[(8-1) - j]; end
    else for (j = 0;j < 8;  j = j + 1) begin  assign wReverseBitOrder[j] = FCSinsertion_Sink_Dat[j]; end
   
   if (INPUT_INVERCE) for (j = 0;j < 8;  j = j + 1) begin  assign wInverce[j] = ~wReverseBitOrder[ j]; end
    else for (j = 0;j < 8;  j = j + 1) begin  assign wInverce[j] =  wReverseBitOrder[ j]; end
   
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