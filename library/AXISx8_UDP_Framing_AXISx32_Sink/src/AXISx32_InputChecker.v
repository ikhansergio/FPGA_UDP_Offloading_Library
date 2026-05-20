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
module AXISx32_InputChecker
(
input  wire [ 1-1:0] Sink_TLAST,
input  wire [ 4-1:0] Sink_TKEEP,
input  wire [32-1:0] Sink_TDATA,

output wire [32-1:0] Source_TDATA,
output wire [ 4-1:0] Source_TKEEP,
output wire [ 4-1:0] Source_COUNT
);
    
//////////////////////////////////////////////////////////////////////////////////////
wire [ 4-1:0]           wTKEEP;
wire [ 4-1:0]           wDATA_COUNT;
wire [32-1:0]           wTDATA;

// validation of TKEEP
assign wTKEEP       [ 4-1:0]  =  ((Sink_TKEEP==4'b0000)&&Sink_TLAST) ? 4'hF :
                                 { Sink_TKEEP[3]&& wTKEEP[2],Sink_TKEEP[2]&&wTKEEP[1], Sink_TKEEP[1]&&wTKEEP[0],Sink_TKEEP[0]};

assign wDATA_COUNT  [ 4-1:0]  =  ((wTKEEP==4'b0001)&&Sink_TLAST) ? 4'h1 :
                                 ((wTKEEP==4'b0011)&&Sink_TLAST) ? 4'h2 :
                                 ((wTKEEP==4'b0111)&&Sink_TLAST) ? 4'h3 :
                                 ((wTKEEP==4'b1111)&&Sink_TLAST) ? 4'h4 :
                                 4'h4;
                                
                                
assign wTDATA [32-1:0]      =    ((wTKEEP==4'b0001)&&Sink_TLAST) ? {24'h00,Sink_TDATA[ 7:0]} :
                                 ((wTKEEP==4'b0011)&&Sink_TLAST) ? {16'h00,Sink_TDATA[15:0]} :
                                 ((wTKEEP==4'b0111)&&Sink_TLAST) ? { 8'h00,Sink_TDATA[23:0]} :
                                 ((wTKEEP==4'b1111)&&Sink_TLAST) ?         Sink_TDATA[31:0]  :
                                  Sink_TDATA[31:0];
                                  

assign Source_TDATA = wTDATA;
assign Source_TKEEP = wTKEEP;
assign Source_COUNT = wDATA_COUNT;     
                                  
endmodule
