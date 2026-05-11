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

module AXISx8_UDP_Framing_AXISx32_Sink
#(
    parameter ARCH = "XLX_ULTRASCALE"   ,
    parameter PADDING_INSERTION = "YES" ,  // "YES" or "NO"
    parameter DROP_IF_OVERFLOW  = "YES" ,  // "YES" or "NO"
    parameter ETHERNET_MTU = 1*1024     ,
    parameter BUFFER_COUNT_1K = 3   
) 
(     
    input  wire                     DATA_CLK,
    output wire                     DATA_Payload_Sink_TRDY  ,
    input  wire                     DATA_Payload_Sink_TVALID,
    input  wire                     DATA_Payload_Sink_TLAST,
    input  wire [ 4-1:0]            DATA_Payload_Sink_TKEEP,
    input  wire [32-1:0]            DATA_Payload_Sink_TDATA,
    
    output reg  [32-1:0]            DATA_DROP_Cnt =        0,
 
 	input  wire [16-1:0]   			UDP_LOCAL_PORT       	,
	input  wire [16-1:0]   			UDP_REMOTE_PORT       	,

	input  wire [32-1:0]   			IPv4_LOCAL_ADDR       	,
	input  wire [32-1:0]   			IPv4_REMOTE_ADDR       	,

	input  wire [48-1:0]   			MAC_LOCAL_ADDR        	,  
    input  wire [48-1:0]   			MAC_REMOTE_ADDR       	,

    input   wire                   	TX_CLK,
    input   wire [1-1:0]	       	TX_FrameBody_Source_TRDY,
    output  wire [1-1:0]	       	TX_FrameBody_Source_TVALID,
    output  wire [1-1:0]	       	TX_FrameBody_Source_TLAST,
    output  wire [8-1:0]           	TX_FrameBody_Source_TDATA
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

localparam BufferSize = BUFFER_COUNT_1K*(1024/4); // BUFFER_COUNT_1K * 256 

if ( ETHERNET_MTU <= 28                         )             begin AXISx32_UDP_Tx_Offload_Engine_Error MTU_Erorr ( );           end
if ((BufferSize*4) < MAX_UDP_PayloadSize        )             begin AXISx32_UDP_Tx_Offload_Engine_Error BufferSize_Erorr ( );    end
if ((BUFFER_COUNT_1K==0)||(BUFFER_COUNT_1K>16)  )             begin AXISx32_UDP_Tx_Offload_Engine_Error BufferCount_Erorr ( );   end
        
//////////////////////////////////////////////////////////////////////////////////////
// find the beginning of a package 
reg  TLAST_DONE_FLAG=1;
wire DATA_TFIRST;
always @(posedge DATA_CLK) begin if (DATA_Payload_Sink_TVALID&&DATA_Payload_Sink_TLAST) TLAST_DONE_FLAG<=1; else if (DATA_Payload_Sink_TVALID) TLAST_DONE_FLAG<=0; end
assign DATA_TFIRST =  TLAST_DONE_FLAG && DATA_Payload_Sink_TVALID ;
//////////////////////////////////////////////////////////////////////////////////////
wire [ 4-1:0]           wDATA_Payload_Sink_TKEEP;
wire [ 4-1:0]           wDATA_COUNT;

wire [32-1:0]           wDATA_Payload_Sink_TDATA;

assign wDATA_Payload_Sink_TKEEP  [ 4-1:0]  = { DATA_Payload_Sink_TKEEP[3]&& wDATA_Payload_Sink_TKEEP[2],DATA_Payload_Sink_TKEEP[2]&&wDATA_Payload_Sink_TKEEP[1], DATA_Payload_Sink_TKEEP[1]&&wDATA_Payload_Sink_TKEEP[0],DATA_Payload_Sink_TKEEP[0]};

assign wDATA_COUNT  [ 4-1:0]  = ((wDATA_Payload_Sink_TKEEP==4'b0001)&&DATA_Payload_Sink_TLAST) ? 4'h1 :
                                ((wDATA_Payload_Sink_TKEEP==4'b0011)&&DATA_Payload_Sink_TLAST) ? 4'h2 :
                                ((wDATA_Payload_Sink_TKEEP==4'b0111)&&DATA_Payload_Sink_TLAST) ? 4'h3 :
                                ((wDATA_Payload_Sink_TKEEP==4'b1111)&&DATA_Payload_Sink_TLAST) ? 4'h4 :
                                4'h4;
                                
assign wDATA_Payload_Sink_TDATA  [32-1:0]  =    ((wDATA_Payload_Sink_TKEEP==4'b0001)&&DATA_Payload_Sink_TLAST) ? {24'h00,DATA_Payload_Sink_TDATA[ 7:0]} :
                                                ((wDATA_Payload_Sink_TKEEP==4'b0011)&&DATA_Payload_Sink_TLAST) ? {16'h00,DATA_Payload_Sink_TDATA[15:0]} :
                                                ((wDATA_Payload_Sink_TKEEP==4'b0111)&&DATA_Payload_Sink_TLAST) ? { 8'h00,DATA_Payload_Sink_TDATA[23:0]} :
                                                ((wDATA_Payload_Sink_TKEEP==4'b1111)&&DATA_Payload_Sink_TLAST) ? DATA_Payload_Sink_TDATA[31:0] : DATA_Payload_Sink_TDATA[31:0];  

wire wCommandFIFO_Full;
 
 
reg          TVALID_Reg0=0;
reg          TVALID_Reg1=0;
reg          TVALID_Reg2=0; 

reg          TFIRST_Reg0=0;
reg          TFIRST_Reg1=0;
reg          TFIRST_Reg2=0; 

reg          TLAST_Reg0=0;
reg          TLAST_Reg1=0;
reg          TLAST_Reg2=0; 
                                                            
reg [ 4-1:0] TKEEP_Reg0=0;  
reg [ 4-1:0] TKEEP_Reg1=0;       
reg [ 4-1:0] TKEEP_Reg2=0;

reg [32-1:0] TDATA_Reg0=0;  
reg [32-1:0] TDATA_Reg1=0;       
reg [32-1:0] TDATA_Reg2=0;
    
reg [16-1:0] RxDataLengthCounter=0;
reg [16-1:0] RxDataLengthCounter_D1=0;
reg [16-1:0] RxDataLengthCounter_D2=0;

reg [32-1:0] UDP_CheckSUM_Data_L=0;
reg [32-1:0] UDP_CheckSUM_Data_H=0;
reg [32-1:0] UDP_CheckSUM_Data=0;

//reg [17-1:0] UDP_CheckSUM_IP4_Internal          =0;
//reg [17-1:0] UDP_CheckSUM_IP4_External          =0;
reg [18-1:0] UDP_CheckSUM_IP4_SUM               =0;
reg [20-1:0] UDP_CheckSUM_IP4_PseudoHeader      =0;

reg [32-1:0] UDP_CheckSUM_FULL                  =0;

//reg [16-1:0] CheckSUM_UDP                   =0;
wire[16-1:0]wCheckSUM_UDP;


reg   PacketDropFlag=0; 
wire  wPacketDropFlag; 
reg   PacketWasDropedFlag=0; 

reg                                 WrCommandToFIFO =0;

reg                                 WrOverflow_n    =0;
reg                                 WrWea           =0;
reg     [32-1: 0]                   WrData          =0;
reg     [BitWidth(BufferSize)-1:0]  WrPointer       =0;
reg     [BitWidth(BufferSize)-1:0]  WrPointerReserve=0;

reg     [BitWidth(BufferSize)  :0]  WrBufferElements=0;

reg     [BitWidth(BufferSize)-1:0]  RdPointer       =0;
wire    [BitWidth(BufferSize)-1:0] wRdPointerGray;
wire    [BitWidth(BufferSize)-1:0] wRdPointer;  


reg RxPacketValid=0;
//reg RxPacketValid_D1=0;

assign wCheckSUM_UDP = ~(UDP_CheckSUM_FULL[16-1: 0] + UDP_CheckSUM_FULL[32-1:16]) ;
assign wPacketDropFlag = (RxDataLengthCounter>MAX_UDP_PayloadSize) || (  (DROP_IF_OVERFLOW == "YES" ) && (( WrBufferElements > (BufferSize- 8))||wCommandFIFO_Full)); 

wire 	wWrDataRDY;
if (DROP_IF_OVERFLOW == "YES" ) assign 	wWrDataRDY = 1; else  assign 	wWrDataRDY = WrOverflow_n;
assign 	DATA_Payload_Sink_TRDY = wWrDataRDY;

(* KEEP_HIERARCHY = "TRUE" *)
Gray2BinRegisteredInOut #( .WIDTH(BitWidth(BufferSize)) ) Gray2BinRegisteredInOut_inst
(
.Clk                (DATA_CLK),
.GrayIn             (wRdPointerGray),
.BinOut             (wRdPointer)
 ); 

always @(posedge DATA_CLK) WrOverflow_n  <= !(( WrBufferElements > (BufferSize- 8))||wCommandFIFO_Full);  

always @(posedge DATA_CLK)
begin
if (WrPointer>=wRdPointer) WrBufferElements <= WrPointer - wRdPointer;
    else WrBufferElements <= WrPointer - wRdPointer + BufferSize;

if (wWrDataRDY)
    begin

    if (TVALID_Reg0 && wPacketDropFlag) RxPacketValid<=1'b0;
	   else if (TFIRST_Reg0 ) RxPacketValid<=1'b1;	   

    TVALID_Reg0 <= DATA_Payload_Sink_TVALID;
    TVALID_Reg1 <= TVALID_Reg0;
    TVALID_Reg2 <= TVALID_Reg1;
    
    TFIRST_Reg0 <= DATA_TFIRST;
    TFIRST_Reg1 <= TFIRST_Reg0;
    TFIRST_Reg2 <= TFIRST_Reg1;

    TLAST_Reg0  <= DATA_Payload_Sink_TLAST ;
    TLAST_Reg1  <= TLAST_Reg0 ;
    TLAST_Reg2  <= TLAST_Reg1 ;
    
    TKEEP_Reg0  <= wDATA_Payload_Sink_TKEEP ;
    TKEEP_Reg1  <= TKEEP_Reg0 ;
    TKEEP_Reg2  <= TKEEP_Reg1 ;
    
    TDATA_Reg0  <= wDATA_Payload_Sink_TDATA;
    TDATA_Reg1  <= TDATA_Reg0 ;
    TDATA_Reg2  <= TDATA_Reg1 ;

	/////////////////////////////////////////////////////////////////////////////////////////////

	if (DATA_Payload_Sink_TVALID&&DATA_TFIRST) RxDataLengthCounter <= wDATA_COUNT;  
		else if (DATA_Payload_Sink_TVALID&&(RxDataLengthCounter>MAX_UDP_PayloadSize)) RxDataLengthCounter <= RxDataLengthCounter;  
			else if (DATA_Payload_Sink_TVALID) RxDataLengthCounter <= RxDataLengthCounter + wDATA_COUNT;  

	if (DATA_Payload_Sink_TVALID&&DATA_TFIRST) UDP_CheckSUM_Data_L <= {16'h00,wDATA_Payload_Sink_TDATA[16-1:0 ]}; 
		else if (DATA_Payload_Sink_TVALID) UDP_CheckSUM_Data_L <=UDP_CheckSUM_Data_L + {16'h00,wDATA_Payload_Sink_TDATA[16-1:0 ]};   
		
	if (DATA_Payload_Sink_TVALID&&DATA_TFIRST) UDP_CheckSUM_Data_H <= {16'h00,wDATA_Payload_Sink_TDATA[32-1:16]}; 
		else if (DATA_Payload_Sink_TVALID) UDP_CheckSUM_Data_H <=UDP_CheckSUM_Data_H + {16'h00,wDATA_Payload_Sink_TDATA[32-1:16]};
			
	UDP_CheckSUM_Data               <=  UDP_CheckSUM_Data_L + UDP_CheckSUM_Data_H;
	
	//UDP_CheckSUM_IP4_Internal       <=  {1'b0,IPv4_LOCAL_ADDR[16-1: 0]   }   +   {1'b0,IPv4_LOCAL_ADDR[32-1:16]};
	//UDP_CheckSUM_IP4_External       <=  {1'b0,IPv4_REMOTE_ADDR[16-1: 0]  }   +   {1'b0,IPv4_REMOTE_ADDR[32-1:16]};
	//UDP_CheckSUM_IP4_SUM            <=  {1'b0,UDP_CheckSUM_IP4_Internal }   +   {1'b0,UDP_CheckSUM_IP4_External};
	
    UDP_CheckSUM_IP4_SUM            <=  {2'b00,IPv4_LOCAL_ADDR[16-1: 0]   }   +   {2'b00,IPv4_LOCAL_ADDR[32-1:16]} 
                                            + {2'b00,IPv4_REMOTE_ADDR[16-1: 0]  }   +   {2'b00,IPv4_REMOTE_ADDR[32-1:16]};
	
	UDP_CheckSUM_IP4_PseudoHeader   <=  {2'b0,UDP_CheckSUM_IP4_SUM      }   +   {4'b0,  RxDataLengthCounter}  + 20'd17;
	UDP_CheckSUM_FULL               <=  UDP_CheckSUM_Data                   +   {12'b0, UDP_CheckSUM_IP4_PseudoHeader }; 
	//CheckSUM_UDP                <= ~(CheckSUM_FULL[16-1: 0]             +   CheckSUM_FULL[32-1:16]) ;
	
	RxDataLengthCounter_D1 <= RxDataLengthCounter;
	RxDataLengthCounter_D2 <= RxDataLengthCounter_D1;
	
    if (TVALID_Reg1 && TLAST_Reg1 && !RxPacketValid) PacketWasDropedFlag <=1'b1;
        else if (TVALID_Reg1 && TFIRST_Reg1 ) PacketWasDropedFlag <=1'b0;
        
    if (TVALID_Reg1 && TLAST_Reg1 && !RxPacketValid)  DATA_DROP_Cnt <= DATA_DROP_Cnt + 1'b1;    
	
	if (TVALID_Reg1 && TFIRST_Reg1 && ! PacketWasDropedFlag) WrPointerReserve <= WrPointer+1 ;

	if (TVALID_Reg1 && TFIRST_Reg1 &&  PacketWasDropedFlag && RxPacketValid) WrPointer <= WrPointerReserve;
		else if (TVALID_Reg1 && (WrPointer==(BufferSize-1))&& RxPacketValid) WrPointer <=0;
			else if (TVALID_Reg1 && RxPacketValid && RxPacketValid) WrPointer<= WrPointer+1;
	
	WrData  <= TDATA_Reg1;
	WrWea   <= TVALID_Reg1 && RxPacketValid;  
    end 
    
WrCommandToFIFO <= (TVALID_Reg1 && TLAST_Reg1 && RxPacketValid && wWrDataRDY );     
end

wire [16-1:0]    wDataLength_Rd   ;
wire [16-1:0]    wUDP_Checksum_Rd ;

wire             wCommandFOFO_Empty;

wire [32-1:0]    wRdData;

reg ReadDonePulse = 0 ;

(* KEEP_HIERARCHY = "TRUE" *)
UDP_CommandFIFOx36          UDP_CommandFIFOx36_inst
(
.WrClk      (DATA_CLK),
.WrRst      (1'b0),
.WrEna      (WrCommandToFIFO),
.WrDat      ({4'b0000,16'h0,RxDataLengthCounter_D2}),

.RdClk      (TX_CLK),
.RdEna      (ReadDonePulse),
.RdEpt      (wCommandFOFO_Empty),
.RdPgF      (wCommandFIFO_Full),
.RdDat      ({ wUDP_Checksum_Rd, wDataLength_Rd })
);

(* KEEP_HIERARCHY = "TRUE" *)
UDP_RAM_DataBuffer_x32 
#(
.ARCH ("XLX_ULTRASCALE" ),
.BUFFER_COUNT_1K(BUFFER_COUNT_1K)
) UDP_RAM_DataBuffer_x32_inst
(
. WrClk       (DATA_CLK     ),
. WrEna       (wWrDataRDY   ),
. WrWea       ({4{WrWea}}   ),
. WrAddress   (WrPointer    ),
. WrData      (WrData       ),

. RdClk       (TX_CLK),
. RdEna       (1'b1),
. RdAddress   (RdPointer),
. RdData      (wRdData)
);

(* KEEP_HIERARCHY = "TRUE" *)
Bin2GrayRegisteredOut #( .WIDTH(BitWidth(BufferSize)) ) Bin2GrayRegisteredOut_inst
(
.Clk                 (TX_CLK),
.BinIn               (RdPointer),
.GrayOut             (wRdPointerGray)
 ); 

reg  [16-1:0]    DATA_TotalLength_Full                     =   0;

reg  [14-1:0]    DATA_TotalLength                          =   0;
reg  [ 4-1:0]    DATA_LastPosition                         =   0;
wire [ 4-1:0]   wDATA_LastPosition;

reg [16-1:0]    UDP_TotalLength                           =   0;
reg [16-1:0]    UDP_Checksum                              =   0;

reg [16-1:0]    IPv4_TotalLength                          =   0;
reg [16-1:0]    IPv4_Identification                       =   0;

reg [16-1:0]    IPv4_HeaderChecksum                       =   0;
reg  [23:0]     IPv4_HeaderChecksum_Step0                 =   0;
reg  [23:0]     IPv4_HeaderChecksum_Step1                 =   0;
reg  [23:0]     IPv4_HeaderChecksum_Step2                 =   0;
reg  [23:0]     IPv4_HeaderChecksum_Step3                 =   0;
reg  [16:0]     IPv4_HeaderChecksum_Step4                 =   0;

reg             Tx_MAC_FrameBody_StartReadPulse           =   0;

reg             Tx_MAC_FrameBody_VALID                    =   0;
reg             Tx_MAC_FrameBody_TLAST                    =   0;
reg [8-1:0]     Tx_MAC_FrameBody_TDATA                    =   0;
reg [6-1:0]     Tx_MAC_FrameBody_ByteCounter              =   63;

reg [3-1:0]     TX_SwitchREG_Decoder                      =   0;

wire[8-1:0]    wTX_SwitchREG_Ethernet_II_MAC;
wire[8-1:0]    wTX_SwitchREG_Ethernet_II_IP4;

//reg [8-1:0]     TX_SwitchREG_Ethernet_II_External_MAC     =   0;
//reg [8-1:0]     TX_SwitchREG_Ethernet_II_Internal_MAC     =   0;
//reg [8-1:0]     TX_SwitchREG_Ethernet_II_IP4_HeaderHi     =   0;
//reg [8-1:0]     TX_SwitchREG_Ethernet_II_IP4_HeaderLo     =   0;
reg [8-1:0]     TX_SwitchREG_Ethernet_II_UDP_Header       =   0;

reg [2-1:0]     RdPointerDivider  = 0;
reg             RdPointerIncPulse = 0;

reg [4-1:0]     LoadDataPulse = 0;

reg             ReadDataState = 0;
reg             ReadDataState_Full = 0;

reg [8-1:0]     ShiftRegD0 = 0;
reg [8-1:0]     ShiftRegD1 = 0;
reg [8-1:0]     ShiftRegD2 = 0;
reg [8-1:0]     ShiftRegD3 = 0;


//reg             FinishPulse = 0;
reg [8-1:0]     FinishPulse = 0;



reg [2-1:0]  READ_STATE=0;
always @(posedge TX_CLK)
begin 
if ((READ_STATE==0) ) 
    begin
    if (!wCommandFOFO_Empty) READ_STATE<=READ_STATE+1;
    end else 
    if ((READ_STATE==1) ) 
        begin
        READ_STATE<=READ_STATE+1;
        end else 
        if ((READ_STATE==2))
            begin
            if (ReadDonePulse) READ_STATE <= READ_STATE+1;
            end else 
            if ((READ_STATE==3 ))
                begin
                READ_STATE <= READ_STATE+1;
                end 
        
Tx_MAC_FrameBody_StartReadPulse <=   (READ_STATE==1);
// Error condition (size ??? )
// Error condition Sync FIRST/LAST error
end

assign wDATA_LastPosition = (wDataLength_Rd[1:0] == 2'd1 ) ? 4'b0001 :
                            (wDataLength_Rd[1:0] == 2'd2 ) ? 4'b0010 :
                            (wDataLength_Rd[1:0] == 2'd3 ) ? 4'b0100 :4'b1000 ;

always @(posedge TX_CLK)
begin
IPv4_HeaderChecksum_Step0   <=  IPv4_REMOTE_ADDR[31:16]+IPv4_REMOTE_ADDR[15: 0];
IPv4_HeaderChecksum_Step1   <=  IPv4_Identification + IPv4_TotalLength ;
IPv4_HeaderChecksum_Step2   <=  IPv4_HeaderChecksum_Step0 + IPv4_HeaderChecksum_Step1 + 16'h4500 + 16'h8011  ;
IPv4_HeaderChecksum_Step3   <=  IPv4_LOCAL_ADDR[31:16] +IPv4_LOCAL_ADDR[15: 0] + IPv4_HeaderChecksum_Step2;
IPv4_HeaderChecksum_Step4   <=  (IPv4_HeaderChecksum_Step3[15:0]+{8'h00,IPv4_HeaderChecksum_Step3[23:16]});

IPv4_HeaderChecksum         <= ~(IPv4_HeaderChecksum_Step4[15:0]+{15'h00,IPv4_HeaderChecksum_Step4[16]});

ReadDonePulse <= TX_FrameBody_Source_TRDY && Tx_MAC_FrameBody_TLAST && Tx_MAC_FrameBody_VALID;
IPv4_TotalLength<= wDataLength_Rd+8+20;
UDP_TotalLength <= wDataLength_Rd+8;
UDP_Checksum    <= wUDP_Checksum_Rd;
if (ReadDonePulse)IPv4_Identification <= IPv4_Identification +1'b1;

    if (Tx_MAC_FrameBody_StartReadPulse)
        begin
        Tx_MAC_FrameBody_ByteCounter                <=2;
        TX_SwitchREG_Decoder                        <=0;
//        TX_SwitchREG_Ethernet_II_External_MAC       <= MAC_REMOTE_ADDR [39:32] ;
        
        Tx_MAC_FrameBody_TDATA                      <= MAC_REMOTE_ADDR [47:40] ;
        Tx_MAC_FrameBody_VALID                      <=1'b1;
        Tx_MAC_FrameBody_TLAST                      <=1'b0;

        end
        else if (TX_FrameBody_Source_TRDY)
            begin
            LoadDataPulse[3:0] <=  {RdPointerIncPulse, LoadDataPulse[3:1]};
            if (LoadDataPulse[0])  {ShiftRegD3,ShiftRegD2,ShiftRegD1,ShiftRegD0} <=  wRdData;
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

//////////////////////////////////////////////////////////////////////////////////////

//            if ((Tx_MAC_FrameBody_ByteCounter ==33 )&&Tx_MAC_FrameBody_VALID) DATA_LastPosition <= wDATA_LastPosition;   
//            if (RdPointerIncPulse && (DATA_TotalLength == 0) && ReadDataState) FinishPulse[8-1:0]  <=  {DATA_LastPosition,4'b0000} ;
//                else FinishPulse[8-1:0]  <=  {1'b0,FinishPulse[8-1:1]};

//            Tx_MAC_FrameBody_TLAST <= FinishPulse[0] && Tx_MAC_FrameBody_VALID;
//            if (Tx_MAC_FrameBody_TLAST) Tx_MAC_FrameBody_VALID <=1'b0;               
                
                
                
//////////////////////////////////////////////////////////////////////////////////////                
                

            
            
            
            
            if (ReadDataState ) RdPointerDivider <= RdPointerDivider +1 ;  else RdPointerDivider <= 0;
                
            RdPointerIncPulse <= ( RdPointerDivider == 3 );
            
            if (RdPointerIncPulse) 
                begin
                    if (RdPointer==(BufferSize-1)) RdPointer <=0;  else RdPointer <= RdPointer + 1'b1;
                end

            if (Tx_MAC_FrameBody_ByteCounter!=63) Tx_MAC_FrameBody_ByteCounter   <= Tx_MAC_FrameBody_ByteCounter +1'b1;

//            if (Tx_MAC_FrameBody_ByteCounter==7'd00) TX_SwitchREG_Ethernet_II_External_MAC<= MAC_REMOTE_ADDR [47:40] ;                         // never used condition
//                else if (Tx_MAC_FrameBody_ByteCounter==7'd01) TX_SwitchREG_Ethernet_II_External_MAC<= MAC_REMOTE_ADDR [39:32] ;                // never used condition
//	               else if (Tx_MAC_FrameBody_ByteCounter==7'd02) TX_SwitchREG_Ethernet_II_External_MAC<= MAC_REMOTE_ADDR [31:24] ;
//	                   else if (Tx_MAC_FrameBody_ByteCounter==7'd03) TX_SwitchREG_Ethernet_II_External_MAC<= MAC_REMOTE_ADDR [23:16] ;
//	                       else if (Tx_MAC_FrameBody_ByteCounter==7'd04) TX_SwitchREG_Ethernet_II_External_MAC<= MAC_REMOTE_ADDR [15: 8] ;
//	                           else if (Tx_MAC_FrameBody_ByteCounter==7'd05) TX_SwitchREG_Ethernet_II_External_MAC<= MAC_REMOTE_ADDR [ 7: 0] ;
//	                               else TX_SwitchREG_Ethernet_II_External_MAC<=0;
	        
//	         if (Tx_MAC_FrameBody_ByteCounter==7'd06) TX_SwitchREG_Ethernet_II_Internal_MAC<= MAC_LOCAL_ADDR  [47:40] ;
//                else if (Tx_MAC_FrameBody_ByteCounter==7'd07) TX_SwitchREG_Ethernet_II_Internal_MAC<= MAC_LOCAL_ADDR  [39:32] ;
//	               else if (Tx_MAC_FrameBody_ByteCounter==7'd08) TX_SwitchREG_Ethernet_II_Internal_MAC<= MAC_LOCAL_ADDR  [31:24] ;
//	                   else if (Tx_MAC_FrameBody_ByteCounter==7'd09) TX_SwitchREG_Ethernet_II_Internal_MAC<= MAC_LOCAL_ADDR  [23:16] ;
//	                       else if (Tx_MAC_FrameBody_ByteCounter==7'd10) TX_SwitchREG_Ethernet_II_Internal_MAC<= MAC_LOCAL_ADDR  [15: 8] ;
//	                           else if (Tx_MAC_FrameBody_ByteCounter==7'd11) TX_SwitchREG_Ethernet_II_Internal_MAC<= MAC_LOCAL_ADDR  [ 7: 0] ;
//	                               else if (Tx_MAC_FrameBody_ByteCounter==7'd12) TX_SwitchREG_Ethernet_II_Internal_MAC<=8'h08;
//	                                   else if (Tx_MAC_FrameBody_ByteCounter==7'd13) TX_SwitchREG_Ethernet_II_Internal_MAC<=8'h00;
//	                                       else TX_SwitchREG_Ethernet_II_Internal_MAC<=0;
                      
//	         if (Tx_MAC_FrameBody_ByteCounter==7'd14) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=8'h45;                                                                        // Version and IHL
//                else if (Tx_MAC_FrameBody_ByteCounter==7'd15) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=8'h00;                                                                // DSCP	and ECN
//	               else if (Tx_MAC_FrameBody_ByteCounter==7'd16) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=IPv4_TotalLength[15:8];                                            // Total Length High
//	                   else if (Tx_MAC_FrameBody_ByteCounter==7'd17) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=IPv4_TotalLength[ 7:0];                                        // Total Length Low
//	                       else if (Tx_MAC_FrameBody_ByteCounter==7'd18) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=IPv4_Identification[15:8];                                 // Identification High
//	                           else if (Tx_MAC_FrameBody_ByteCounter==7'd19) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=IPv4_Identification[ 7:0];                             // Identification Low
//	                               else if (Tx_MAC_FrameBody_ByteCounter==7'd20) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=8'h00;                                             // Flags	and Fragment Offset High
//	                                   else if (Tx_MAC_FrameBody_ByteCounter==7'd21) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=8'h00;                                         // Flags	and Fragment Offset Low
//	                                       else if (Tx_MAC_FrameBody_ByteCounter==7'd22) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=8'h80;                                     // Time to Live
//	                                           else if (Tx_MAC_FrameBody_ByteCounter==7'd23) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=8'h11;                                 // Protocol
//	                                               else TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=0;  
	                                               
//	         if (Tx_MAC_FrameBody_ByteCounter==7'd24) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_HeaderChecksum[15:8];                                                    // Header Checksum High
//                else if (Tx_MAC_FrameBody_ByteCounter==7'd25) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_HeaderChecksum[ 7:0];                                            // Header Checksum Low
//	               else if (Tx_MAC_FrameBody_ByteCounter==7'd26) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_LOCAL_ADDR[31:24];                                          // Source address
//	                   else if (Tx_MAC_FrameBody_ByteCounter==7'd27) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_LOCAL_ADDR[23:16];                                      // Source address
//	                       else if (Tx_MAC_FrameBody_ByteCounter==7'd28) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_LOCAL_ADDR[15: 8];                                  // Source address
//	                           else if (Tx_MAC_FrameBody_ByteCounter==7'd29) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_LOCAL_ADDR[ 7: 0];                              // Source address
//	                               else if (Tx_MAC_FrameBody_ByteCounter==7'd30) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_REMOTE_ADDR[31:24];                          // Destination address
//	                                   else if (Tx_MAC_FrameBody_ByteCounter==7'd31) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_REMOTE_ADDR[23:16];                      // Destination address
//	                                       else if (Tx_MAC_FrameBody_ByteCounter==7'd32) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_REMOTE_ADDR[15: 8];                  // Destination address
//	                                           else if (Tx_MAC_FrameBody_ByteCounter==7'd33) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_REMOTE_ADDR[ 7: 0];              // Destination address
//	                                               else TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=0; 

	         if (Tx_MAC_FrameBody_ByteCounter==7'd34) TX_SwitchREG_Ethernet_II_UDP_Header<=UDP_LOCAL_PORT[15:8];                                                        // Source Port High
                else if (Tx_MAC_FrameBody_ByteCounter==7'd35) TX_SwitchREG_Ethernet_II_UDP_Header<=UDP_LOCAL_PORT[ 7:0];                                                // Source Port Low
	               else if (Tx_MAC_FrameBody_ByteCounter==7'd36) TX_SwitchREG_Ethernet_II_UDP_Header<=UDP_REMOTE_PORT[15:8];                                             // Destination Port High
	                   else if (Tx_MAC_FrameBody_ByteCounter==7'd37) TX_SwitchREG_Ethernet_II_UDP_Header<=UDP_REMOTE_PORT[ 7:0];                                         // Destination Port Low
	                       else if (Tx_MAC_FrameBody_ByteCounter==7'd38) TX_SwitchREG_Ethernet_II_UDP_Header<=UDP_TotalLength[15: 8];                                      // Length High
	                           else if (Tx_MAC_FrameBody_ByteCounter==7'd39) TX_SwitchREG_Ethernet_II_UDP_Header<=UDP_TotalLength[ 7: 0];                                  // Length Low
	                               else if (Tx_MAC_FrameBody_ByteCounter==7'd40) TX_SwitchREG_Ethernet_II_UDP_Header<=UDP_Checksum[15:8];                                  // Checksum High
	                                   else if (Tx_MAC_FrameBody_ByteCounter==7'd41) TX_SwitchREG_Ethernet_II_UDP_Header<=UDP_Checksum[ 7:0];                              // Checksum Low
	                                               else TX_SwitchREG_Ethernet_II_UDP_Header<=0; 
                     
            if ((Tx_MAC_FrameBody_ByteCounter>=7'd00)&& (Tx_MAC_FrameBody_ByteCounter<=7'd05)) TX_SwitchREG_Decoder <= 0;
                else if ((Tx_MAC_FrameBody_ByteCounter>=7'd06)&& (Tx_MAC_FrameBody_ByteCounter<=7'd13)) TX_SwitchREG_Decoder <= 1;
                    else if ((Tx_MAC_FrameBody_ByteCounter>=7'd14)&& (Tx_MAC_FrameBody_ByteCounter<=7'd23)) TX_SwitchREG_Decoder <= 2;
                        else if ((Tx_MAC_FrameBody_ByteCounter>=7'd24)&& (Tx_MAC_FrameBody_ByteCounter<=7'd33)) TX_SwitchREG_Decoder <= 3;
                            else if ((Tx_MAC_FrameBody_ByteCounter>=7'd34)&& (Tx_MAC_FrameBody_ByteCounter<=7'd41)) TX_SwitchREG_Decoder <= 4;
                                else TX_SwitchREG_Decoder <= 5;
                                
//            if (TX_SwitchREG_Decoder==0) Tx_MAC_FrameBody_TDATA <= TX_SwitchREG_Ethernet_II_External_MAC;
//                else if (TX_SwitchREG_Decoder==1)  Tx_MAC_FrameBody_TDATA <= TX_SwitchREG_Ethernet_II_Internal_MAC;
                
            if (TX_SwitchREG_Decoder==0) Tx_MAC_FrameBody_TDATA <= wTX_SwitchREG_Ethernet_II_MAC;
                else if (TX_SwitchREG_Decoder==1)  Tx_MAC_FrameBody_TDATA <= wTX_SwitchREG_Ethernet_II_MAC;
                
//                    else if (TX_SwitchREG_Decoder==2)  Tx_MAC_FrameBody_TDATA <= TX_SwitchREG_Ethernet_II_IP4_HeaderHi;
//                        else if (TX_SwitchREG_Decoder==3)  Tx_MAC_FrameBody_TDATA <= TX_SwitchREG_Ethernet_II_IP4_HeaderLo;                
                
                    else if (TX_SwitchREG_Decoder==2)  Tx_MAC_FrameBody_TDATA <= wTX_SwitchREG_Ethernet_II_IP4;
                        else if (TX_SwitchREG_Decoder==3)  Tx_MAC_FrameBody_TDATA <= wTX_SwitchREG_Ethernet_II_IP4;
                        
                            else if (TX_SwitchREG_Decoder==4)  Tx_MAC_FrameBody_TDATA <= TX_SwitchREG_Ethernet_II_UDP_Header;
                                else if (TX_SwitchREG_Decoder==5)  Tx_MAC_FrameBody_TDATA <= ShiftRegD0;//0;
	               end                
end	                    

(* KEEP_HIERARCHY = "TRUE" *)
Ethernet_II_MAC_Header_Generator  
#(
.EtherTypeValue(16'h0800)
)Ethernet_II_MAC_Header_Generator_inst
(
.CLK                                (TX_CLK),
.MAC_TRY                            (TX_FrameBody_Source_TRDY),
.MAC_Header_PreSet                  (Tx_MAC_FrameBody_StartReadPulse),
.MAC_Header_Position                (Tx_MAC_FrameBody_ByteCounter),
.MAC_LOCAL_ADDR                     (MAC_LOCAL_ADDR),
.MAC_REMOTE_ADDR                    (IPv4_REMOTE_ADDR),

.MAC_Header                         (wTX_SwitchREG_Ethernet_II_MAC)
);

(* KEEP_HIERARCHY = "TRUE" *)
IPv4_Header_Generator    
#(.IPv4_Protocol_Number(8'd17)) 
IPv4_Header_Generator_inst
(
.CLK                                (TX_CLK),
.IPv4_TRY                           (TX_FrameBody_Source_TRDY),
.IPv4_TotalLength                   (IPv4_TotalLength),
.IPv4_Header_Position               (Tx_MAC_FrameBody_ByteCounter),
.IPv4_LOCAL_ADDR                    (IPv4_LOCAL_ADDR),
.IPv4_REMOTE_ADDR                   (IPv4_REMOTE_ADDR),

.IPv4_Header                        (wTX_SwitchREG_Ethernet_II_IP4)
);

assign TX_FrameBody_Source_TVALID    =   Tx_MAC_FrameBody_VALID;
assign TX_FrameBody_Source_TLAST     =   Tx_MAC_FrameBody_TLAST;
assign TX_FrameBody_Source_TDATA     =   Tx_MAC_FrameBody_TDATA;
    

endmodule

