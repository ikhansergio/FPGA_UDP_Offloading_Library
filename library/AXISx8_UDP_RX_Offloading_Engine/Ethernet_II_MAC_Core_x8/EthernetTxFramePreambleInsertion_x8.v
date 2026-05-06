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

module EthernetTxFramePreambleInsertion_x8
(
	input   wire        clk,

    output  wire        PreambleInsertion_Sink_RDY, 
	input   wire        PreambleInsertion_Sink_Val, 
	input   wire        PreambleInsertion_Sink_EoF, 
	input   wire [7:0]  PreambleInsertion_Sink_Dat,
	
	input   wire        PreambleInsertion_Source_RDY,
	output 	wire        PreambleInsertion_Source_EoF,
    output 	wire        PreambleInsertion_Source_Val,
    output  wire [7:0]  PreambleInsertion_Source_Dat
);

//////////////////////////////////////////////////////////////////////////////////////
// find the beginning of a package 
reg  TLAST_DONE_FLAG=1;
wire PreambleInsertion_Sink_SoF;
always @(posedge clk) begin if (PreambleInsertion_Sink_Val&&PreambleInsertion_Sink_EoF&&PreambleInsertion_Source_RDY) TLAST_DONE_FLAG<=1; else if (PreambleInsertion_Sink_Val&&PreambleInsertion_Source_RDY) TLAST_DONE_FLAG<=0; end
assign PreambleInsertion_Sink_SoF=TLAST_DONE_FLAG&&PreambleInsertion_Sink_Val;
//////////////////////////////////////////////////////////////////////////////////////

assign PreambleInsertion_Sink_RDY = PreambleInsertion_Source_RDY;

reg [8*9-1:0] DatShiftReg = 0;

reg [  9-1:0] ValShiftReg = 0;
reg [  9-1:0] EoFShiftReg = 0;

always @(posedge clk) 
begin
if (PreambleInsertion_Sink_SoF&&PreambleInsertion_Source_RDY) DatShiftReg <= {PreambleInsertion_Sink_Dat,8'hD5,8'h55,8'h55,8'h55,8'h55,8'h55,8'h55,8'h55};
    else if (PreambleInsertion_Source_RDY)  DatShiftReg <= {PreambleInsertion_Sink_Dat,DatShiftReg[8*9-1:8]};
    
if (PreambleInsertion_Sink_SoF&&PreambleInsertion_Source_RDY) ValShiftReg <= 9'h1FF;
    else if (PreambleInsertion_Source_RDY)  ValShiftReg <= {PreambleInsertion_Sink_Val,ValShiftReg[9-1:1]};
    
if (PreambleInsertion_Sink_SoF&&PreambleInsertion_Source_RDY) EoFShiftReg <= 9'h000;
    else if (PreambleInsertion_Source_RDY)  EoFShiftReg <= {PreambleInsertion_Sink_EoF,EoFShiftReg[9-1:1]};
end

assign PreambleInsertion_Source_Dat = DatShiftReg[7:0];
assign PreambleInsertion_Source_EoF = EoFShiftReg[0];
assign PreambleInsertion_Source_Val = ValShiftReg[0];
    

endmodule
