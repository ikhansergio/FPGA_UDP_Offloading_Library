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

module AXISx8_UDP_TG_Controller
(
    input                           CLK ,
    
    input [8-1:0]                   TDATA ,
    input                           TVALID,
    input                           TFIRST,
    input                           TLAST,
    input                           TERROR,
    
    output  reg                     TG_Start_Pulse=0,
    output  reg [32-1:0]            TG_PacketCount=0,
    output  reg [16-1:0]            TG_PacketSize=0, 
    output  reg [16-1:0]            TG_PacketGap=0     
                 
);



(* keep = "true" *) wire [8-1:0]                   wTDATA0 ;
(* keep = "true" *) wire                           wTVALID0;
(* keep = "true" *) wire                           wTLAST0 ;
(* keep = "true" *) wire                           wTERROR0;

(* keep = "true" *) wire [8-1:0]                   wTDATA1 ;
(* keep = "true" *) wire                           wTVALID1;
(* keep = "true" *) wire                           wTLAST1 ;
(* keep = "true" *) wire                           wTERROR1;

(* keep = "true" *) wire [32-1:0]                  wTDATA2 ;
(* keep = "true" *) wire                           wTFIRSTD2;
(* keep = "true" *) wire                           wTVALID2;
(* keep = "true" *) wire                           wTLAST2 ;
(* keep = "true" *) wire                           wTERROR2;

(* keep = "true" *) reg [7:0]Position=0;

(* KEEP_HIERARCHY = "TRUE" *)
EthernetRxFrameFCS_Check_x8  
#(
.INIT_FF(1),
.INPUT_REVERCEORDER(1),
.INPUT_INVERCE(0)
) TG_Controller_FCS_Check_x8_inst
(
.CLK                          (CLK),

.FCS_Check_Sink_Val           (TVALID   ), 
.FCS_Check_Sink_MSK           (TVALID   ),
.FCS_Check_Sink_EoF           (TLAST    ),
.FCS_Check_Sink_Err           (TERROR   ),
.FCS_Check_Sink_Dat           (TDATA    ),

.FCS_Check_Source_Val         (wTVALID0  ),
.FCS_Check_Source_EoF         (wTLAST0   ),
.FCS_Check_Source_Err         (wTERROR0  ),
.FCS_Check_Source_Dat         (wTDATA0   )
);


(* KEEP_HIERARCHY = "TRUE" *)
EthernetRxFrameFCS_Remover_x8      EthernetRxFrameFCS_Remover_x8_inst
(
.CLK                          (CLK      ),
.FCS_Remover_Sink_Val         (wTVALID0 ),
.FCS_Remover_Sink_EoF         (wTLAST0  ),
.FCS_Remover_Sink_Err         (wTERROR0 ),  
.FCS_Remover_Sink_Dat         (wTDATA0  ),

.FCS_Remover_Source_Val       (wTVALID1 ),
.FCS_Remover_Source_EoF       (wTLAST1  ),
.FCS_Remover_Source_Err       (wTERROR1 ),
.FCS_Remover_Source_Dat       (wTDATA1  )
 );

(* KEEP_HIERARCHY = "TRUE" *)
AXIS_Width_Up_Converter
#(
. BIT_WIDTH             (8),
. N                     (4),
. BIG_ENDIAN            (0),         
. TFIRST_ReSTORE        (1) 
) AXISx8_To_AXISx32_Width_Up_Converter_inst
(
           
. CLK                       (CLK),
 
. TFIRST                    (0),   
. TVALID                    (wTVALID1   ),
. TERROR                    (wTERROR1   ),
. TLAST                     (wTLAST1    ),       
. TDATA                     (wTDATA1    ),  

. TFIRST_OUT                (wTFIRSTD2  ),
. TVALID_OUT                (wTVALID2   ),
. TERROR_OUT                (wTERROR2   ), 
. TLAST_OUT                 (wTLAST2    ),
. TKEEP_OUT                 (           ),
. TDATA_OUT                 (wTDATA2    )
 );  


always @(posedge CLK)
begin
if (wTVALID2&&wTFIRSTD2) Position<=1;
    else if (wTVALID2) Position<=Position+1;
end

(* keep = "true" *) reg CommandCodeFlag =0;
(* keep = "true" *) reg MagicNumberFlag =0;
(* keep = "true" *) reg [15:0]PacketSize=0;
(* keep = "true" *) reg [15:0]PacketGap=0;
(* keep = "true" *) reg [31:0]PacketCount=0;

always @(posedge CLK)
begin
if (wTVALID2 && wTFIRSTD2       )  CommandCodeFlag        <=(wTDATA2[ 7:0] ==  8'h01);
if (wTVALID2 && (Position == 1) )  MagicNumberFlag        <=(wTDATA2[31:0] == 32'hDEADBEAF);
if (wTVALID2 && (Position == 2) )  {PacketGap,PacketSize} <= wTDATA2[31:0];
if (wTVALID2 && (Position == 3) )  PacketCount            <= wTDATA2[31:0];

TG_Start_Pulse <= CommandCodeFlag&&MagicNumberFlag&&wTLAST2&&wTVALID2&&!wTERROR2;

if (CommandCodeFlag&&MagicNumberFlag&&wTLAST2&&wTVALID2&&!wTERROR2)
    begin
    TG_PacketSize  <= PacketSize;
    TG_PacketCount <= PacketCount;
    TG_PacketGap   <= PacketGap;
    end
end


endmodule
