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
