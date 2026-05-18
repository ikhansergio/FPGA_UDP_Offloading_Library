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

module DataBuffer_14k_x36
#(parameter ARCH = "XLX_ULTRASCALE")
(
input  wire                                 WrClk       ,
input  wire                                 WrEna       ,
input  wire [ 0:0]                          WrWea       ,
input  wire [RAM_AddrBitWidth(16*256)-1:0]  WrAddress   ,
input  wire [35:0]                          WrData      ,

input  wire                                 RdClk       ,
input  wire                                 RdEna       ,
input  wire [RAM_AddrBitWidth(16*256)-1:0]  RdAddress   ,
output reg  [35:0]                          RdData   
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

wire [35:0] wRdData0;
wire [35:0] wRdData1;
wire [35:0] wRdData2;

wire [ 0:0] wWrWeaBank0;
wire [ 0:0] wWrWeaBank1;
wire [ 0:0] wWrWeaBank2;

assign wWrWeaBank0  [ 0:0]  = (WrAddress[11:11]==1'b0   ) ? WrWea : 1'b0; 
assign wWrWeaBank1  [ 0:0]  = (WrAddress[11:10]==2'b10  ) ? WrWea : 1'b0; 
assign wWrWeaBank2  [ 0:0]  = (WrAddress[11: 9]==3'b110 ) ? WrWea : 1'b0; 

reg  [ 2:0] ReadBankSel_D0=0;
reg  [ 2:0] ReadBankSel_D1=0;

always @(posedge RdClk)
begin
if (RdEna) 
    begin
    ReadBankSel_D0 <= RdAddress[11:9];
    ReadBankSel_D1 <= ReadBankSel_D0;
    
    if (ReadBankSel_D1[2:0]==3'b000) RdData <= wRdData0;
        else if (ReadBankSel_D1[2:0]==3'b001) RdData <= wRdData0;
            else if (ReadBankSel_D1[2:0]==3'b010) RdData <= wRdData0;
                else if (ReadBankSel_D1[2:0]==3'b011) RdData <= wRdData0;
                    else if (ReadBankSel_D1[2:0]==3'b100) RdData <= wRdData1;
                        else if (ReadBankSel_D1[2:0]==3'b101) RdData <= wRdData1;
                            else if (ReadBankSel_D1[2:0]==3'b110) RdData <= wRdData2;
                                else if (ReadBankSel_D1[2:0]==3'b111) RdData <= 0;
    end
end

(* KEEP_HIERARCHY = "TRUE" *)
DataBuffer_BlockRAM_8k_X36 
#(
.ARCH(ARCH)
) DataBuffer_BlockRAM_8k_X36_inst  
(
.clka              (WrClk               ),
.ena               (WrEna               ),
.wea               (wWrWeaBank0         ),
.addra             (WrAddress[10:0]     ),
.dina              (WrData              ),

.clkb              (RdClk               ),
.enb               (RdEna               ),
.addrb             (RdAddress[10:0]     ),
.doutb             (wRdData0            )
);

(* KEEP_HIERARCHY = "TRUE" *)
DataBuffer_BlockRAM_4k_X36 
#(
.ARCH(ARCH)
) DataBuffer_BlockRAM_4k_X36_inst  
(
.clka              (WrClk               ),
.ena               (WrEna               ),
.wea               (wWrWeaBank1         ),
.addra             (WrAddress[ 9:0]     ),
.dina              (WrData              ),

.clkb              (RdClk               ),
.enb               (RdEna               ),
.addrb             (RdAddress[ 9:0]     ),
.doutb             (wRdData1            )
);

(* KEEP_HIERARCHY = "TRUE" *)
DataBuffer_BlockRAM_2k_X36 
#(
.ARCH(ARCH)
) DataBuffer_BlockRAM_2k_X36_inst  
(
.clka              (WrClk               ),
.ena               (WrEna               ),
.wea               (wWrWeaBank2         ),
.addra             (WrAddress[ 8:0]     ),
.dina              (WrData              ),

.clkb              (RdClk               ),
.enb               (RdEna               ),
.addrb             (RdAddress[ 8:0]     ),
.doutb             (wRdData2            )
);


endmodule
