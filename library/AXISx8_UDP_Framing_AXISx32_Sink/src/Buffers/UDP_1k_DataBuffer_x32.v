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

module UDP_1k_DataBuffer_x32
#(parameter ARCH = "XLX_ULTRASCALE")
(
input  wire                                 WrClk       ,
input  wire                                 WrEna       ,
input  wire [ 3:0]                          WrWea       ,
input  wire [RAM_AddrBitWidth(1*256)-1:0]   WrAddress   ,
input  wire [31:0]                          WrData      ,

input  wire                                 RdClk       ,
input  wire                                 RdEna       ,
input  wire [RAM_AddrBitWidth(1*256)-1:0]   RdAddress   ,
output reg  [31:0]                          RdData        
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

wire [31:0]   wRdData;
always @(posedge RdClk) if (RdEna) RdData <= wRdData;

(* KEEP_HIERARCHY = "TRUE" *)
X32_1k_DataBuffer #(.ARCH(ARCH)) X32_1k_DataBuffer_inst  
(
.WrClk             (WrClk           ),
.WrEna             (WrEna           ),
.WrWea             (WrWea           ),
.WrAddress         (WrAddress[ 7:0] ),
.WrData            (WrData          ),

.RdClk             (RdClk           ),
.RdEna             (RdEna           ),
.RdAddress         (RdAddress[ 7:0] ),
.RdData            (wRdData         )
);

endmodule
