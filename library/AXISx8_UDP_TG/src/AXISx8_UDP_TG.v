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

module AXISx8_UDP_TG
#(
//    parameter MB_ARCH			= "XLX_ULTRASCALE",
    parameter PADDING_INSERTION = "YES" ,  // "YES" or "NO"
//    parameter DROP_IF_OVERFLOW  = "YES" ,  // "YES" or "NO"
//    parameter UDP_CHECKSUM_CALK = "YES" ,  // "YES" or "NO"
//    parameter BUFFER_COUNT_1K   = 3     ,
    parameter ETHERNET_MTU      = 1*1024      
) 
(     
 	input  wire [16-1:0]   			UDP_LOCAL_PORT_IN          ,
	input  wire [16-1:0]   			UDP_REMOTE_PORT_IN         ,

	input  wire [32-1:0]   			IP4_LOCAL_ADDR_IN          ,
	input  wire [32-1:0]   			IP4_REMOTE_ADDR_IN         ,

	input  wire [48-1:0]   			MAC_LOCAL_ADDR_IN          ,  
    input  wire [48-1:0]   			MAC_REMOTE_ADDR_IN         ,
    
    input  wire                     TG_Start_Pulse             ,
    input  wire [32-1:0]            TG_PacketCount             ,
    input  wire [16-1:0]            TG_PacketSize              ,    
    input  wire [16-1:0]            TG_PacketGap               ,
    
    input   wire                   	Source_CLK                 ,
    input   wire [1-1:0]	       	Source_TRDY                ,
    output  wire [1-1:0]	       	Source_TVALID              ,
    output  wire [1-1:0]	       	Source_TLAST               ,
    output  wire [8-1:0]           	Source_TDATA
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

localparam MAX_Eth_PayloadSize = ETHERNET_MTU - 0;
localparam MAX_IP4_PayloadSize = ETHERNET_MTU - 20;
localparam MAX_UDP_PayloadSize = ETHERNET_MTU - 28;

//localparam BufferSize = (BUFFER_COUNT_1K==0) ? 128 : BUFFER_COUNT_1K * (1024/4); 

generate if ( ETHERNET_MTU <= 28                         )             begin AXISx32_UDP_Tx_Offload_Engine_Error MTU_Erorr ( );           end	endgenerate
//if ((BufferSize*4) < MAX_UDP_PayloadSize        )             begin AXISx32_UDP_Tx_Offload_Engine_Error BufferSize_Erorr ( );    end
//generate if ((BUFFER_COUNT_1K>16)                        )             begin AXISx32_UDP_Tx_Offload_Engine_Error BufferCount_Erorr ( );   end	endgenerate



(* KEEP = "TRUE" *) wire [16-1:0]    wDataLength_Rd   ;
(* KEEP = "TRUE" *) wire [16-1:0]    wUDP_Checksum_Rd ;



(* KEEP = "TRUE" *) reg  [16-1:0]    DATA_TotalLength_Full                     =   0;

(* KEEP = "TRUE" *) reg  [14-1:0]    DATA_TotalLength                          =   0;

(* KEEP = "TRUE" *) reg [16-1:0]    UDP_TotalLength                           =   0;
(* KEEP = "TRUE" *) reg [16-1:0]    UDP_Checksum                              =   0;

(* KEEP = "TRUE" *) reg [16-1:0]    IPv4_TotalLength                          =   0;

(* KEEP = "TRUE" *) reg             Tx_MAC_FrameBody_StartReadPulse           =   0;

(* KEEP = "TRUE" *) reg             Tx_MAC_FrameBody_VALID                    =   0;
(* KEEP = "TRUE" *) reg             Tx_MAC_FrameBody_TLAST                    =   0;
//reg [8-1:0]     Tx_MAC_FrameBody_TDATA                    =   0;
(* KEEP = "TRUE" *) wire[8-1:0]    wTx_MAC_FrameBody_TDATA;



(* KEEP = "TRUE" *) reg ReadDonePulse = 0 ;


(* KEEP = "TRUE" *) reg [6-1:0]     Tx_MAC_FrameBody_ByteCounter              =   63;

(* KEEP = "TRUE" *) reg [3-1:0]     TX_SwitchREG_Decoder                      =   0;

(* KEEP = "TRUE" *) wire[8-1:0]    wTX_SwitchREG_Ethernet_II_MAC;
(* KEEP = "TRUE" *) wire[8-1:0]    wTX_SwitchREG_Ethernet_II_IP4;
(* KEEP = "TRUE" *) wire[8-1:0]    wTX_SwitchREG_Ethernet_II_UDP;

(* KEEP = "TRUE" *) reg [2-1:0]     RdPointerDivider  = 0;
(* KEEP = "TRUE" *) reg             RdPointerIncPulse = 0;

(* KEEP = "TRUE" *) reg [4-1:0]     LoadDataPulse = 0;

(* KEEP = "TRUE" *) reg             ReadDataState = 0;
(* KEEP = "TRUE" *) reg             ReadDataState_Full = 0;

(* KEEP = "TRUE" *) reg [8-1:0]     ShiftRegD0 = 0;
(* KEEP = "TRUE" *) reg [8-1:0]     ShiftRegD1 = 0;
(* KEEP = "TRUE" *) reg [8-1:0]     ShiftRegD2 = 0;
(* KEEP = "TRUE" *) reg [8-1:0]     ShiftRegD3 = 0;

(* KEEP = "TRUE" *) wire             wCommandFOFO_Empty;
(* KEEP = "TRUE" *) wire [32-1:0]    wRdData;


(* KEEP = "TRUE" *) reg  [16-1:0]    TG_PacketSizeReg =0;

(* KEEP = "TRUE" *) reg  [16-1:0]    TG_GapCounter =0;
(* KEEP = "TRUE" *) reg  [16-1:0]    TG_GapThreshold =0;

(* KEEP = "TRUE" *) reg  [32-1:0]    TG_PacketCounter =0;
(* KEEP = "TRUE" *) reg  [32-1:0]    TG_PacketCountThreshold =0;

assign wDataLength_Rd = TG_PacketSizeReg;


(* KEEP = "TRUE" *) reg [2-1:0]  READ_STATE=0;
always @(posedge Source_CLK)
begin 
if (TG_Start_Pulse) TG_PacketCountThreshold <= TG_PacketCount;
if (TG_Start_Pulse) TG_PacketCounter <= 0;
    else if (ReadDonePulse) TG_PacketCounter <= TG_PacketCounter +1;
    
if (TG_Start_Pulse)
    begin
    TG_GapThreshold <=  TG_PacketGap[15:0]; 
    if (TG_PacketSize[15:0]<4) TG_PacketSizeReg <=  4; 
        else TG_PacketSizeReg <=  TG_PacketSize[15:0]; 
    end    
    


if ((READ_STATE==0) ) 
    begin
    if (TG_PacketCounter<TG_PacketCountThreshold) READ_STATE<=READ_STATE+1;
    end else 
    if ((READ_STATE==1) ) 
        begin
        READ_STATE<=READ_STATE+1;
        end else 
        if ((READ_STATE==2))
            begin
            if (ReadDonePulse) 
                begin
                READ_STATE <= READ_STATE+1;
                TG_GapCounter <=0;
                end
            end else 
            if ((READ_STATE==3 ))
                begin
                TG_GapCounter <= TG_GapCounter+1;
                if (TG_GapCounter == TG_GapThreshold) READ_STATE <= READ_STATE+1;
                end 
        
Tx_MAC_FrameBody_StartReadPulse <=   (READ_STATE==1);
// Error condition (size ??? )
// Error condition Sync FIRST/LAST error
end



always @(posedge Source_CLK)
begin
ReadDonePulse <= Source_TRDY && Tx_MAC_FrameBody_TLAST && Tx_MAC_FrameBody_VALID;
IPv4_TotalLength<= wDataLength_Rd+8+20;
UDP_TotalLength <= wDataLength_Rd+8;
//UDP_Checksum    <= wUDP_Checksum_Rd;
UDP_Checksum    <= 0;


    if (Tx_MAC_FrameBody_StartReadPulse)
        begin
        Tx_MAC_FrameBody_ByteCounter                <=2;
        TX_SwitchREG_Decoder                        <=0;
        Tx_MAC_FrameBody_VALID                      <=1'b1;
        Tx_MAC_FrameBody_TLAST                      <=1'b0;

        end
        else if (Source_TRDY)
            begin
            LoadDataPulse[3:0] <=  {RdPointerIncPulse, LoadDataPulse[3:1]};
            if (LoadDataPulse[0])  {ShiftRegD3,ShiftRegD2,ShiftRegD1,ShiftRegD0} <=  TG_PacketCounter;
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
                else if ((DATA_TotalLength == 0)&&RdPointerIncPulse) ReadDataState<=1'b0;
                

//////////////////////////////////////////////////////////////////////////////////////
          
            if ((Tx_MAC_FrameBody_ByteCounter ==33 )&&Tx_MAC_FrameBody_VALID) 
                begin
                if (PADDING_INSERTION=="YES")
                    begin 
                    if (wDataLength_Rd > 18) DATA_TotalLength_Full<= wDataLength_Rd [16-1:0]  + 8 ;
                        else DATA_TotalLength_Full <= 18  + 8 ;
                    end else 
                    begin 
                        DATA_TotalLength_Full<= wDataLength_Rd [16-1:0]  + 8 ;
                    end
                end
                else if (ReadDataState_Full) DATA_TotalLength_Full <=DATA_TotalLength_Full-1'b1;
                      
            if ((Tx_MAC_FrameBody_ByteCounter ==33 )&&Tx_MAC_FrameBody_VALID) ReadDataState_Full <= 1'b1; 
                else if ((DATA_TotalLength_Full == 0)) ReadDataState_Full<=1'b0;
                
            Tx_MAC_FrameBody_TLAST <= ReadDataState_Full && (DATA_TotalLength_Full ==0) && Tx_MAC_FrameBody_VALID;
            if (Tx_MAC_FrameBody_TLAST) Tx_MAC_FrameBody_VALID <=1'b0;

            if (ReadDataState ) RdPointerDivider <= RdPointerDivider +1 ;  else RdPointerDivider <= 0;
                
            RdPointerIncPulse <= ( RdPointerDivider == 3 );

            if (Tx_MAC_FrameBody_ByteCounter!=63) Tx_MAC_FrameBody_ByteCounter   <= Tx_MAC_FrameBody_ByteCounter +1'b1;

	        end                
end	                    

(* KEEP_HIERARCHY = "TRUE" *)
Ethernet_II_MAC_Header_Generator  
#(
.EtherTypeValue(16'h0800)
)Ethernet_II_MAC_Header_Generator_inst
(
.CLK                                (Source_CLK),
.MAC_TRY                            (Source_TRDY),
.MAC_Header_PreSet                  (Tx_MAC_FrameBody_StartReadPulse),
.MAC_Header_Position                (Tx_MAC_FrameBody_ByteCounter),
.MAC_LOCAL_ADDR                     (MAC_LOCAL_ADDR_IN),
.MAC_REMOTE_ADDR                    (MAC_REMOTE_ADDR_IN),

.MAC_Header                         (wTX_SwitchREG_Ethernet_II_MAC)
);

(* KEEP_HIERARCHY = "TRUE" *)
IPv4_Header_Generator    
#(.IPv4_Protocol_Number(8'd17)) 
IPv4_Header_Generator_inst
(
.CLK                                (Source_CLK),
.IPv4_TRY                           (Source_TRDY),
.IPv4_TotalLength                   (IPv4_TotalLength),
.IPv4_Header_Position               (Tx_MAC_FrameBody_ByteCounter),
.IPv4_LOCAL_ADDR                    (IP4_LOCAL_ADDR_IN),
.IPv4_REMOTE_ADDR                   (IP4_REMOTE_ADDR_IN),

.IPv4_Header                        (wTX_SwitchREG_Ethernet_II_IP4)
);

(* KEEP_HIERARCHY = "TRUE" *)
UDP_Header_Generator                UDP_Header_Generator_inst
(
.CLK                                (Source_CLK                             ),

.UDP_TRDY                           (Source_TRDY                            ),

.UDP_LOCAL_PORT_IN                  (UDP_LOCAL_PORT_IN                      ),
.UDP_REMOTE_PORT_IN                 (UDP_REMOTE_PORT_IN                     ),
.UDP_TotalLength                    (UDP_TotalLength                        ),
.UDP_Checksum                       (UDP_Checksum                           ),
.UDP_Position                       (Tx_MAC_FrameBody_ByteCounter           ),

.UDP_Header                         (wTX_SwitchREG_Ethernet_II_UDP          ) 
);

(* KEEP_HIERARCHY = "TRUE" *)
ICMP_UDP_Frame_Header_Multiplexer   UDP_Frame_Header_Multiplexer_inst
(
.CLK                                (Source_CLK                             ),

.Frame_TRDY                         (Source_TRDY                            ),
.Frame_PreSet                       (Tx_MAC_FrameBody_StartReadPulse        ),
.Frame_PreSetValue                  (MAC_REMOTE_ADDR_IN [47:40]             ),
.Frame_Position                     (Tx_MAC_FrameBody_ByteCounter           ),

.Header_Ethernet_II_MAC_Part        (wTX_SwitchREG_Ethernet_II_MAC          ),
.Header_IPv4_Part                   (wTX_SwitchREG_Ethernet_II_IP4          ),
.Header_ICMP_PING_Part              (wTX_SwitchREG_Ethernet_II_UDP          ),
.Data_Payload_Part                  (ShiftRegD0),

.Tx_MAC_FrameBody_TDATA             (wTx_MAC_FrameBody_TDATA                )
);

assign Source_TVALID    =   Tx_MAC_FrameBody_VALID;
assign Source_TLAST     =   Tx_MAC_FrameBody_TLAST;
//assign Source_TDATA     =   Tx_MAC_FrameBody_TDATA;
assign Source_TDATA     =  wTx_MAC_FrameBody_TDATA;    

endmodule

