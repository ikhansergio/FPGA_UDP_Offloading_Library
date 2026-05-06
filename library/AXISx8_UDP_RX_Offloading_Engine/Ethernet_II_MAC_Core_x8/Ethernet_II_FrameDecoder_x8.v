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

module Ethernet_II_FrameDecoder_x8(
	input wire 	           CLK,
	input wire 	           TLAST,
	input wire 	           TVALID,
	input wire 	           TERROR,
	input wire [ 8-1:0]    TDATA,
	
	output wire            Ethernet_II_Frame_TLAST,
	output wire            Ethernet_II_Frame_TVALID,
	output wire            Ethernet_II_Frame_TERROR,
	output wire [ 8-1 :0]  Ethernet_II_Frame_TDATA,
	input  wire [48-1:0]   Ethernet_II_Internal_MAC,

	output reg [48-1:0]    Ethernet_II_External_MAC = 0,
	output reg [16-1:0]    Ethernet_II_TypeCode = 0
    );
    
	//////////////////////////////////////////////////////////////////////////////////////
	// find the beginning of a package 
    reg  TLAST_DONE=1;
    wire wTFIRST;
	always @(posedge CLK) begin if (TVALID&&TLAST) TLAST_DONE<=1; else if (TVALID) TLAST_DONE<=0; end
	assign wTFIRST=TLAST_DONE&&TVALID;
	//////////////////////////////////////////////////////////////////////////////////////
	
	reg [ 5-1:0] PositionCounter=0;
	reg [ 8-1:0] TDATA_Reg0=0;
	reg          TVALID_Reg0=0;
	reg          TLAST_Reg0=0;
	reg          TERROR_Reg0=0;
	
	reg [7-1:0]  PreambleCheckFlags=0;
	reg          PreambleCheckDoneFlag=0;

	reg [6-1:0]  DA_MAC_CheckFlag=0;
	reg          DA_MAC_CheckDoneFlag=0;
	
	reg          FrameAcceptedFlag=0;
	
	reg [8-1:0]  Ethernet_II_External_MAC0=0;
	reg [8-1:0]  Ethernet_II_External_MAC1=0;
	reg [8-1:0]  Ethernet_II_External_MAC2=0;
	reg [8-1:0]  Ethernet_II_External_MAC3=0;
	reg [8-1:0]  Ethernet_II_External_MAC4=0;
	reg [8-1:0]  Ethernet_II_External_MAC5=0;	
	
	reg [8-1:0]  EtherType0=0;	
	reg [8-1:0]  EtherType1=0;	
	
	reg Ethernet_II_FrameFlag=0;
	// TODO PositionCounter ==15
	always @(posedge CLK)
    begin
    if (wTFIRST) PositionCounter <=0;
        else if (TVALID&&(PositionCounter==31)) PositionCounter <= PositionCounter;    
            else if (TVALID) PositionCounter <= PositionCounter +1'b1; 
    
    TDATA_Reg0  <= TDATA;
    TVALID_Reg0 <= TVALID;
    TLAST_Reg0  <= TLAST;
    
    if (wTFIRST) TERROR_Reg0<= TERROR;
        else if (TVALID) TERROR_Reg0<= TERROR||TERROR_Reg0;
    
    
    if (TVALID_Reg0&&(PositionCounter==5'h00)&&(TDATA_Reg0==8'h55)) PreambleCheckFlags [0] <=1'b1; else if (TVALID_Reg0&&TLAST_Reg0)  PreambleCheckFlags [0] <=1'b0;
    if (TVALID_Reg0&&(PositionCounter==5'h01)&&(TDATA_Reg0==8'h55)) PreambleCheckFlags [1] <=1'b1; else if (TVALID_Reg0&&TLAST_Reg0)  PreambleCheckFlags [1] <=1'b0;
    if (TVALID_Reg0&&(PositionCounter==5'h02)&&(TDATA_Reg0==8'h55)) PreambleCheckFlags [2] <=1'b1; else if (TVALID_Reg0&&TLAST_Reg0)  PreambleCheckFlags [2] <=1'b0;
    if (TVALID_Reg0&&(PositionCounter==5'h03)&&(TDATA_Reg0==8'h55)) PreambleCheckFlags [3] <=1'b1; else if (TVALID_Reg0&&TLAST_Reg0)  PreambleCheckFlags [3] <=1'b0;
    if (TVALID_Reg0&&(PositionCounter==5'h04)&&(TDATA_Reg0==8'h55)) PreambleCheckFlags [4] <=1'b1; else if (TVALID_Reg0&&TLAST_Reg0)  PreambleCheckFlags [4] <=1'b0;
    if (TVALID_Reg0&&(PositionCounter==5'h05)&&(TDATA_Reg0==8'h55)) PreambleCheckFlags [5] <=1'b1; else if (TVALID_Reg0&&TLAST_Reg0)  PreambleCheckFlags [5] <=1'b0;
    if (TVALID_Reg0&&(PositionCounter==5'h06)&&(TDATA_Reg0==8'h55)) PreambleCheckFlags [6] <=1'b1; else if (TVALID_Reg0&&TLAST_Reg0)  PreambleCheckFlags [6] <=1'b0;
    //if (TVALID_Reg0&&(PositionCounter==5'h07)&&(TDATA_Reg0==8'hD5)) PreambleCheckFlags [7] <=1'b1; else if (TVALID_Reg0&&(PositionCounter==5'h07))  PreambleCheckFlags [7] <=1'b0; 
    
    if (TVALID_Reg0&&(PositionCounter==5'h08)&&((TDATA_Reg0==Ethernet_II_Internal_MAC[5*8+:8])||(TDATA_Reg0==8'hFF))) DA_MAC_CheckFlag [5] <=1'b1; else if (TVALID_Reg0&&(PositionCounter==5'h08))  DA_MAC_CheckFlag [5] <=1'b0;
    if (TVALID_Reg0&&(PositionCounter==5'h09)&&((TDATA_Reg0==Ethernet_II_Internal_MAC[4*8+:8])||(TDATA_Reg0==8'hFF))) DA_MAC_CheckFlag [4] <=1'b1; else if (TVALID_Reg0&&(PositionCounter==5'h09))  DA_MAC_CheckFlag [4] <=1'b0;
    if (TVALID_Reg0&&(PositionCounter==5'h0A)&&((TDATA_Reg0==Ethernet_II_Internal_MAC[3*8+:8])||(TDATA_Reg0==8'hFF))) DA_MAC_CheckFlag [3] <=1'b1; else if (TVALID_Reg0&&(PositionCounter==5'h0A))  DA_MAC_CheckFlag [3] <=1'b0;
    if (TVALID_Reg0&&(PositionCounter==5'h0B)&&((TDATA_Reg0==Ethernet_II_Internal_MAC[2*8+:8])||(TDATA_Reg0==8'hFF))) DA_MAC_CheckFlag [2] <=1'b1; else if (TVALID_Reg0&&(PositionCounter==5'h0B))  DA_MAC_CheckFlag [2] <=1'b0;
    if (TVALID_Reg0&&(PositionCounter==5'h0C)&&((TDATA_Reg0==Ethernet_II_Internal_MAC[1*8+:8])||(TDATA_Reg0==8'hFF))) DA_MAC_CheckFlag [1] <=1'b1; else if (TVALID_Reg0&&(PositionCounter==5'h0C))  DA_MAC_CheckFlag [1] <=1'b0;
    if (TVALID_Reg0&&(PositionCounter==5'h0D)&&((TDATA_Reg0==Ethernet_II_Internal_MAC[0*8+:8])||(TDATA_Reg0==8'hFF))) DA_MAC_CheckFlag [0] <=1'b1; else if (TVALID_Reg0&&(PositionCounter==5'h0D))  DA_MAC_CheckFlag [0] <=1'b0;
    
    if (TVALID_Reg0&&(PositionCounter==5'h0E)) Ethernet_II_External_MAC5    <= TDATA_Reg0;
    if (TVALID_Reg0&&(PositionCounter==5'h0F)) Ethernet_II_External_MAC4    <= TDATA_Reg0;
    if (TVALID_Reg0&&(PositionCounter==5'h10)) Ethernet_II_External_MAC3    <= TDATA_Reg0;
    if (TVALID_Reg0&&(PositionCounter==5'h11)) Ethernet_II_External_MAC2    <= TDATA_Reg0;
    if (TVALID_Reg0&&(PositionCounter==5'h12)) Ethernet_II_External_MAC1    <= TDATA_Reg0;
    if (TVALID_Reg0&&(PositionCounter==5'h13)) Ethernet_II_External_MAC0    <= TDATA_Reg0;
    
    if (TVALID_Reg0&&(PositionCounter==5'h14)) EtherType1                   <= TDATA_Reg0;
    if (TVALID_Reg0&&(PositionCounter==5'h15)) EtherType0                   <= TDATA_Reg0;
    
    if (TVALID_Reg0&&(PositionCounter==5'h15)) FrameAcceptedFlag            <= (&DA_MAC_CheckFlag) && PreambleCheckDoneFlag  ;    else if (TVALID_Reg0&&TLAST_Reg0) FrameAcceptedFlag <=1'b0;
    if (TVALID_Reg0&&(PositionCounter==5'h15)) Ethernet_II_FrameFlag        <= ({EtherType1,TDATA_Reg0}>=16'h0600);
    
    if (TVALID_Reg0&&(PositionCounter==5'h16)) Ethernet_II_TypeCode         <= {EtherType1,EtherType0};
    if (TVALID_Reg0&&(PositionCounter==5'h16)) Ethernet_II_External_MAC     <= {Ethernet_II_External_MAC5,Ethernet_II_External_MAC4,Ethernet_II_External_MAC3,Ethernet_II_External_MAC2,Ethernet_II_External_MAC1,Ethernet_II_External_MAC0};
    
    if (TVALID_Reg0&&(PositionCounter==5'h07)) PreambleCheckDoneFlag        <= (&PreambleCheckFlags)&&(TDATA_Reg0==8'hD5); else if (TVALID_Reg0&&TLAST_Reg0) PreambleCheckDoneFlag <=1'b0;
    if (TVALID_Reg0&&(PositionCounter==5'h0E)) DA_MAC_CheckDoneFlag         <= &DA_MAC_CheckFlag;
    
    
    end
    
wire            wEthernetRxFrameFCS_TVALID;
wire            wEthernetRxFrameFCS_TLAST;
wire            wEthernetRxFrameFCS_TERROR;
wire [ 8-1 :0]  wEthernetRxFrameFCS_TDATA;
	

(* KEEP_HIERARCHY = "TRUE" *)
EthernetRxFrameFCS_Check_x8  
#(
.INIT_FF(1),
.INPUT_REVERCEORDER(1),
.INPUT_INVERCE(0)
)    EthernetRxFrameFCS_Check_x8_inst
(
.CLK                          (CLK),

.FCS_Check_Sink_Val           (TVALID_Reg0&&PreambleCheckDoneFlag), 
.FCS_Check_Sink_MSK           (TVALID_Reg0&&FrameAcceptedFlag&&Ethernet_II_FrameFlag),
.FCS_Check_Sink_EoF           (TLAST_Reg0),
.FCS_Check_Sink_Err           (TERROR_Reg0),
.FCS_Check_Sink_Dat           (TDATA_Reg0),

.FCS_Check_Source_Val         (wEthernetRxFrameFCS_TVALID),
.FCS_Check_Source_EoF         (wEthernetRxFrameFCS_TLAST),
.FCS_Check_Source_Err         (wEthernetRxFrameFCS_TERROR),
.FCS_Check_Source_Dat         (wEthernetRxFrameFCS_TDATA)
);

(* KEEP_HIERARCHY = "TRUE" *)
EthernetRxFrameFCS_Remover_x8      EthernetRxFrameFCS_Remover_x8_inst
(
.CLK                          (CLK),
.FCS_Remover_Sink_Val         (wEthernetRxFrameFCS_TVALID),
.FCS_Remover_Sink_EoF         (wEthernetRxFrameFCS_TLAST),
.FCS_Remover_Sink_Err         (wEthernetRxFrameFCS_TERROR),  
.FCS_Remover_Sink_Dat         (wEthernetRxFrameFCS_TDATA),

.FCS_Remover_Source_Val       (Ethernet_II_Frame_TVALID),
.FCS_Remover_Source_EoF       (Ethernet_II_Frame_TLAST),
.FCS_Remover_Source_Err       (Ethernet_II_Frame_TERROR),
.FCS_Remover_Source_Dat       (Ethernet_II_Frame_TDATA)
 );

endmodule
