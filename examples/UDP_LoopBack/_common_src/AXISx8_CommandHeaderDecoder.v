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

module AXISx8_CommandHeaderDecoder
#(
parameter COMAND_UNIQ_CONST = 32'hAFBEADDE,
parameter COMAND_TYPE_CODE  =  8'h1
) 
(
    input                           CLK ,
    
    input  wire [ 8-1:0]            Sink_TDATA ,
    input  wire                     Sink_TVALID,
    input  wire                     Sink_TFIRST,
    input  wire                     Sink_TLAST,
    input  wire                     Sink_TERROR,
    
    output reg                      Source_TFIRST=0,
    output reg                      Source_TVALID=0,
    output reg                      Source_TERROR=0,
    output reg                      Source_TLAST=0,
    output reg [ 4-1:0]             Source_TKEEP=0,
    output reg [32-1:0]             Source_TDATA=0,
    
    output reg [16-1:0]             POSITION=0,
    output reg                      CommandSize_ValidFlag=0,


    output reg [ 8-1:0]             CommandCode=0,
    output reg [ 8-1:0]             CommandParam=0,
    output reg [16-1:0]             CommandSize=0,
    output reg [32-1:0]             CommandReserve=0  
);

(* keep = "true" *) wire [ 8-1:0]   wTDATA0 ;
(* keep = "true" *) wire            wTFIRST0;
(* keep = "true" *) wire            wTVALID0;
(* keep = "true" *) wire            wTLAST0 ;
(* keep = "true" *) wire            wTERROR0;
(* keep = "true" *) wire            wCRC_FLAG0;



(* keep = "true" *) wire [32-1:0]   wTDATA1 ;
(* keep = "true" *) wire [ 4-1:0]   wTKEEP1 ;
(* keep = "true" *) wire            wTFIRST1;
(* keep = "true" *) wire            wTVALI1;
(* keep = "true" *) wire            wTLAST1 ;
(* keep = "true" *) wire            wTERROR1;

(* keep = "true" *) reg [16-1:0]BytePosition=0;

(* keep = "true" *) reg                      CommandPayloadFlag=0;
(* keep = "true" *) reg                      CommandUniq_ValidFlag=0;
(* keep = "true" *) reg                      HeaderCRC_ValidFlag=0;



always @(posedge CLK)
begin
if (Sink_TVALID)
    begin
    if (Sink_TFIRST)BytePosition<=0;
        else if (BytePosition!=16'hFFFF) BytePosition <= BytePosition +1'b1;
    end
end

(* KEEP_HIERARCHY = "TRUE" *)
EthernetRxFrameFCS_Check_x8  
#(
.INIT_FF(1),
.INPUT_REVERCEORDER(1),
.INPUT_INVERCE(0)
) AXISx8_CommandHeaderChecker_FCS_Check_inst
(
.CLK                          (CLK),

.FCS_Check_Sink_Val           (Sink_TVALID   ), 
.FCS_Check_Sink_MSK           (Sink_TVALID   ),
.FCS_Check_Sink_EoF           (Sink_TLAST    ),
.FCS_Check_Sink_Err           (Sink_TERROR   ),
.FCS_Check_Sink_Dat           (Sink_TDATA    ),

.FCS_Check_Source_Val         (wTVALID0      ),
.FCS_Check_Source_SoF         (wTFIRST0      ),
.FCS_Check_Source_EoF         (wTLAST0       ),
.FCS_Check_Source_Err         (wTERROR0      ),
.FCS_Check_Source_CRC         (wCRC_FLAG0    ),
.FCS_Check_Source_Dat         (wTDATA0       )
);

always @(posedge CLK)
begin
if (wTVALID0)
    begin
    if (wTFIRST0)HeaderCRC_ValidFlag<=0;
        else if (BytePosition==16'h000F) HeaderCRC_ValidFlag <= wCRC_FLAG0;

     if (wTLAST0) CommandSize_ValidFlag <= ((BytePosition+1'b1) == CommandSize) ;
    end
end

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
. TVALID                    (wTVALID0   ),
. TERROR                    (wTERROR0   ),
. TLAST                     (wTLAST0    ),       
. TDATA                     (wTDATA0    ),  

. TFIRST_OUT                (wTFIRST1   ),
. TVALID_OUT                (wTVALID1   ),
. TERROR_OUT                (wTERROR1   ), 
. TLAST_OUT                 (wTLAST1    ),
. TKEEP_OUT                 (wTKEEP1    ),
. TDATA_OUT                 (wTDATA1    )
 );  
 

    
    
always @(posedge CLK)
begin
if (wTVALID1&&wTFIRST1) POSITION <= 16'hFFFC;
    else if (wTVALID1) POSITION <= POSITION + 1'b1;
    


if (wTVALID1 && wTFIRST1 )                  CommandCode             <=  wTDATA1[ 7: 0];
if (wTVALID1 && wTFIRST1 )                  CommandParam            <=  wTDATA1[15: 8];
if (wTVALID1 && wTFIRST1 )                  CommandSize             <=  wTDATA1[31:16];
if (wTVALID1 && (POSITION==16'hFFFC) )      CommandReserve          <=  wTDATA1[31: 0];
if (wTVALID1 && (POSITION==16'hFFFD) )      CommandUniq_ValidFlag   <= (wTDATA1[31: 0]==COMAND_UNIQ_CONST);

if (wTVALID1 && (POSITION==16'hFFFE) )      CommandPayloadFlag <=     CommandUniq_ValidFlag && HeaderCRC_ValidFlag;
    else if (wTVALID1 && wTLAST1) CommandPayloadFlag <=     0;

Source_TVALID <= wTVALID1 && CommandPayloadFlag; 
Source_TFIRST <= wTVALID1 && CommandPayloadFlag && (POSITION==16'hFFFF) ; 
Source_TERROR <= wTERROR1 && CommandPayloadFlag; 
Source_TLAST  <= wTLAST1  && CommandPayloadFlag; 
Source_TKEEP  <= wTKEEP1;
Source_TDATA  <= wTDATA1;

end
endmodule
