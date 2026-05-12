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

    output  wire        Sink_RDY, 
	input   wire        Sink_Val,
	input   wire        Sink_Err, 
	input   wire        Sink_EoF, 
	input   wire [7:0]  Sink_Dat,
	
	input   wire        Source_RDY,
	output 	wire        Source_Val,
	output 	wire        Source_EoF,
    output 	wire        Source_Err,
    output  wire [7:0]  Source_Dat
);

//////////////////////////////////////////////////////////////////////////////////////
// find the beginning of a package 
reg  TLAST_DONE_FLAG=1;
wire PreambleInsertion_Sink_SoF;
always @(posedge clk) begin if (Sink_Val&&Sink_EoF&&Source_RDY) TLAST_DONE_FLAG<=1; else if (Sink_Val&&Source_RDY) TLAST_DONE_FLAG<=0; end
assign Sink_SoF=TLAST_DONE_FLAG&&Sink_Val;
//////////////////////////////////////////////////////////////////////////////////////

assign Sink_RDY = Source_RDY;

reg [8*9-1:0] DatShiftReg = 0;

reg [  9-1:0] ValShiftReg = 0;
reg [  9-1:0] ErrShiftReg = 0;
reg [  9-1:0] EoFShiftReg = 0;

always @(posedge clk) 
begin
if (Sink_SoF&&Source_RDY) DatShiftReg <= {Sink_Dat,8'hD5,8'h55,8'h55,8'h55,8'h55,8'h55,8'h55,8'h55};
    else if (Source_RDY)  DatShiftReg <= {Sink_Dat,DatShiftReg[8*9-1:8]};
    
if (Sink_SoF&&Source_RDY) ValShiftReg <= 9'h1FF;
    else if (Source_RDY)  ValShiftReg <= {Sink_Val,ValShiftReg[9-1:1]};
    
if (Sink_SoF&&Source_RDY) ErrShiftReg <= 9'h000;
    else if (Source_RDY)  ErrShiftReg <= {Sink_Err,ErrShiftReg[9-1:1]};
    
if (Sink_SoF&&Source_RDY) EoFShiftReg <= 9'h000;
    else if (Source_RDY)  EoFShiftReg <= {Sink_EoF,EoFShiftReg[9-1:1]};
end

assign Source_Dat = DatShiftReg[7:0];
assign Source_EoF = EoFShiftReg[0];
assign Source_Val = ValShiftReg[0];
assign Source_Err = ErrShiftReg[0];    

endmodule
