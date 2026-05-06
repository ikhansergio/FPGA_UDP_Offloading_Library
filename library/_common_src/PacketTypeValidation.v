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

module PacketTypeValidation
#(
parameter PackTypePattern = 1                        
)
(
	input  wire	                   CLK                     ,
	input  wire	                   Sink_TVALID             ,
	input  wire	                   Sink_TERROR             ,
	input  wire	                   Sink_TLAST              ,
	input  wire	[ 8-1:0]           Sink_TDATA              ,
	
	input  wire	[16-1:0]           PackTypeCode            ,

	output reg	                   Source_TVALID =0        ,
	output reg	                   Source_TFIRST =0        ,
	output reg	                   Source_TLAST  =0        ,
    output reg	                   Source_TERROR =0        ,
	output reg	[ 8-1:0]           Source_TDATA  =0
);

//////////////////////////////////////////////////////////////////////////////////////
// find the beginning of a package 
reg  TLAST_DONE_FLAG=1;
wire RX_TFIRST;
always @(posedge CLK) begin if (Sink_TVALID&&Sink_TLAST) TLAST_DONE_FLAG<=1; else if (Sink_TVALID) TLAST_DONE_FLAG<=0; end
assign RX_TFIRST =  TLAST_DONE_FLAG && Sink_TVALID ;
//////////////////////////////////////////////////////////////////////////////////////
reg         PackTypeValidFlag =0;

reg         RX_REG_TFIRST           =0;
reg         RX_REG_TVALID           =0;
reg         RX_REG_TERROR           =0;
reg         RX_REG_TLAST            =0;
reg [8-1:0] RX_REG_TDATA            =0;


always @(posedge CLK)
begin
if (TLAST_DONE_FLAG&&Sink_TVALID) PackTypeValidFlag    <=  (PackTypeCode == PackTypePattern);

RX_REG_TFIRST     <=	RX_TFIRST;
RX_REG_TVALID     <=    Sink_TVALID;
RX_REG_TERROR     <=    Sink_TERROR;
RX_REG_TLAST      <=    Sink_TLAST;
RX_REG_TDATA      <=    Sink_TDATA;

if (PackTypeValidFlag)  Source_TFIRST <= RX_REG_TFIRST;   else Source_TFIRST <=  0;
if (PackTypeValidFlag)  Source_TVALID <= RX_REG_TVALID;   else Source_TVALID <=  0;
if (PackTypeValidFlag)  Source_TLAST  <= RX_REG_TLAST;    else Source_TLAST  <=  0; 
if (PackTypeValidFlag)  Source_TERROR <= RX_REG_TERROR;   else Source_TERROR <=  0;  
if (PackTypeValidFlag)  Source_TDATA <=  RX_REG_TDATA;    else Source_TDATA  <=  0; 
end

endmodule
