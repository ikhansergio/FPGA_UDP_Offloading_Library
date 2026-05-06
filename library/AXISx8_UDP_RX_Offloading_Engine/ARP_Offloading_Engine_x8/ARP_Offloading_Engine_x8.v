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

module ARP_Offloading_Engine_x8
(
	input  wire	                   RX_CLK,
	input  wire	                   RX_TVALID,
	input  wire	                   RX_TERROR,
	input  wire	                   RX_TLAST,
	input  wire	[ 8-1:0]           RX_TDATA,
	
	input  wire [16-1:0]           Ethernet_TypeCode,
	
	input  wire	[48-1:0]           Internal_MAC_ADDR ,
	input  wire	[48-1:0]           External_MAC_ADDR ,
	input  wire	[32-1:0]           Internal_IP4_ADDR ,


    input  wire 	               TX_CLK,
	input  wire	                   TX_TRDY,
	output wire	                   TX_TVALID,
	output wire	                   TX_TLAST,
	output wire	[ 8-1:0]           TX_TDATA
);

localparam EtherType = 16'h0806;


(* KEEP_HIERARCHY = "TRUE" *)
PacketTypeValidation                
#(
.PackTypePattern(EtherType)                        
)Ethernet_TypeCode_Validation_inst
(
.CLK                   (RX_CLK),
.Sink_TVALID           (RX_TVALID),
.Sink_TERROR           (RX_TERROR),
.Sink_TLAST            (RX_TLAST),
.Sink_TDATA            (RX_TDATA),
	
.PackTypeCode          (Ethernet_TypeCode),

.Source_TVALID         (),
.Source_TFIRST         (),
.Source_TLAST          (),
.Source_TERROR         (),
.Source_TDATA          ()
);



//////////////////////////////////////////////////////////////////////////////////////
// find the beginning of a package 
reg  TLAST_DONE_FLAG=1;
wire RX_TFIRST;
always @(posedge RX_CLK) begin if (RX_TVALID&&RX_TLAST) TLAST_DONE_FLAG<=1; else if (RX_TVALID) TLAST_DONE_FLAG<=0; end
assign RX_TFIRST =  TLAST_DONE_FLAG && RX_TVALID && (Ethernet_TypeCode == EtherType);
//assign RX_TFIRST =  TLAST_DONE_FLAG && RX_TVALID ;
//////////////////////////////////////////////////////////////////////////////////////

reg         RX_REG_ARP_PackTypeFlag =0;

reg         RX_REG_TFIRST           =0;
reg         RX_REG_TVALID           =0;
reg         RX_REG_TERROR           =0;
reg         RX_REG_TLAST            =0;
reg [8-1:0] RX_REG_TDATA            =0;

reg         ARP_Core_TVALID         =0;
reg         ARP_Core_TERROR         =0;
reg         ARP_Core_TLAST          =0;
reg [8-1:0] ARP_Core_TDATA          =0;


always @(posedge RX_CLK)
begin
if (TLAST_DONE_FLAG&&RX_TVALID) RX_REG_ARP_PackTypeFlag    <=  (Ethernet_TypeCode == EtherType);

RX_REG_TFIRST     <=	RX_TFIRST;
RX_REG_TVALID     <=    RX_TVALID;
RX_REG_TERROR     <=    RX_TERROR;
RX_REG_TLAST      <=    RX_TLAST;
RX_REG_TDATA      <=    RX_TDATA;

if (RX_REG_ARP_PackTypeFlag)  ARP_Core_TVALID <= RX_REG_TVALID;   else ARP_Core_TVALID <=  0;
if (RX_REG_ARP_PackTypeFlag)  ARP_Core_TLAST  <= RX_REG_TLAST;    else ARP_Core_TLAST  <=  0; 
if (RX_REG_ARP_PackTypeFlag)  ARP_Core_TERROR <= RX_REG_TERROR;   else ARP_Core_TERROR <=  0;  
if (RX_REG_ARP_PackTypeFlag)  ARP_Core_TDATA <=  RX_REG_TDATA;    else ARP_Core_TDATA <=  0; 
end

reg [8-1:0]     RX_ARP_FrameCounter                 =   1'b0;
reg [4-1:0]     RX_ARP_HeaderCheckCounter           =   1'b0;
reg             RX_ARP_HeaderValidFlag              =   1'b0;
reg [3-1:0]     RX_ARP_InternalIP4CheckCounter      =   1'b0;
reg             RX_ARP_IP4ValidFlag                 =   1'b0;
reg             RX_ARP_EndDetectedFlag              =   1'b0;

reg             ARP_ReplyPulse                      =   1'b0;
reg [8-1:0]     ARP_ReplyWiderCouter                =   1'b0;
reg             ARP_ReplyWidePulse                  =   1'b0;

reg [8-1:0] Ethernet_II_External_MAC_REG0 = 0;
reg [8-1:0] Ethernet_II_External_MAC_REG1 = 0;
reg [8-1:0] Ethernet_II_External_MAC_REG2 = 0;
reg [8-1:0] Ethernet_II_External_MAC_REG3 = 0;
reg [8-1:0] Ethernet_II_External_MAC_REG4 = 0;
reg [8-1:0] Ethernet_II_External_MAC_REG5 = 0;

reg [8-1:0] Ethernet_II_External_IP4_REG0 = 0;
reg [8-1:0] Ethernet_II_External_IP4_REG1 = 0;
reg [8-1:0] Ethernet_II_External_IP4_REG2 = 0;
reg [8-1:0] Ethernet_II_External_IP4_REG3 = 0;


always @(posedge RX_CLK)
begin

if (RX_REG_TFIRST) RX_ARP_FrameCounter<=1'b0; 	
    else if (RX_REG_TVALID&&(RX_ARP_FrameCounter!=63)) RX_ARP_FrameCounter<=RX_ARP_FrameCounter+1'b1;
// Check ARP Headr
if (RX_REG_TFIRST) RX_ARP_HeaderCheckCounter<=1'b0;
	else if ((RX_ARP_FrameCounter==8'h00) && ARP_Core_TVALID&&(ARP_Core_TDATA==8'h00)) RX_ARP_HeaderCheckCounter<=RX_ARP_HeaderCheckCounter+1'b1;
		else if ((RX_ARP_FrameCounter==8'h01) && ARP_Core_TVALID&&(ARP_Core_TDATA==8'h01)) RX_ARP_HeaderCheckCounter<=RX_ARP_HeaderCheckCounter+1'b1;
			else if ((RX_ARP_FrameCounter==8'h02) && ARP_Core_TVALID&&(ARP_Core_TDATA==8'h08)) RX_ARP_HeaderCheckCounter<=RX_ARP_HeaderCheckCounter+1'b1;
				else if ((RX_ARP_FrameCounter==8'h03) && ARP_Core_TVALID&&(ARP_Core_TDATA==8'h00)) RX_ARP_HeaderCheckCounter<=RX_ARP_HeaderCheckCounter+1'b1;
					else if ((RX_ARP_FrameCounter==8'h04) && ARP_Core_TVALID&&(ARP_Core_TDATA==8'h06)) RX_ARP_HeaderCheckCounter<=RX_ARP_HeaderCheckCounter+1'b1;
						else if ((RX_ARP_FrameCounter==8'h05) && ARP_Core_TVALID&&(ARP_Core_TDATA==8'h04)) RX_ARP_HeaderCheckCounter<=RX_ARP_HeaderCheckCounter+1'b1;
							else if ((RX_ARP_FrameCounter==8'h06) && ARP_Core_TVALID&&(ARP_Core_TDATA==8'h00)) RX_ARP_HeaderCheckCounter<=RX_ARP_HeaderCheckCounter+1'b1;
								else if ((RX_ARP_FrameCounter==8'h07) && ARP_Core_TVALID&&(ARP_Core_TDATA==8'h01)) RX_ARP_HeaderCheckCounter<=RX_ARP_HeaderCheckCounter+1'b1;

if (RX_REG_TFIRST) RX_ARP_HeaderValidFlag<=1'b0;
	else if ((RX_ARP_FrameCounter==8'h08) &&(RX_ARP_HeaderCheckCounter==4'h8)) RX_ARP_HeaderValidFlag<=1'b1;


if (RX_REG_TFIRST) Ethernet_II_External_MAC_REG5<=1'b0;
	else if ((RX_ARP_FrameCounter==8'h08)&& ARP_Core_TVALID ) Ethernet_II_External_MAC_REG5<=ARP_Core_TDATA;
if (RX_REG_TFIRST) Ethernet_II_External_MAC_REG4<=1'b0;
	else if ((RX_ARP_FrameCounter==8'h09)&& ARP_Core_TVALID ) Ethernet_II_External_MAC_REG4<=ARP_Core_TDATA;
if (RX_REG_TFIRST) Ethernet_II_External_MAC_REG3<=1'b0;
	else if ((RX_ARP_FrameCounter==8'h0A)&& ARP_Core_TVALID ) Ethernet_II_External_MAC_REG3<=ARP_Core_TDATA;
if (RX_REG_TFIRST) Ethernet_II_External_MAC_REG2<=1'b0;
	else if ((RX_ARP_FrameCounter==8'h0B)&& ARP_Core_TVALID ) Ethernet_II_External_MAC_REG2<=ARP_Core_TDATA;
if (RX_REG_TFIRST) Ethernet_II_External_MAC_REG1<=1'b0;
	else if ((RX_ARP_FrameCounter==8'h0C)&& ARP_Core_TVALID ) Ethernet_II_External_MAC_REG1<=ARP_Core_TDATA;
if (RX_REG_TFIRST) Ethernet_II_External_MAC_REG0<=1'b0;
	else if ((RX_ARP_FrameCounter==8'h0D)&& ARP_Core_TVALID ) Ethernet_II_External_MAC_REG0<=ARP_Core_TDATA;
if (RX_REG_TFIRST) Ethernet_II_External_IP4_REG3<=1'b0;
	else if ((RX_ARP_FrameCounter==8'h0E)&& ARP_Core_TVALID ) Ethernet_II_External_IP4_REG3<=ARP_Core_TDATA;
if (RX_REG_TFIRST) Ethernet_II_External_IP4_REG2<=1'b0;
	else if ((RX_ARP_FrameCounter==8'h0F)&& ARP_Core_TVALID ) Ethernet_II_External_IP4_REG2<=ARP_Core_TDATA;
if (RX_REG_TFIRST) Ethernet_II_External_IP4_REG1<=1'b0;
	else if ((RX_ARP_FrameCounter==8'h10)&& ARP_Core_TVALID ) Ethernet_II_External_IP4_REG1<=ARP_Core_TDATA;
if (RX_REG_TFIRST) Ethernet_II_External_IP4_REG0<=1'b0;
	else if ((RX_ARP_FrameCounter==8'h11)&& ARP_Core_TVALID ) Ethernet_II_External_IP4_REG0<=ARP_Core_TDATA;
	
// Check ARP  InternalI IP
if (RX_REG_TFIRST) RX_ARP_InternalIP4CheckCounter<=1'b0;
	else if ((RX_ARP_FrameCounter==8'h18) && ARP_Core_TVALID&&(ARP_Core_TDATA==Internal_IP4_ADDR[31:24])) RX_ARP_InternalIP4CheckCounter<=RX_ARP_InternalIP4CheckCounter+1'b1;
		else if ((RX_ARP_FrameCounter==8'h19) && ARP_Core_TVALID&&(ARP_Core_TDATA==Internal_IP4_ADDR[23:16])) RX_ARP_InternalIP4CheckCounter<=RX_ARP_InternalIP4CheckCounter+1'b1;
			else if ((RX_ARP_FrameCounter==8'h1A) && ARP_Core_TVALID&&(ARP_Core_TDATA==Internal_IP4_ADDR[15: 8])) RX_ARP_InternalIP4CheckCounter<=RX_ARP_InternalIP4CheckCounter+1'b1;
				else if ((RX_ARP_FrameCounter==8'h1B) && ARP_Core_TVALID&&(ARP_Core_TDATA==Internal_IP4_ADDR[ 7: 0])) RX_ARP_InternalIP4CheckCounter<=RX_ARP_InternalIP4CheckCounter+1'b1;

RX_ARP_IP4ValidFlag         <=	 RX_ARP_InternalIP4CheckCounter==3'd4; 

RX_ARP_EndDetectedFlag      <=   ARP_Core_TVALID&ARP_Core_TLAST&!ARP_Core_TERROR;

ARP_ReplyPulse  <= RX_ARP_EndDetectedFlag && RX_ARP_IP4ValidFlag && RX_ARP_HeaderValidFlag;

if (ARP_ReplyPulse) ARP_ReplyWiderCouter<=1'b1;
    else if (ARP_ReplyWiderCouter!=0) ARP_ReplyWiderCouter<=ARP_ReplyWiderCouter+1'b1;

ARP_ReplyWidePulse <= ARP_ReplyWiderCouter!=0;

end

//////////////////////////////////////////////////////////////////////////////////////////////////////
// Tx Part

reg ARP_ReplyWidePulse_ResyncD0=0;
reg ARP_ReplyWidePulse_ResyncD1=0;
reg ARP_ReplyWidePulse_ResyncD2=0;

reg ARP_StartReplyPulse =   0;



reg             TX_ARP_Reply_TVALID                       =   0;
reg             TX_ARP_Reply_TLAST                        =   0;
reg [8-1:0]     TX_ARP_Reply_TDATA                        =   0;
reg [8-1:0]     TX_ARP_Reply_FrameCounter                 =   0;

reg [4-1:0]     TX_SwitchREG_Decoder                      =   0;
reg             TX_SwitchREG_LAST_FLAG                    =   0;


reg [8-1:0]     TX_SwitchREG_Ethernet_II_External_MAC     =   0;
reg [8-1:0]     TX_SwitchREG_Ethernet_II_Internal_MAC     =   0;
reg [8-1:0]     TX_SwitchREG_Ethernet_II_ARP_Header       =   0;
reg [8-1:0]     TX_SwitchREG_ARP_REPLAY_Internal_MAC      =   0;
reg [8-1:0]     TX_SwitchREG_ARP_REPLAY_Internal_IP4      =   0;
reg [8-1:0]     TX_SwitchREG_ARP_REPLAY_External_MAC      =   0;
reg [8-1:0]     TX_SwitchREG_ARP_REPLAY_External_IP4      =   0;


always @(posedge TX_CLK)
begin
ARP_ReplyWidePulse_ResyncD0<=ARP_ReplyWidePulse;
ARP_ReplyWidePulse_ResyncD1<=ARP_ReplyWidePulse_ResyncD0;
ARP_ReplyWidePulse_ResyncD2<=ARP_ReplyWidePulse_ResyncD1;
ARP_StartReplyPulse<=ARP_ReplyWidePulse_ResyncD1 && ! ARP_ReplyWidePulse_ResyncD2;


    if (ARP_StartReplyPulse)
        begin

        TX_ARP_Reply_FrameCounter               <=2;
        TX_SwitchREG_Decoder                    <=0;
        TX_SwitchREG_Ethernet_II_External_MAC   <= External_MAC_ADDR [39:32] ;
        
        TX_ARP_Reply_TDATA                      <= External_MAC_ADDR [47:40] ;
        TX_ARP_Reply_TVALID         <=1'b1;
        TX_ARP_Reply_TLAST          <=1'b0;
        end
        else if (TX_TRDY)
            begin
            TX_ARP_Reply_FrameCounter   <= TX_ARP_Reply_FrameCounter +1'b1;

            if (TX_ARP_Reply_FrameCounter==7'd00) TX_SwitchREG_Ethernet_II_External_MAC<= External_MAC_ADDR [47:40] ;                         // never used condition
                else if (TX_ARP_Reply_FrameCounter==7'd01) TX_SwitchREG_Ethernet_II_External_MAC<= External_MAC_ADDR [39:32] ;                // never used condition
	               else if (TX_ARP_Reply_FrameCounter==7'd02) TX_SwitchREG_Ethernet_II_External_MAC<= External_MAC_ADDR [31:24] ;
	                   else if (TX_ARP_Reply_FrameCounter==7'd03) TX_SwitchREG_Ethernet_II_External_MAC<= External_MAC_ADDR [23:16] ;
	                       else if (TX_ARP_Reply_FrameCounter==7'd04) TX_SwitchREG_Ethernet_II_External_MAC<= External_MAC_ADDR [15: 8] ;
	                           else if (TX_ARP_Reply_FrameCounter==7'd05) TX_SwitchREG_Ethernet_II_External_MAC<= External_MAC_ADDR [ 7: 0] ;
	                               else TX_SwitchREG_Ethernet_II_External_MAC<=0;
	        
	         if (TX_ARP_Reply_FrameCounter==7'd06) TX_SwitchREG_Ethernet_II_Internal_MAC<= Internal_MAC_ADDR [47:40] ;
                else if (TX_ARP_Reply_FrameCounter==7'd07) TX_SwitchREG_Ethernet_II_Internal_MAC<= Internal_MAC_ADDR [39:32] ;
	               else if (TX_ARP_Reply_FrameCounter==7'd08) TX_SwitchREG_Ethernet_II_Internal_MAC<= Internal_MAC_ADDR [31:24] ;
	                   else if (TX_ARP_Reply_FrameCounter==7'd09) TX_SwitchREG_Ethernet_II_Internal_MAC<= Internal_MAC_ADDR [23:16] ;
	                       else if (TX_ARP_Reply_FrameCounter==7'd10) TX_SwitchREG_Ethernet_II_Internal_MAC<= Internal_MAC_ADDR [15: 8] ;
	                           else if (TX_ARP_Reply_FrameCounter==7'd11) TX_SwitchREG_Ethernet_II_Internal_MAC<= Internal_MAC_ADDR [ 7: 0] ;
	                               else if (TX_ARP_Reply_FrameCounter==7'd12) TX_SwitchREG_Ethernet_II_Internal_MAC<=8'h08;
	                                   else if (TX_ARP_Reply_FrameCounter==7'd13) TX_SwitchREG_Ethernet_II_Internal_MAC<=8'h06;
	                                       else TX_SwitchREG_Ethernet_II_Internal_MAC<=0;
	                                   
	         if (TX_ARP_Reply_FrameCounter==7'd14) TX_SwitchREG_Ethernet_II_ARP_Header<=8'h00;
                else if (TX_ARP_Reply_FrameCounter==7'd15) TX_SwitchREG_Ethernet_II_ARP_Header<=8'h01;
	               else if (TX_ARP_Reply_FrameCounter==7'd16) TX_SwitchREG_Ethernet_II_ARP_Header<=8'h08;
	                   else if (TX_ARP_Reply_FrameCounter==7'd17) TX_SwitchREG_Ethernet_II_ARP_Header<=8'h00;
	                       else if (TX_ARP_Reply_FrameCounter==7'd18) TX_SwitchREG_Ethernet_II_ARP_Header<=8'h06;
	                           else if (TX_ARP_Reply_FrameCounter==7'd19) TX_SwitchREG_Ethernet_II_ARP_Header<=8'h04;
	                               else if (TX_ARP_Reply_FrameCounter==7'd20) TX_SwitchREG_Ethernet_II_ARP_Header<=8'h00;
	                                   else if (TX_ARP_Reply_FrameCounter==7'd21) TX_SwitchREG_Ethernet_II_ARP_Header<=8'h02;
	                                       else TX_SwitchREG_Ethernet_II_ARP_Header<=0;  
	                                     
	         if (TX_ARP_Reply_FrameCounter==7'd22) TX_SwitchREG_ARP_REPLAY_Internal_MAC<= Internal_MAC_ADDR [47:40] ;
                else if (TX_ARP_Reply_FrameCounter==7'd23) TX_SwitchREG_ARP_REPLAY_Internal_MAC<= Internal_MAC_ADDR [39:32] ;
	               else if (TX_ARP_Reply_FrameCounter==7'd24) TX_SwitchREG_ARP_REPLAY_Internal_MAC<= Internal_MAC_ADDR [31:24] ;
	                   else if (TX_ARP_Reply_FrameCounter==7'd25) TX_SwitchREG_ARP_REPLAY_Internal_MAC<= Internal_MAC_ADDR [23:16] ;
	                       else if (TX_ARP_Reply_FrameCounter==7'd26) TX_SwitchREG_ARP_REPLAY_Internal_MAC<= Internal_MAC_ADDR [15: 8] ;
	                           else if (TX_ARP_Reply_FrameCounter==7'd27) TX_SwitchREG_ARP_REPLAY_Internal_MAC<= Internal_MAC_ADDR [ 7: 0] ;
	                               else TX_SwitchREG_ARP_REPLAY_Internal_MAC<=0;         
	                           
	         if (TX_ARP_Reply_FrameCounter==7'd28) TX_SwitchREG_ARP_REPLAY_Internal_IP4<= Internal_IP4_ADDR [31:24] ;
                else if (TX_ARP_Reply_FrameCounter==7'd29) TX_SwitchREG_ARP_REPLAY_Internal_IP4<= Internal_IP4_ADDR [23:16] ;
	               else if (TX_ARP_Reply_FrameCounter==7'd30) TX_SwitchREG_ARP_REPLAY_Internal_IP4<= Internal_IP4_ADDR [15: 8] ;
	                   else if (TX_ARP_Reply_FrameCounter==7'd31) TX_SwitchREG_ARP_REPLAY_Internal_IP4<= Internal_IP4_ADDR [ 7: 0] ;
	                       else TX_SwitchREG_ARP_REPLAY_Internal_IP4<=0;

	         if (TX_ARP_Reply_FrameCounter==7'd32) TX_SwitchREG_ARP_REPLAY_External_MAC<= Ethernet_II_External_MAC_REG5;
                else if (TX_ARP_Reply_FrameCounter==7'd33) TX_SwitchREG_ARP_REPLAY_External_MAC<= Ethernet_II_External_MAC_REG4;
	               else if (TX_ARP_Reply_FrameCounter==7'd34) TX_SwitchREG_ARP_REPLAY_External_MAC<= Ethernet_II_External_MAC_REG3;
	                   else if (TX_ARP_Reply_FrameCounter==7'd35) TX_SwitchREG_ARP_REPLAY_External_MAC<= Ethernet_II_External_MAC_REG2;
	                       else if (TX_ARP_Reply_FrameCounter==7'd36) TX_SwitchREG_ARP_REPLAY_External_MAC<= Ethernet_II_External_MAC_REG1;
	                           else if (TX_ARP_Reply_FrameCounter==7'd37) TX_SwitchREG_ARP_REPLAY_External_MAC<= Ethernet_II_External_MAC_REG0;
	                               else TX_SwitchREG_ARP_REPLAY_External_MAC<=0;   
	                           
	         if (TX_ARP_Reply_FrameCounter==7'd38) TX_SwitchREG_ARP_REPLAY_External_IP4<= Ethernet_II_External_IP4_REG3 ;
                else if (TX_ARP_Reply_FrameCounter==7'd39) TX_SwitchREG_ARP_REPLAY_External_IP4<= Ethernet_II_External_IP4_REG2 ;
	               else if (TX_ARP_Reply_FrameCounter==7'd40) TX_SwitchREG_ARP_REPLAY_External_IP4<= Ethernet_II_External_IP4_REG1 ;
	                   else if (TX_ARP_Reply_FrameCounter==7'd41) TX_SwitchREG_ARP_REPLAY_External_IP4<= Ethernet_II_External_IP4_REG0 ;
	                       else TX_SwitchREG_ARP_REPLAY_External_MAC<=0;
	                       
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	        
            if ((TX_ARP_Reply_FrameCounter>=7'd00)&& (TX_ARP_Reply_FrameCounter<=7'd05)) TX_SwitchREG_Decoder <= 0;
                else if ((TX_ARP_Reply_FrameCounter>=7'd06)&& (TX_ARP_Reply_FrameCounter<=7'd13)) TX_SwitchREG_Decoder <= 1;
                    else if ((TX_ARP_Reply_FrameCounter>=7'd14)&& (TX_ARP_Reply_FrameCounter<=7'd21)) TX_SwitchREG_Decoder <= 2;
                        else if ((TX_ARP_Reply_FrameCounter>=7'd22)&& (TX_ARP_Reply_FrameCounter<=7'd27)) TX_SwitchREG_Decoder <= 3;
                            else if ((TX_ARP_Reply_FrameCounter>=7'd28)&& (TX_ARP_Reply_FrameCounter<=7'd31)) TX_SwitchREG_Decoder <= 4;
                                else if ((TX_ARP_Reply_FrameCounter>=7'd32)&& (TX_ARP_Reply_FrameCounter<=7'd37)) TX_SwitchREG_Decoder <= 5;
                                    else if ((TX_ARP_Reply_FrameCounter>=7'd38)&& (TX_ARP_Reply_FrameCounter<=7'd41)) TX_SwitchREG_Decoder <= 6;
                                        else TX_SwitchREG_Decoder <= 7;
                                        
            if (TX_SwitchREG_Decoder==0) TX_ARP_Reply_TDATA <= TX_SwitchREG_Ethernet_II_External_MAC;
                else if (TX_SwitchREG_Decoder==1)  TX_ARP_Reply_TDATA <= TX_SwitchREG_Ethernet_II_Internal_MAC;
                    else if (TX_SwitchREG_Decoder==2)  TX_ARP_Reply_TDATA <= TX_SwitchREG_Ethernet_II_ARP_Header;
                        else if (TX_SwitchREG_Decoder==3)  TX_ARP_Reply_TDATA <= TX_SwitchREG_ARP_REPLAY_Internal_MAC;
                            else if (TX_SwitchREG_Decoder==4)  TX_ARP_Reply_TDATA <= TX_SwitchREG_ARP_REPLAY_Internal_IP4;
                                else if (TX_SwitchREG_Decoder==5)  TX_ARP_Reply_TDATA <= TX_SwitchREG_ARP_REPLAY_External_MAC;
                                    else if (TX_SwitchREG_Decoder==6)  TX_ARP_Reply_TDATA <= TX_SwitchREG_ARP_REPLAY_External_IP4;
                                        else if (TX_SwitchREG_Decoder==7)  TX_ARP_Reply_TDATA <= 0;
                                        
            TX_SwitchREG_LAST_FLAG                          <= (TX_ARP_Reply_FrameCounter==67) ;
            
            TX_ARP_Reply_TLAST                              <=  TX_SwitchREG_LAST_FLAG;
            if (TX_ARP_Reply_TLAST) TX_ARP_Reply_TVALID     <=0;
            end
end



	assign TX_TVALID     =   TX_ARP_Reply_TVALID;
	assign TX_TLAST      =   TX_ARP_Reply_TLAST;
	assign TX_TDATA      =   TX_ARP_Reply_TDATA;


endmodule
