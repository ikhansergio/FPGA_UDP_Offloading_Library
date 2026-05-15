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
    parameter UDP_CHECKSUM_CALK = "YES" ,  // "YES" or "NO"
    parameter BUFFER_COUNT_1K = 3       ,
    parameter ETHERNET_MTU = 1*1024      
) 
(     
    input  wire                     Sink_CLK,
    output wire                     Sink_TRDY  ,
    input  wire                     Sink_TVALID,
    input  wire                     Sink_TLAST,
    input  wire [ 4-1:0]            Sink_TKEEP,
    input  wire [32-1:0]            Sink_TDATA,
    
    output reg  [32-1:0]            DATA_DROP_Cnt =             0,
 
 	input  wire [16-1:0]   			UDP_LOCAL_PORT_IN         	,
	input  wire [16-1:0]   			UDP_REMOTE_PORT_IN         	,

	input  wire [32-1:0]   			IP4_LOCAL_ADDR_IN         	,
	input  wire [32-1:0]   			IP4_REMOTE_ADDR_IN         	,

	input  wire [48-1:0]   			MAC_LOCAL_ADDR_IN          	,  
    input  wire [48-1:0]   			MAC_REMOTE_ADDR_IN         	,

    input   wire                   	Source_CLK,
    input   wire [1-1:0]	       	Source_TRDY,
    output  wire [1-1:0]	       	Source_TVALID,
    output  wire [1-1:0]	       	Source_TLAST,
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

localparam BufferSize = (BUFFER_COUNT_1K==0) ? 128 : BUFFER_COUNT_1K * (1024/4); // BUFFER_COUNT_1K * 256 

if ( ETHERNET_MTU <= 28                         )             begin AXISx32_UDP_Tx_Offload_Engine_Error MTU_Erorr ( );           end
if ((BufferSize*4) < MAX_UDP_PayloadSize        )             begin AXISx32_UDP_Tx_Offload_Engine_Error BufferSize_Erorr ( );    end
if ((BUFFER_COUNT_1K>16)                        )             begin AXISx32_UDP_Tx_Offload_Engine_Error BufferCount_Erorr ( );   end
        
//////////////////////////////////////////////////////////////////////////////////////
// find the beginning of a package 
reg  TLAST_DONE_FLAG=1;
wire DATA_TFIRST;
always @(posedge Sink_CLK) begin if (Sink_TVALID&&Sink_TLAST) TLAST_DONE_FLAG<=1; else if (Sink_TVALID) TLAST_DONE_FLAG<=0; end
assign DATA_TFIRST =  TLAST_DONE_FLAG && Sink_TVALID ;
//////////////////////////////////////////////////////////////////////////////////////

wire [ 4-1:0]           wSink_TKEEP;
wire [ 4-1:0]           wDATA_COUNT;
wire [32-1:0]           wSink_TDATA;

(* KEEP_HIERARCHY = "TRUE" *)
AXISx32_InputChecker    AXISx32_InputChecker_inst
(
.TLAST_IN    (Sink_TLAST),
.TKEEP_IN    (Sink_TKEEP),
.TDATA_IN    (Sink_TDATA),

.TKEEP_OUT   (wSink_TKEEP),
.COUNT_OUT   (wDATA_COUNT),
.TDATA_OUT   (wSink_TDATA)
);

wire wCommandFIFO_Full;
 
reg          TVALID_Reg0=0;
reg          TVALID_Reg1=0;

reg          TFIRST_Reg0=0;
reg          TFIRST_Reg1=0;

reg          TLAST_Reg0=0;
reg          TLAST_Reg1=0;
                                                            
reg [ 4-1:0] TKEEP_Reg0=0;  
reg [ 4-1:0] TKEEP_Reg1=0;       

reg [32-1:0] TDATA_Reg0=0;  
reg [32-1:0] TDATA_Reg1=0;       
    
reg [16-1:0] RxDataLengthCounter=0;
reg [16-1:0] RxDataLengthCounter_D1=0;
reg [16-1:0] RxDataLengthCounter_D2=0;

//(* keep = "true" *) wire [32-1:0] wUDP_CheckSUM_Data;

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


assign wPacketDropFlag = (RxDataLengthCounter>MAX_UDP_PayloadSize) || (  (DROP_IF_OVERFLOW == "YES" ) && (( WrBufferElements > (BufferSize- 8))||wCommandFIFO_Full)); 

wire 	wWrDataRDY;
if (DROP_IF_OVERFLOW == "YES" ) assign 	wWrDataRDY = 1; else  assign 	wWrDataRDY = WrOverflow_n;
assign 	Sink_TRDY = wWrDataRDY;

(* KEEP_HIERARCHY = "TRUE" *)
Gray2BinRegisteredInOut #( .WIDTH(BitWidth(BufferSize)) ) Gray2BinRegisteredInOut_inst
(
.Clk                (Sink_CLK),
.GrayIn             (wRdPointerGray),
.BinOut             (wRdPointer)
 ); 
 
 (* keep = "true" *) wire[16-1:0]wCheckSUM_UDP;
 if (UDP_CHECKSUM_CALK=="YES")
 begin
 (* KEEP_HIERARCHY = "TRUE" *)
 UDP_CheckSumCalc            UDP_CheckSumCalc_inst
(
.CLK                         ( Sink_CLK             ),
.TFIRST                      ( DATA_TFIRST          ),
.TVALID                      ( Sink_TVALID          ),
.TDATA                       (wSink_TDATA           ),
.IP4_DataLength_IN           ( RxDataLengthCounter  ),
.UDP_LOCAL_PORT_IN           ( UDP_LOCAL_PORT_IN    ),
.UDP_REMOTE_PORT_IN          ( UDP_REMOTE_PORT_IN   ),
.IP4_LOCAL_ADDR_IN           ( IP4_LOCAL_ADDR_IN    ),
.IP4_REMOTE_ADDR_IN          ( IP4_REMOTE_ADDR_IN   ),
.CheckSUM_UDP                (wCheckSUM_UDP         )
);
end else
begin
assign wCheckSUM_UDP = 16'h0;
end
 
always @(posedge Sink_CLK) WrOverflow_n  <= !(( WrBufferElements > (BufferSize- 8))||wCommandFIFO_Full);  

always @(posedge Sink_CLK)
begin
if (WrPointer>=wRdPointer) WrBufferElements <= WrPointer - wRdPointer;
    else WrBufferElements <= WrPointer - wRdPointer + BufferSize;

if (wWrDataRDY)
    begin

    if (TVALID_Reg0 && wPacketDropFlag) RxPacketValid<=1'b0;
	   else if (TFIRST_Reg0 ) RxPacketValid<=1'b1;	   

    TVALID_Reg0 <= Sink_TVALID;
    TVALID_Reg1 <= TVALID_Reg0;
    
    TFIRST_Reg0 <= DATA_TFIRST;
    TFIRST_Reg1 <= TFIRST_Reg0;

    TLAST_Reg0  <= Sink_TLAST ;
    TLAST_Reg1  <= TLAST_Reg0 ;
    
    TKEEP_Reg0  <= wSink_TKEEP ;
    TKEEP_Reg1  <= TKEEP_Reg0 ;
    
    TDATA_Reg0  <= wSink_TDATA;
    TDATA_Reg1  <= TDATA_Reg0 ;

	/////////////////////////////////////////////////////////////////////////////////////////////

	if (Sink_TVALID&&DATA_TFIRST) RxDataLengthCounter <= wDATA_COUNT;  
		else if (Sink_TVALID&&(RxDataLengthCounter>MAX_UDP_PayloadSize)) RxDataLengthCounter <= RxDataLengthCounter;  
			else if (Sink_TVALID) RxDataLengthCounter <= RxDataLengthCounter + wDATA_COUNT;  


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
.WrClk      (Sink_CLK),
.WrRst      (1'b0),
.WrEna      (WrCommandToFIFO),
.WrDat      ({4'b0000,wCheckSUM_UDP,RxDataLengthCounter_D2}),

.RdClk      (Source_CLK),
.RdEna      (ReadDonePulse),
.RdEpt      (wCommandFOFO_Empty),
.RdPgF      (wCommandFIFO_Full),
.RdDat      ({ wUDP_Checksum_Rd, wDataLength_Rd })
);



(* KEEP_HIERARCHY = "TRUE" *)
UDP_RAM_DataBuffer_x36 
#(
.ARCH ("XLX_ULTRASCALE" ),
.BUFFER_COUNT_1K(BUFFER_COUNT_1K)
) UDP_RAM_DataBuffer_x36_inst
(
. WrClk       (Sink_CLK     ),
. WrEna       (wWrDataRDY   ),
. WrWea       (WrWea        ),
. WrAddress   (WrPointer    ),
. WrData      (WrData       ),

. RdClk       (Source_CLK),
. RdEna       (1'b1),
. RdAddress   (RdPointer),
. RdData      (wRdData)
);

(* KEEP_HIERARCHY = "TRUE" *)
Bin2GrayRegisteredOut #( .WIDTH(BitWidth(BufferSize)) ) Bin2GrayRegisteredOut_inst
(
.Clk                 (Source_CLK),
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

reg             Tx_MAC_FrameBody_StartReadPulse           =   0;

reg             Tx_MAC_FrameBody_VALID                    =   0;
reg             Tx_MAC_FrameBody_TLAST                    =   0;
//reg [8-1:0]     Tx_MAC_FrameBody_TDATA                    =   0;
wire[8-1:0]    wTx_MAC_FrameBody_TDATA;

reg [6-1:0]     Tx_MAC_FrameBody_ByteCounter              =   63;

reg [3-1:0]     TX_SwitchREG_Decoder                      =   0;

wire[8-1:0]    wTX_SwitchREG_Ethernet_II_MAC;
wire[8-1:0]    wTX_SwitchREG_Ethernet_II_IP4;
wire[8-1:0]    wTX_SwitchREG_Ethernet_II_UDP;


reg [2-1:0]     RdPointerDivider  = 0;
reg             RdPointerIncPulse = 0;

reg [4-1:0]     LoadDataPulse = 0;

reg             ReadDataState = 0;
reg             ReadDataState_Full = 0;

reg [8-1:0]     ShiftRegD0 = 0;
reg [8-1:0]     ShiftRegD1 = 0;
reg [8-1:0]     ShiftRegD2 = 0;
reg [8-1:0]     ShiftRegD3 = 0;

reg [8-1:0]     FinishPulse = 0;

reg [2-1:0]  READ_STATE=0;
always @(posedge Source_CLK)
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

always @(posedge Source_CLK)
begin
ReadDonePulse <= Source_TRDY && Tx_MAC_FrameBody_TLAST && Tx_MAC_FrameBody_VALID;
IPv4_TotalLength<= wDataLength_Rd+8+20;
UDP_TotalLength <= wDataLength_Rd+8;
UDP_Checksum    <= wUDP_Checksum_Rd;
//if (ReadDonePulse)IPv4_Identification <= IPv4_Identification +1'b1;

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

            if (ReadDataState ) RdPointerDivider <= RdPointerDivider +1 ;  else RdPointerDivider <= 0;
                
            RdPointerIncPulse <= ( RdPointerDivider == 3 );
            
            if (RdPointerIncPulse) 
                begin
                    if (RdPointer==(BufferSize-1)) RdPointer <=0;  else RdPointer <= RdPointer + 1'b1;
                end

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
.CLK                                (Source_CLK),

.UDP_LOCAL_PORT_IN                  (UDP_LOCAL_PORT_IN),
.UDP_REMOTE_PORT_IN                 (UDP_REMOTE_PORT_IN),
.UDP_TotalLength                    (UDP_TotalLength),
.UDP_Checksum                       (UDP_Checksum),
.UDP_Position                       (Tx_MAC_FrameBody_ByteCounter),

.UDP_Header                         (wTX_SwitchREG_Ethernet_II_UDP) 
);

(* KEEP_HIERARCHY = "TRUE" *)
ICMP_UDP_Frame_Header_Multiplexer   UDP_Frame_Header_Multiplexer_inst
(
.CLK                                (Source_CLK                                     ),

.Frame_TRY                          (Source_TRDY                                    ),
.Frame_PreSet                       (Tx_MAC_FrameBody_StartReadPulse                ),
.Frame_PreSetValue                  (MAC_REMOTE_ADDR_IN [47:40]                     ),
.Frame_Position                     (Tx_MAC_FrameBody_ByteCounter                   ),

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

