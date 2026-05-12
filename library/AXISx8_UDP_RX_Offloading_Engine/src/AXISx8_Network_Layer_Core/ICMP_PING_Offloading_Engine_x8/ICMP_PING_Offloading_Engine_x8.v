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

module ICMP_PING_Offloading_Engine_x8
#(
    parameter BUFFER_COUNT_1K = 1       , 
    parameter ETHERNET_MTU = 1*1024     ,  
    parameter PADDING_INSERTION = "YES"   // "YES" or "NO"
) 
(
	input  wire	                   Sink_CLK                ,
	input  wire	                   Sink_TVALID             ,
	input  wire	                   Sink_TERROR             ,
	input  wire	                   Sink_TLAST              ,
	input  wire	[ 8-1:0]           Sink_TDATA              ,
	
	input  wire	[48-1:0]           MAC_LOCAL_ADDR_IN       ,
	input  wire	[48-1:0]           MAC_REMOTE_ADDR_IN      ,
    input  wire	[ 8-1:0] 		   IP4_Used_Protocol_IN    ,
	input  wire	[32-1:0]           IP4_LOCAL_ADDR_IN       ,
	input  wire	[32-1:0]           IP4_REMOTE_ADDR_IN      ,

    input  wire 	               ICMP_PING_Source_CLK,
	input  wire	                   ICMP_PING_Source_TRDY,
	output wire	                   ICMP_PING_Source_TVALID,
	output wire	                   ICMP_PING_Source_TERROR,
	output wire	                   ICMP_PING_Source_TLAST,
	output wire	[ 8-1:0]           ICMP_PING_Source_TDATA
);

function integer BitWidth (input integer Value);                  
    if (Value<3)
        begin
            BitWidth = 1; 
        end
    else 
        begin
            Value=Value-1;                                                            
            for(BitWidth=0; Value>0; BitWidth=BitWidth+1) Value = Value >> 1;                                                     
        end                                                          
endfunction 

localparam ICMP_ProtocolCode = 8'h01;
localparam BufferSize = BUFFER_COUNT_1K*(1024/4); // BUFFER_COUNT_1K * 256 

localparam MAX_Eth_PayloadSize      = ETHERNET_MTU - 0;
localparam MAX_IP4_PayloadSize      = ETHERNET_MTU - 20;
localparam MAX_ICMP_PayloadSize     = ETHERNET_MTU - 28;
//localparam MAX_ICMP_PayloadSize_BUF = BufferSize - 28;

if ( ETHERNET_MTU <= 28                         )             begin Error_Generation MTU_Erorr ( );           end
//if ((BufferSize*4) < MAX_ICMP_PayloadSize_MTU   )             begin AXISx32_UDP_Tx_Offload_Engine_Error BufferSize_Erorr ( );    end
if ((BUFFER_COUNT_1K==0)||(BUFFER_COUNT_1K>16)  )             begin Error_Generation BufferCount_Erorr ( );   end

(* KEEP = "TRUE" *) wire         wSink_TFIRST;
(* KEEP = "TRUE" *) wire         wSink_TVALID;
(* KEEP = "TRUE" *) wire         wSink_TERROR;
(* KEEP = "TRUE" *) wire         wSink_TLAST ;
(* KEEP = "TRUE" *) wire [8-1:0] wSink_TDATA ;

(* KEEP_HIERARCHY = "TRUE" *)
PacketTypeValidation                
#(
.PackTypePattern(ICMP_ProtocolCode)                        
)ICMP_PING_PacketTypeValidation_inst
(
.CLK                   (Sink_CLK                ),
.Sink_TVALID           (Sink_TVALID             ),
.Sink_TERROR           (Sink_TERROR             ),
.Sink_TLAST            (Sink_TLAST              ),
.Sink_TDATA            (Sink_TDATA              ),
	
.PackTypeCode          ({8'h00,IP4_Used_Protocol_IN}),

.Source_TVALID         (wSink_TVALID),
.Source_TFIRST         (wSink_TFIRST),
.Source_TLAST          (wSink_TLAST),
.Source_TERROR         (wSink_TERROR),
.Source_TDATA          (wSink_TDATA)
);

(* KEEP = "TRUE" *)wire            wICMP_Core_TFIRST_x32 ;
(* KEEP = "TRUE" *)wire            wICMP_Core_TVALID_x32 ;
(* KEEP = "TRUE" *)wire            wICMP_Core_TERROR_x32 ;
(* KEEP = "TRUE" *)wire            wICMP_Core_TLAST_x32  ;
(* KEEP = "TRUE" *)wire   [ 4-1:0] wICMP_Core_TKEEP_x32  ;
//(* KEEP = "TRUE" *)wire   [ 4-1:0] wICMP_Core_TKEEP; 
//(* KEEP = "TRUE" *)wire   [32-1:0] wICMP_Core_TDATA  ;
(* KEEP = "TRUE" *)wire   [32-1:0] wICMP_Core_TDATA_x32;
(* KEEP = "TRUE" *)wire   [ 3-1:0] wICMP_Core_Byte_COUNT_x32;  

(* KEEP_HIERARCHY = "TRUE" *)
AXIS_Width_Up_Converter
#(
. BIT_WIDTH             (8),
. N                     (4),
. BIG_ENDIAN            (1),         
. TFIRST_ReSTORE        (0) 
) AXISx8_To_AXISx32_Width_Up_Converter_inst
(
            
. CLK                       (Sink_CLK                       ),
. TFIRST                    (wSink_TFIRST                   ),            
. TDATA                     (wSink_TDATA                    ),
. TVALID                    (wSink_TVALID                   ),
. TERROR                    (wSink_TERROR                   ),
. TLAST                     (wSink_TLAST                    ),
 
. TFIRST_OUT                (wICMP_Core_TFIRST_x32          ),
. TVALID_OUT                (wICMP_Core_TVALID_x32          ),
. TERROR_OUT                (wICMP_Core_TERROR_x32          ), 
. TLAST_OUT                 (wICMP_Core_TLAST_x32           ),
. TKEEP_OUT                 (wICMP_Core_TKEEP_x32           ),
. TCOUNT_OUT                (wICMP_Core_Byte_COUNT_x32      ),
. TDATA_OUT                 (wICMP_Core_TDATA_x32           )
 );  
                       
                                        
//(* KEEP = "TRUE" *)reg [32-1:0] ICMP_CheckSUM_Packet_L=0;
//(* KEEP = "TRUE" *)reg [32-1:0] ICMP_CheckSUM_Packet_H=0;
//(* KEEP = "TRUE" *)reg [16-1:0] ICMP_CheckSUM_CalkRes=0;

//(* KEEP = "TRUE" *) reg [32-1:0] ICMP_PING_CheckSUM_FullPacket=0;
//(* KEEP = "TRUE" *)wire [32-1:0]wICMP_PING_CheckSUM_FullPacket;

//(* KEEP = "TRUE" *)reg [17-1:0] ICMP_PING_CheckSUM_Sub =0;
//(* KEEP = "TRUE" *)reg [32-1:0] ICMP_PING_CheckSUM_Reply=0;
(* KEEP = "TRUE" *)wire [32-1:0] wICMP_PING_CheckSUM_Reply;

(* KEEP = "TRUE" *)reg [ 1-1:0] ICMP_PING_TypeFlag=0;
(* KEEP = "TRUE" *)reg [ 1-1:0] ICMP_PING_CodeFlag=0;

(* KEEP = "TRUE" *)reg [16-1:0] ICMP_PING_Req_Header_Identifier=0;
(* KEEP = "TRUE" *)reg [16-1:0] ICMP_PING_Req_Header_SequenceNumber=0;


(* KEEP = "TRUE" *)reg [16-1:0] ICMP_PING_RxData_Length_Counter=0;


(* KEEP = "TRUE" *)reg [16-1:0] ICMP_PING_Payload_WrRAM_Pointer=0;


//(* KEEP = "TRUE" *)reg [32-1:0] ICMP_PING_Payload_WrRAM_Data=0;
(* KEEP = "TRUE" *)reg [ 1-1:0] ICMP_PING_WrWea=0;

(* KEEP = "TRUE" *)reg rICMP_Core_TFIRST_x32=0 ;



 (* KEEP_HIERARCHY = "TRUE" *)
 ICMP_PING_CheckSum      ICMP_PING_CheckSum_inst
(
.CLK                    (Sink_CLK   ),
.TFIRST                 (wICMP_Core_TFIRST_x32),
.TVALID                 (wICMP_Core_TVALID_x32),
.TDATA                  (wICMP_Core_TDATA_x32),
.CheckSUM               (wICMP_PING_CheckSUM_Reply)
);

always @(posedge Sink_CLK)
begin
	if (wICMP_Core_TVALID_x32 && wICMP_Core_TFIRST_x32) ICMP_PING_RxData_Length_Counter <= wICMP_Core_Byte_COUNT_x32;  
	   else if (wICMP_Core_TVALID_x32&&(ICMP_PING_RxData_Length_Counter>MAX_ICMP_PayloadSize)) ICMP_PING_RxData_Length_Counter <= ICMP_PING_RxData_Length_Counter;
	       else if (wICMP_Core_TVALID_x32&&(ICMP_PING_RxData_Length_Counter>BufferSize)) ICMP_PING_RxData_Length_Counter <= ICMP_PING_RxData_Length_Counter;    
	           else if (wICMP_Core_TVALID_x32) ICMP_PING_RxData_Length_Counter <= ICMP_PING_RxData_Length_Counter + wICMP_Core_Byte_COUNT_x32;  

 //   if (wICMP_Core_TVALID_x32 && wICMP_Core_TFIRST_x32) ICMP_PING_CheckSUM_Sub <= wICMP_Core_TDATA_x32[32-1:16] + wICMP_Core_TDATA_x32[16-1:0 ];

//	if (wICMP_Core_TVALID_x32 && wICMP_Core_TFIRST_x32) ICMP_CheckSUM_Packet_L <= {16'h00,wICMP_Core_TDATA_x32[16-1:0 ]}; 
//		else if (wICMP_Core_TVALID_x32) ICMP_CheckSUM_Packet_L <=ICMP_CheckSUM_Packet_L + {16'h00,wICMP_Core_TDATA_x32[16-1:0 ]};   
		
//	if (wICMP_Core_TVALID_x32 && wICMP_Core_TFIRST_x32) ICMP_CheckSUM_Packet_H <= {16'h00,wICMP_Core_TDATA_x32[32-1:16]}; 
//		else if (wICMP_Core_TVALID_x32) ICMP_CheckSUM_Packet_H <=ICMP_CheckSUM_Packet_H + {16'h00,wICMP_Core_TDATA_x32[32-1:16]};
			
	//ICMP_PING_CheckSUM_FullPacket    <=  ICMP_CheckSUM_Packet_L        + ICMP_CheckSUM_Packet_H;

//	ICMP_PING_CheckSUM_Reply         <=  ICMP_PING_CheckSUM_FullPacket - ICMP_PING_CheckSUM_Sub;
//    ICMP_PING_CheckSUM_Reply         <= wICMP_PING_CheckSUM_FullPacket - ICMP_PING_CheckSUM_Sub;


if (wICMP_Core_TFIRST_x32&&wICMP_Core_TVALID_x32) ICMP_PING_TypeFlag <= (wICMP_Core_TDATA_x32[31:24] == 8'h8);
if (wICMP_Core_TFIRST_x32&&wICMP_Core_TVALID_x32) ICMP_PING_CodeFlag <= (wICMP_Core_TDATA_x32[23:16] == 8'h0);


if (wICMP_Core_TVALID_x32) rICMP_Core_TFIRST_x32 <= wICMP_Core_TFIRST_x32;

if (wICMP_Core_TVALID_x32 && wICMP_Core_TFIRST_x32)  ICMP_PING_WrWea <= 0;  
    else if (wICMP_Core_TVALID_x32 && rICMP_Core_TFIRST_x32)  ICMP_PING_WrWea <= ICMP_PING_TypeFlag&&ICMP_PING_CodeFlag;
    
    
  
//if (wICMP_Core_TVALID_x32 && rICMP_Core_TFIRST_x32) {ICMP_PING_Req_Header_SequenceNumber,ICMP_PING_Req_Header_Identifier}   <= wICMP_Core_TDATA_x32[32-1:0];
if (wICMP_Core_TVALID_x32 && rICMP_Core_TFIRST_x32) {ICMP_PING_Req_Header_Identifier,ICMP_PING_Req_Header_SequenceNumber}   <= wICMP_Core_TDATA_x32[32-1:0];

if (wICMP_Core_TVALID_x32 && rICMP_Core_TFIRST_x32) ICMP_PING_Payload_WrRAM_Pointer<=0;
    else if (wICMP_Core_TVALID_x32 && (ICMP_PING_Payload_WrRAM_Pointer!=255) ) ICMP_PING_Payload_WrRAM_Pointer <= ICMP_PING_Payload_WrRAM_Pointer+1'b1;

end




(* KEEP = "TRUE" *) reg Start0 =0;
(* KEEP = "TRUE" *) reg Start1 =0;
(* KEEP = "TRUE" *) reg Start2 =0;
(* KEEP = "TRUE" *) reg Start3 =0;

(* KEEP = "TRUE" *) reg Start_Wide =0;
(* KEEP = "TRUE" *) reg [3:0]Wide_Counter =0;




//(* KEEP = "TRUE" *) reg [16-1:0] ICMP_PING_Payload_RdRAM_Pointer=0;
(* KEEP = "TRUE" *) wire [32-1:0] wICMP_PING_Payload_WrRAM_Data;

(* KEEP = "TRUE" *) reg             ICMP_PING_ReplyPulse                      =   1'b0;
(* KEEP = "TRUE" *) reg [8-1:0]     ICMP_PING_ReplyWiderCouter                =   1'b0;
(* KEEP = "TRUE" *) reg             ICMP_PING_ReplyWidePulse                  =   1'b0;


always @(posedge Sink_CLK)
begin
Start0 <= (wICMP_Core_TVALID_x32 && wICMP_Core_TLAST_x32 && !wICMP_Core_TERROR_x32);
Start1 <= Start0;
Start2 <= Start1;
Start3 <= Start2;

ICMP_PING_ReplyPulse <= Start3;
if (ICMP_PING_ReplyPulse) ICMP_PING_ReplyWiderCouter<=1'b1;
    else if (ICMP_PING_ReplyWiderCouter!=0) ICMP_PING_ReplyWiderCouter<=ICMP_PING_ReplyWiderCouter+1'b1;

ICMP_PING_ReplyWidePulse <= ICMP_PING_ReplyWiderCouter!=0;

end
 
(* KEEP = "TRUE" *) reg ICMP_PING_ReplyWidePulse_ResyncD0=0;
(* KEEP = "TRUE" *) reg ICMP_PING_ReplyWidePulse_ResyncD1=0;
(* KEEP = "TRUE" *) reg ICMP_PING_ReplyWidePulse_ResyncD2=0;

(* KEEP = "TRUE" *) reg ICMP_PING_StartReplyPulse =   0;


always @(posedge ICMP_PING_Source_CLK)
begin

ICMP_PING_ReplyWidePulse_ResyncD0<=ICMP_PING_ReplyWidePulse;
ICMP_PING_ReplyWidePulse_ResyncD1<=ICMP_PING_ReplyWidePulse_ResyncD0;
ICMP_PING_ReplyWidePulse_ResyncD2<=ICMP_PING_ReplyWidePulse_ResyncD1;
ICMP_PING_StartReplyPulse<=ICMP_PING_ReplyWidePulse_ResyncD1 && ! ICMP_PING_ReplyWidePulse_ResyncD2;


//if (ICMP_PING_StartReplyPulse) ICMP_PING_Payload_RdRAM_Pointer<=0;
//    else if (ICMP_PING_Source_TRDY) ICMP_PING_Payload_RdRAM_Pointer<=ICMP_PING_Payload_RdRAM_Pointer+1'b1;
end 


(* KEEP = "TRUE" *) reg  [16-1:0]    DATA_TotalLength_Full                     =   0;
(* KEEP = "TRUE" *) reg  [14-1:0]    DATA_TotalLength                          =   0;

(* KEEP = "TRUE" *) reg             Tx_MAC_FrameBody_VALID                    =   0;
(* KEEP = "TRUE" *) reg             Tx_MAC_FrameBody_TLAST                    =   0;
//reg [8-1:0]     Tx_MAC_FrameBody_TDATA                    =   0;
(* KEEP = "TRUE" *) reg [6-1:0]     Tx_MAC_FrameBody_ByteCounter              =   63;

(* KEEP = "TRUE" *) reg [4-1:0]     LoadDataPulse = 0;

//reg [3-1:0]     TX_SwitchREG_Decoder                      =   0;

(* KEEP = "TRUE" *) reg             ReadDataState = 0;
(* KEEP = "TRUE" *) reg             ReadDataState_Full = 0;

(* KEEP = "TRUE" *) reg [8-1:0]     ShiftRegD0 = 0;
(* KEEP = "TRUE" *) reg [8-1:0]     ShiftRegD1 = 0;
(* KEEP = "TRUE" *) reg [8-1:0]     ShiftRegD2 = 0;
(* KEEP = "TRUE" *) reg [8-1:0]     ShiftRegD3 = 0;

(* KEEP = "TRUE" *) reg [8-1:0]     TX_SwitchREG_Ethernet_II_External_MAC     =   0;
(* KEEP = "TRUE" *) reg [8-1:0]     TX_SwitchREG_Ethernet_II_Internal_MAC     =   0;



(* KEEP = "TRUE" *) reg [8-1:0]     TX_SwitchREG_Ethernet_II_UDP_Header       =   0;

(* KEEP = "TRUE" *) wire [8-1:0]    wTX_SwitchREG_Ethernet_II_MAC;
(* KEEP = "TRUE" *) wire [8-1:0]    wTX_SwitchREG_Ethernet_II_IP4;
(* KEEP = "TRUE" *) wire [8-1:0]    wTX_SwitchREG_Ethernet_II_ICMP_PING;

(* KEEP = "TRUE" *) reg [8-1:0]     TX_SwitchREG_Ethernet_II_IP4_HeaderHi     =   0;
(* KEEP = "TRUE" *) reg [8-1:0]     TX_SwitchREG_Ethernet_II_IP4_HeaderLo     =   0;


(* KEEP = "TRUE" *) reg     [BitWidth(BufferSize)-1:0]  ICMP_PING_Payload_RdRAM_Pointer       =0;
(* KEEP = "TRUE" *) reg [2-1:0]     RdPointerDivider  = 0;
(* KEEP = "TRUE" *) reg             RdPointerIncPulse = 0;

(* KEEP = "TRUE" *) reg [16-1:0]    wDataLength_Rd=0;
(* KEEP = "TRUE" *) reg [16-1:0]    IPv4_TotalLength                          =   0;
always @(posedge ICMP_PING_Source_CLK)
begin
IPv4_TotalLength<= wDataLength_Rd+20;//+8;
wDataLength_Rd <=  ICMP_PING_RxData_Length_Counter;

    if (ICMP_PING_StartReplyPulse)
        begin
        ICMP_PING_Payload_RdRAM_Pointer <=16'hFFFF;
        
        Tx_MAC_FrameBody_ByteCounter                <=2;

        Tx_MAC_FrameBody_VALID                      <=1'b1;
        Tx_MAC_FrameBody_TLAST                      <=1'b0;

        end
        else if (ICMP_PING_Source_TRDY)
            begin
            LoadDataPulse[3:0] <=  {RdPointerIncPulse, LoadDataPulse[3:1]};
            //if (LoadDataPulse[0])  {ShiftRegD3,ShiftRegD2,ShiftRegD1,ShiftRegD0} <=  wICMP_PING_Payload_WrRAM_Data;   ////// !!!!!!!!!!!!!!!!!!!!!!!
            if (LoadDataPulse[0])  {ShiftRegD0,ShiftRegD1,ShiftRegD2,ShiftRegD3} <=  wICMP_PING_Payload_WrRAM_Data;
                else  
                begin
                ShiftRegD0<=ShiftRegD1;
                ShiftRegD1<=ShiftRegD2;
                ShiftRegD2<=ShiftRegD3;
                ShiftRegD3<=0;
                end
            if ((Tx_MAC_FrameBody_ByteCounter ==33 )&&Tx_MAC_FrameBody_VALID) DATA_TotalLength<= wDataLength_Rd [16-1:2]  + (|wDataLength_Rd[1:0]) -1;
                else if (RdPointerIncPulse)  DATA_TotalLength <=DATA_TotalLength-1'b1;

            if ((Tx_MAC_FrameBody_ByteCounter ==33 )&&Tx_MAC_FrameBody_VALID) ReadDataState <= 1'b1; 
                //else if ((DATA_TotalLength == 0)&&RdPointerIncPulse) ReadDataState<=1'b0;
                else if (DATA_TotalLength_Full==0) ReadDataState<=1'b0;

//////////////////////////////////////////////////////////////////////////////////////
          
            if ((Tx_MAC_FrameBody_ByteCounter ==33 )&&Tx_MAC_FrameBody_VALID) 
                begin
                if (PADDING_INSERTION=="YES")
                    begin 
                    if (wDataLength_Rd > 18) DATA_TotalLength_Full<= wDataLength_Rd [16-1:0] ;// + 8 ;
                        else DATA_TotalLength_Full <= 18 ;// + 8 ;
                    end else 
                    begin 
                        DATA_TotalLength_Full<= wDataLength_Rd [16-1:0] ;// + 8 ;
                    end
                end
                else if (ReadDataState_Full) DATA_TotalLength_Full <=DATA_TotalLength_Full-1'b1;
                      
            if ((Tx_MAC_FrameBody_ByteCounter ==33 )&&Tx_MAC_FrameBody_VALID) ReadDataState_Full <= 1'b1; 
                else if ((DATA_TotalLength_Full == 0)) ReadDataState_Full<=1'b0;
                
            Tx_MAC_FrameBody_TLAST <= ReadDataState_Full && (DATA_TotalLength_Full ==0) && Tx_MAC_FrameBody_VALID;
            if (Tx_MAC_FrameBody_TLAST) Tx_MAC_FrameBody_VALID <=1'b0;

            if (ReadDataState ) RdPointerDivider <= RdPointerDivider +1 ;  else RdPointerDivider <= 0;
                
            RdPointerIncPulse <= ( RdPointerDivider == 3 ) && ReadDataState;
            
            if (RdPointerIncPulse) 
                begin
                    if (ICMP_PING_Payload_RdRAM_Pointer==(BufferSize-1)) ICMP_PING_Payload_RdRAM_Pointer <=0;  
                        else ICMP_PING_Payload_RdRAM_Pointer <= ICMP_PING_Payload_RdRAM_Pointer + 1'b1;
                end

            if (Tx_MAC_FrameBody_ByteCounter!=63) Tx_MAC_FrameBody_ByteCounter   <= Tx_MAC_FrameBody_ByteCounter +1'b1;
	    end
end 

(* KEEP = "TRUE" *) wire [8-1:0]     wTx_MAC_FrameBody_TDATA;

(* KEEP_HIERARCHY = "TRUE" *)
Ethernet_II_MAC_Header_Generator
 #(.EtherTypeValue(16'h0800))   
Ethernet_II_MAC_Header_Generator_inst
(
.CLK                                (ICMP_PING_Source_CLK),
.MAC_TRY                            (ICMP_PING_Source_TRDY),
.MAC_Header_PreSet                  (ICMP_PING_StartReplyPulse),
.MAC_Header_Position                (Tx_MAC_FrameBody_ByteCounter),
.MAC_LOCAL_ADDR                     (MAC_LOCAL_ADDR_IN),
.MAC_REMOTE_ADDR                    (MAC_REMOTE_ADDR_IN),

.MAC_Header                         (wTX_SwitchREG_Ethernet_II_MAC)
);

(* KEEP_HIERARCHY = "TRUE" *)
IPv4_Header_Generator    
#(.IPv4_Protocol_Number(8'h1)) 
IPv4_Header_Generator_inst
(
.CLK                                (ICMP_PING_Source_CLK),
.IPv4_TRY                           (ICMP_PING_Source_TRDY),
.IPv4_TotalLength                   (IPv4_TotalLength),
.IPv4_Header_Position               (Tx_MAC_FrameBody_ByteCounter),
.IPv4_LOCAL_ADDR                    (IP4_LOCAL_ADDR_IN),
.IPv4_REMOTE_ADDR                   (IP4_REMOTE_ADDR_IN),

.IPv4_Header                        (wTX_SwitchREG_Ethernet_II_IP4)
);

(* KEEP_HIERARCHY = "TRUE" *)
ICMP_PING_IPv4_Header_Generator_x8  ICMP_PING_IPv4_Header_Generator_x8_inst
(
.CLK                                ( ICMP_PING_Source_CLK                  ),
.ICMP_PING_Position                 ( Tx_MAC_FrameBody_ByteCounter          ),
.ICMP_PING_CheckSUM_Reply           (wICMP_PING_CheckSUM_Reply              ),
.ICMP_PING_Identifier               ( ICMP_PING_Req_Header_Identifier       ),
.ICMP_PING_Sequence_Number          ( ICMP_PING_Req_Header_SequenceNumber   ),

.ICMP_PING_Header                   (wTX_SwitchREG_Ethernet_II_ICMP_PING    )
);

(* KEEP_HIERARCHY = "TRUE" *)
ICMP_UDP_Frame_Header_Multiplexer   ICMP_Frame_Header_Multiplexer_inst
(
.CLK                                (ICMP_PING_Source_CLK                   ),

.Frame_TRY                          (ICMP_PING_Source_TRDY                  ),
.Frame_PreSet                       (ICMP_PING_StartReplyPulse              ),
.Frame_PreSetValue                  (MAC_REMOTE_ADDR_IN [47:40]             ),
.Frame_Position                     (Tx_MAC_FrameBody_ByteCounter           ),

.Header_Ethernet_II_MAC_Part        (wTX_SwitchREG_Ethernet_II_MAC          ),
.Header_IPv4_Part                   (wTX_SwitchREG_Ethernet_II_IP4          ),
.Header_ICMP_PING_Part              (wTX_SwitchREG_Ethernet_II_ICMP_PING    ),
.Data_Payload_Part                  (ShiftRegD0),

.Tx_MAC_FrameBody_TDATA             (wTx_MAC_FrameBody_TDATA                )
);

(* KEEP_HIERARCHY = "TRUE" *)
ICMP_PING_RAM_DataBuffer_x32 
#(
.ARCH ("XLX_ULTRASCALE" ),
.BUFFER_COUNT_1K(1)
) ICMP_PING_RAM_DataBuffer_x32_inst
(
. WrClk                             ( Sink_CLK                            ),
. WrEna                             (wICMP_Core_TVALID_x32                ),
. WrWea                             ( {4{ICMP_PING_WrWea}}                ),
. WrAddress                         ( ICMP_PING_Payload_WrRAM_Pointer     ),
. WrData                            (wICMP_Core_TDATA_x32                 ),

. RdClk                             ( ICMP_PING_Source_CLK                ),
. RdEna                             ( 1'b1                                ),
. RdAddress                         ( ICMP_PING_Payload_RdRAM_Pointer     ),
. RdData                            (wICMP_PING_Payload_WrRAM_Data        )
);

assign ICMP_PING_Source_TVALID  =   Tx_MAC_FrameBody_VALID;
assign ICMP_PING_Source_TLAST   =   Tx_MAC_FrameBody_TLAST;
assign ICMP_PING_Source_TDATA   =  wTx_MAC_FrameBody_TDATA;
assign ICMP_PING_Source_TERROR  = 0;

endmodule
