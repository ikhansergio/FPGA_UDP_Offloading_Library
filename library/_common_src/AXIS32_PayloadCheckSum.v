`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.05.2026 12:13:48
// Design Name: 
// Module Name: AXIS32_PayloadCheckSum
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


module AXIS32_PayloadCheckSum
(
input wire            CLK,
input wire   [ 1-1:0] TFIRST,
input wire   [ 1-1:0] TVALID,
input wire   [32-1:0] TDATA,
output reg   [32-1:0] CheckSUM=0
);

reg [32-1:0] CheckSUM_Data_L=0;
reg [32-1:0] CheckSUM_Data_H=0;

always @(posedge CLK)
begin

	if (TVALID&&TFIRST) CheckSUM_Data_L <= {16'h00,TDATA[16-1:0 ]}; 
		else if (TVALID) CheckSUM_Data_L <=CheckSUM_Data_L + {16'h00,TDATA[16-1:0 ]};   
		
	if (TVALID&&TFIRST) CheckSUM_Data_H <= {16'h00,TDATA[32-1:16]}; 
		else if (TVALID) CheckSUM_Data_H <=CheckSUM_Data_H + {16'h00,TDATA[32-1:16]};
			
	CheckSUM <=  CheckSUM_Data_L + CheckSUM_Data_H;
end

endmodule
