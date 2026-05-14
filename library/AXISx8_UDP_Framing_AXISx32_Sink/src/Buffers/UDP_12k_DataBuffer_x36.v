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

module UDP_12k_DataBuffer_x36
#(parameter ARCH = "XLX_ULTRASCALE")
(
input  wire                                 WrClk       ,
input  wire                                 WrEna       ,
input  wire [ 3:0]                          WrWea       ,
input  wire [RAM_AddrBitWidth(16*256)-1:0]  WrAddress   ,
input  wire [31:0]                          WrData      ,

input  wire                                 RdClk       ,
input  wire                                 RdEna       ,
input  wire [RAM_AddrBitWidth(16*256)-1:0]  RdAddress   ,
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

wire [31:0]   wRdData0;
wire [31:0]   wRdData1;
wire [31:0]   wRdData2;

wire [ 4-1:0] wWrWeaBank0;
wire [ 4-1:0] wWrWeaBank1;
wire [ 4-1:0] wWrWeaBank2;
assign wWrWeaBank0  [ 4-1:0]  = (WrAddress[11:10]==2'b00) ? WrWea : 4'b0000; 
assign wWrWeaBank1  [ 4-1:0]  = (WrAddress[11:10]==2'b01) ? WrWea : 4'b0000; 
assign wWrWeaBank2  [ 4-1:0]  = (WrAddress[11:10]==2'b10) ? WrWea : 4'b0000; 

reg  [ 2-1:0] ReadBankSel_D0=0;
reg  [ 2-1:0] ReadBankSel_D1=0;

always @(posedge RdClk)
begin
if (RdEna) 
    begin
    ReadBankSel_D0 <= RdAddress[11:10];
    ReadBankSel_D1 <= ReadBankSel_D0;
    
    if (ReadBankSel_D1==2'b00) RdData <= wRdData0;
        else if (ReadBankSel_D1==2'b01) RdData <= wRdData1;
            else if (ReadBankSel_D1==2'b10) RdData <= wRdData2;
                else if (ReadBankSel_D1==2'b11) RdData <= 0;
    end
end

(* KEEP_HIERARCHY = "TRUE" *)
X32_4k_DataBuffer #(.ARCH(ARCH)) X32_4k_DataBuffer_inst0  
(
.WrClk             (WrClk               ),
.WrEna             (WrEna               ),
.WrWea             (wWrWeaBank0         ),
.WrAddress         (WrAddress[ 9:0]     ),
.WrData            (WrData              ),

.RdClk             (RdClk               ),
.RdEna             (RdEna               ),
.RdAddress         (RdAddress[ 9:0]     ),
.RdData            (wRdData0            )
);

(* KEEP_HIERARCHY = "TRUE" *)
X32_4k_DataBuffer #(.ARCH(ARCH)) X32_4k_DataBuffer_inst1  
(
.WrClk             (WrClk               ),
.WrEna             (WrEna               ),
.WrWea             (wWrWeaBank1         ),
.WrAddress         (WrAddress[ 9:0]     ),
.WrData            (WrData              ),

.RdClk             (RdClk               ),
.RdEna             (RdEna               ),
.RdAddress         (RdAddress[ 9:0]     ),
.RdData            (wRdData1            )
);

(* KEEP_HIERARCHY = "TRUE" *)
X32_4k_DataBuffer #(.ARCH(ARCH)) X32_4k_DataBuffer_inst2  
(
.WrClk             (WrClk               ),
.WrEna             (WrEna               ),
.WrWea             (wWrWeaBank2         ),
.WrAddress         (WrAddress[ 9:0]     ),
.WrData            (WrData              ),

.RdClk             (RdClk               ),
.RdEna             (RdEna               ),
.RdAddress         (RdAddress[ 9:0]     ),
.RdData            (wRdData2            )
);
endmodule
