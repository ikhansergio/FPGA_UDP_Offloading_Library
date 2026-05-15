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

module DataBuffer_Fabric_X36
#(
parameter RAM_DEPTH = 256
)
(
input  wire                                     WrClk       ,
input  wire                                     WrEna       ,
input  wire                                     WrWea       ,
input  wire [RAM_AddrBitWidth(RAM_DEPTH)-1:0]   WrAddress   ,
input  wire [35:0]                              WrData      ,

input  wire                                     RdClk       ,
input  wire                                     RdEna       ,
input  wire [RAM_AddrBitWidth(RAM_DEPTH)-1:0]   RdAddress   ,
output reg  [35:0]                              RdData   
);

function integer RAM_AddrBitWidth (input integer Value);                  
    if (Value<3)
        begin
            RAM_AddrBitWidth = 1; 
        end
    else 
        begin
            Value=Value-1;                                                            
            for(RAM_AddrBitWidth=0; Value>0; RAM_AddrBitWidth=RAM_AddrBitWidth+1) Value = Value >> 1;                                                     
        end                                                          
endfunction 

localparam ADDR_WIDTH = RAM_AddrBitWidth(RAM_DEPTH);

reg [36-1:0] RAM_MEMORY [0:(2**ADDR_WIDTH)-1];


always @(posedge WrClk) 
begin
if (WrEna)
    begin
    if (WrWea) RAM_MEMORY[WrAddress] <= WrData;
    end
end


always @(posedge RdClk) 
begin
if (RdEna)
    begin
	RdData <=  RAM_MEMORY[RdAddress];
    end
end

endmodule
