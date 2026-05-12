`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.05.2026 11:23:56
// Design Name: 
// Module Name: AXISx32_InputChecker
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


module AXISx32_InputChecker
(
input wire [ 1-1:0] TLAST_IN,
input wire [ 4-1:0] TKEEP_IN,
input wire [32-1:0] TDATA_IN,

output wire [32-1:0] TDATA_OUT,
output wire [ 4-1:0] TKEEP_OUT,
output wire [ 4-1:0] COUNT_OUT
);
    
//////////////////////////////////////////////////////////////////////////////////////
wire [ 4-1:0]           wTKEEP;
wire [ 4-1:0]           wDATA_COUNT;

wire [32-1:0]           wTDATA;

assign wTKEEP  [ 4-1:0]  = { TKEEP_IN[3]&& TKEEP_OUT[2],TKEEP_IN[2]&&TKEEP_OUT[1], TKEEP_IN[1]&&TKEEP_OUT[0],TKEEP_IN[0]};

assign wDATA_COUNT  [ 4-1:0]  =  ((wTKEEP==4'b0001)&&TLAST_IN) ? 4'h1 :
                                 ((wTKEEP==4'b0011)&&TLAST_IN) ? 4'h2 :
                                 ((wTKEEP==4'b0111)&&TLAST_IN) ? 4'h3 :
                                 ((wTKEEP==4'b1111)&&TLAST_IN) ? 4'h4 :
                                 4'h4;
                                
                                
assign wTDATA [32-1:0]      =    ((wTKEEP==4'b0001)&&TLAST_IN) ? {24'h00,TDATA_IN[ 7:0]} :
                                 ((wTKEEP==4'b0011)&&TLAST_IN) ? {16'h00,TDATA_IN[15:0]} :
                                 ((wTKEEP==4'b0111)&&TLAST_IN) ? { 8'h00,TDATA_IN[23:0]} :
                                 ((wTKEEP==4'b1111)&&TLAST_IN) ?         TDATA_IN[31:0]  :
                                  TDATA_IN[31:0];
                                  

assign TDATA_OUT = wTDATA;
assign TKEEP_OUT = wTKEEP;
assign COUNT_OUT = wDATA_COUNT;                                       
endmodule
