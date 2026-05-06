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

module UDP_RxDatagramProcessing_Core_x8
(
	input	wire					CLK						,
	input	wire					UDP_Core_Sink_TVALID	,
	input	wire					UDP_Core_Sink_TERROR	,
	input	wire					UDP_Core_Sink_TLAST	    ,
	input	wire [ 8-1:0]		    UDP_Core_Sink_TDATA	    ,
	
	input  wire [16-1:0]   			UDP_LOCAL_PORT_IN      ,


    input  wire	[ 8-1:0] 		    IP4_Used_Protocol_IN    ,
	input  wire [32-1:0]   			IP4_LOCAL_ADDR_IN       ,
	input  wire [32-1:0]   			IP4_REMOTE_ADDR_IN      ,
	input  wire [48-1:0]   			MAC_REMOTE_ADDR_IN      ,
	
	output reg  [16-1:0]   			UDP_REMOTE_PORT_OUT=0   ,
	output reg  [32-1:0]   			IP4_REMOTE_ADDR_OUT=0   ,
	output reg  [48-1:0]   			MAC_REMOTE_ADDR_OUT=0   ,
	
	
    	
	
	output	reg 					UDP_Core_ERROR_Pulse=0  ,
	
	output	reg  					UDP_Core_Source_TFIRST=0,
	output	reg 					UDP_Core_Source_TVALID=0,
	output	reg 					UDP_Core_Source_TERROR=0,
	output	reg					    UDP_Core_Source_TLAST =0,
	output  reg  	[ 8-1:0]		UDP_Core_Source_TDATA =0
);

localparam UDP_ProtocolCode        = 8'd17;


(* KEEP_HIERARCHY = "TRUE" *)
PacketTypeValidation                
#(
.PackTypePattern(UDP_ProtocolCode)                        
)UDP_ProtocolCode_Validation_inst
(
.CLK                   (CLK),
.Sink_TVALID           (UDP_Core_Sink_TVALID),
.Sink_TERROR           (UDP_Core_Sink_TERROR),
.Sink_TLAST            (UDP_Core_Sink_TLAST),
.Sink_TDATA            (UDP_Core_Sink_TDATA),
	
.PackTypeCode          ({8'h00,IP4_Used_Protocol_IN}),

.Source_TVALID         (),
.Source_TFIRST         (),
.Source_TLAST          (),
.Source_TERROR         (),
.Source_TDATA          ()
);


//////////////////////////////////////////////////////////////////////////////////////
// find the beginning of a package 
reg  TLAST_DONE_FLAG=1;
wire UDP_Core_Sink_TFIRST;
always @(posedge CLK) begin if (UDP_Core_Sink_TVALID&&UDP_Core_Sink_TLAST) TLAST_DONE_FLAG<=1; else if (UDP_Core_Sink_TVALID) TLAST_DONE_FLAG<=0; end
//assign UDP_Core_Sink_TFIRST =  TLAST_DONE_FLAG && UDP_Core_Sink_TVALID ;
assign UDP_Core_Sink_TFIRST =  TLAST_DONE_FLAG && UDP_Core_Sink_TVALID && (IP4_Used_Protocol_IN     == UDP_ProtocolCode);
//////////////////////////////////////////////////////////////////////////////////////


reg             UDP_ProtocolFlag =0;

reg             UDP_Core_Sink_REG_TFIRST           =0;
reg             UDP_Core_Sink_REG_TVALID           =0;
reg             UDP_Core_Sink_REG_TERROR           =0;
reg             UDP_Core_Sink_REG_TLAST            =0;
reg [ 8-1:0]    UDP_Core_Sink_REG_TDATA            =0;  

reg             UDP_Core_TFIRST         =0;
reg             UDP_Core_TVALID         =0;
reg             UDP_Core_TERROR         =0;
reg             UDP_Core_TLAST          =0;
reg [ 8-1:0]    UDP_Core_TDATA          =0;  

reg             UDP_Core_TFIRST_D0      =0;
reg             UDP_Core_TVALID_D0      =0;
reg             UDP_Core_TERROR_D0      =0;
reg             UDP_Core_TLAST_D0       =0;
reg [ 8-1:0]    UDP_Core_TDATA_D0       =0; 

reg             UDP_Core_TFIRST_D1      =0;
reg             UDP_Core_TVALID_D1      =0;
reg             UDP_Core_TERROR_D1      =0;
reg             UDP_Core_TLAST_D1       =0;
reg [ 8-1:0]    UDP_Core_TDATA_D1       =0;

reg             UDP_Core_TFIRST_D2      =0;
reg             UDP_Core_TVALID_D2      =0;
reg             UDP_Core_TERROR_D2      =0;
reg             UDP_Core_TLAST_D2       =0;
reg [ 8-1:0]    UDP_Core_TDATA_D2       =0;  

reg             UDP_Core_HalfwordFlag               =1'b0; // The flag is used to calculate halfword boundaries in the checksum calculation.
reg [ 4-1:0]    UDP_Core_HeaderPosition             =1'b0; 
reg [16-1:0]    UDP_Core_Total_ByteCounter          =1'b0; 
reg [16-1:0]    UDP_Total_Length                    =1'b0;
reg [ 8-1:0]    UDP_Core_TDATA_SHIFT                =0;

reg             UDP_Port_ValidFlag                  =1'b0;
reg             UDP_ByteCountValidationDoneFlag     =1'b0; // The received packet contains the same bytes as specified in the UDP header. 
reg             UDP_HeaderValidationDoneFlag        =1'b0;
reg             UDP_SizeValidFlag                   =1'b0;  
reg             UDP_Need2CheckFlag                  =1'b0; // Checksum verification flag. If the Checksum field is zero, the checksum is not verified.
reg             UDP_Need2CheckFlag_D0               =1'b0;
reg             UDP_Need2CheckFlag_D1               =1'b0;
reg             UDP_Need2CheckFlag_D2               =1'b0;

reg             UDP_HeaderValidationDonePulse       =1'b0;


reg [32-1:0]    UDP_PseudoHeader_CheckSum           =1'b0;
reg [32-1:0]    UDP_CheckSumCounter                 =1'b0;

reg [32-1:0]    UDP_CheckSum                        =1'b0;
reg [16-1:0]    UDP_CheckSumDone                    =1'b0;

reg [16-1:0]    UDP_REMOTE_PORT                     =1'b0;

always @(posedge CLK)
begin
if (TLAST_DONE_FLAG&&UDP_Core_Sink_TVALID) UDP_ProtocolFlag    <=  (IP4_Used_Protocol_IN     == UDP_ProtocolCode);

UDP_Core_Sink_REG_TFIRST     <=     UDP_Core_Sink_TFIRST;
UDP_Core_Sink_REG_TVALID     <=     UDP_Core_Sink_TVALID;
UDP_Core_Sink_REG_TERROR     <=     UDP_Core_Sink_TERROR;
UDP_Core_Sink_REG_TLAST      <=     UDP_Core_Sink_TLAST;
UDP_Core_Sink_REG_TDATA      <=     UDP_Core_Sink_TDATA;

if (UDP_ProtocolFlag)  UDP_Core_TFIRST <= UDP_Core_Sink_REG_TFIRST;   else UDP_Core_TFIRST  <=  0;
if (UDP_ProtocolFlag)  UDP_Core_TVALID <= UDP_Core_Sink_REG_TVALID;   else UDP_Core_TVALID  <=  0;
if (UDP_ProtocolFlag)  UDP_Core_TLAST  <= UDP_Core_Sink_REG_TLAST;    else UDP_Core_TLAST   <=  0; 
if (UDP_ProtocolFlag)  UDP_Core_TERROR <= UDP_Core_Sink_REG_TERROR;   else UDP_Core_TERROR  <=  0;  
if (UDP_ProtocolFlag)  UDP_Core_TDATA  <= UDP_Core_Sink_REG_TDATA;    else UDP_Core_TDATA   <=  0; 


if (UDP_Core_Sink_REG_TFIRST&&UDP_Core_Sink_REG_TVALID) UDP_Core_HeaderPosition<=0;
	else if (UDP_Core_Sink_REG_TVALID&&(UDP_Core_HeaderPosition<(4'hF))) UDP_Core_HeaderPosition<= UDP_Core_HeaderPosition+1'b1;
	
if (UDP_Core_Sink_REG_TFIRST&&UDP_Core_Sink_REG_TVALID) UDP_Core_Total_ByteCounter<=1'b1;
    else if (UDP_Core_Sink_REG_TVALID) UDP_Core_Total_ByteCounter<=UDP_Core_Total_ByteCounter+1'b1;
    
    
if (UDP_Core_Sink_REG_TFIRST&&UDP_Core_Sink_REG_TVALID) UDP_Core_HalfwordFlag<=1'b0;
	else if (UDP_Core_Sink_REG_TVALID) UDP_Core_HalfwordFlag<=!UDP_Core_HalfwordFlag;


UDP_ByteCountValidationDoneFlag <= (UDP_Core_Total_ByteCounter>8)&&(UDP_Core_Total_ByteCounter==UDP_Total_Length);


if (UDP_Core_TVALID)
    begin
    UDP_Core_TDATA_SHIFT <= UDP_Core_TDATA;
    
    if ((UDP_Core_HeaderPosition== 1))  UDP_REMOTE_PORT                  <=  {UDP_Core_TDATA_SHIFT,UDP_Core_TDATA};
    
    if ((UDP_Core_HeaderPosition== 3))  UDP_Port_ValidFlag                 <= UDP_LOCAL_PORT_IN == {UDP_Core_TDATA_SHIFT,UDP_Core_TDATA};
    
    if ((UDP_Core_HeaderPosition== 5))  UDP_Total_Length                   <=  {UDP_Core_TDATA_SHIFT,UDP_Core_TDATA};

    UDP_SizeValidFlag<= UDP_Total_Length > 8;
    
    if (UDP_Core_TFIRST) UDP_CheckSumCounter<=1'b0;
        else if ( UDP_Core_TLAST && UDP_Core_HalfwordFlag)  UDP_CheckSumCounter<=UDP_CheckSumCounter+{16'h0000,UDP_Core_TDATA_SHIFT,UDP_Core_TDATA};
	       else if ( UDP_Core_TLAST &&~UDP_Core_HalfwordFlag) UDP_CheckSumCounter<=UDP_CheckSumCounter+{16'h0000,UDP_Core_TDATA_SHIFT,8'h00};
	           else if (~UDP_Core_TLAST && UDP_Core_HalfwordFlag) UDP_CheckSumCounter<=UDP_CheckSumCounter+{16'h0000,UDP_Core_TDATA_SHIFT,UDP_Core_TDATA};
	           
    if ((UDP_Core_HeaderPosition== 0)) UDP_PseudoHeader_CheckSum    <= {32'h00000000};
        else if ((UDP_Core_HeaderPosition== 1)) UDP_PseudoHeader_CheckSum    <= {16'h0000,IP4_LOCAL_ADDR_IN[16-1: 0]}     + UDP_PseudoHeader_CheckSum;
            else if ((UDP_Core_HeaderPosition== 2)) UDP_PseudoHeader_CheckSum    <= {16'h0000,IP4_LOCAL_ADDR_IN[32-1:16]}     + UDP_PseudoHeader_CheckSum;
                else if ((UDP_Core_HeaderPosition== 3)) UDP_PseudoHeader_CheckSum    <= {16'h0000,IP4_REMOTE_ADDR_IN[16-1: 0]}     + UDP_PseudoHeader_CheckSum;
                    else if ((UDP_Core_HeaderPosition== 4)) UDP_PseudoHeader_CheckSum    <= {16'h0000,IP4_REMOTE_ADDR_IN[32-1:16]}     + UDP_PseudoHeader_CheckSum;
                        else if ((UDP_Core_HeaderPosition== 5)) UDP_PseudoHeader_CheckSum    <= {16'h0000,8'h00,IP4_Used_Protocol_IN}         + UDP_PseudoHeader_CheckSum;
                            else if ((UDP_Core_HeaderPosition== 6)) UDP_PseudoHeader_CheckSum    <= {16'h0000,UDP_Total_Length [16-1: 0]}        + UDP_PseudoHeader_CheckSum;
   
    
    UDP_HeaderValidationDonePulse <= UDP_Port_ValidFlag && UDP_SizeValidFlag && (UDP_Core_HeaderPosition== 7);

            
    if ((UDP_Core_HeaderPosition== 7)) UDP_HeaderValidationDoneFlag <= UDP_Port_ValidFlag && UDP_SizeValidFlag;
        else if (UDP_Core_TLAST) UDP_HeaderValidationDoneFlag <= 1'b0;
    
    if ((UDP_Core_HeaderPosition== 7)) UDP_Need2CheckFlag <= ({UDP_Core_TDATA_SHIFT,UDP_Core_TDATA} != 16'h0000);    
        else if (UDP_Core_TLAST) UDP_Need2CheckFlag <= 1'b0;  

    end

UDP_CheckSum <= UDP_PseudoHeader_CheckSum + UDP_CheckSumCounter;
UDP_CheckSumDone <= UDP_CheckSum[32-1:16] + UDP_CheckSum[16-1: 0];   

UDP_Core_TVALID_D0      <=  UDP_Core_TVALID&&UDP_HeaderValidationDoneFlag;
UDP_Core_TLAST_D0       <=  UDP_Core_TLAST;

if (UDP_Core_TVALID) UDP_Core_TFIRST_D0 <= UDP_HeaderValidationDonePulse;

if (UDP_HeaderValidationDoneFlag&&UDP_Core_TVALID)   UDP_Need2CheckFlag_D0   <=  UDP_Need2CheckFlag;
    else   if (UDP_Core_TVALID_D0&&UDP_Core_TLAST_D0)   UDP_Need2CheckFlag_D0      <=  0;
    
if (UDP_HeaderValidationDoneFlag&&UDP_Core_TVALID)   UDP_Core_TERROR_D0      <=  UDP_Core_TERROR; 
    else   if (UDP_Core_TVALID_D0&&UDP_Core_TLAST_D0)   UDP_Core_TERROR_D0      <=  0;
    
if (UDP_HeaderValidationDoneFlag&&UDP_Core_TVALID)   UDP_Core_TDATA_D0       <=  UDP_Core_TDATA;  
    else   if (UDP_Core_TVALID_D0&&UDP_Core_TLAST_D0)  UDP_Core_TDATA_D0       <=  8'h00;


UDP_Need2CheckFlag_D1   <=  UDP_Need2CheckFlag_D0;
UDP_Core_TFIRST_D1      <=  UDP_Core_TFIRST_D0;
UDP_Core_TVALID_D1      <=  UDP_Core_TVALID_D0;
UDP_Core_TERROR_D1      <=  UDP_Core_TERROR_D0;
UDP_Core_TLAST_D1       <=  UDP_Core_TLAST_D0;
UDP_Core_TDATA_D1       <=  UDP_Core_TDATA_D0;

UDP_Need2CheckFlag_D2   <=  UDP_Need2CheckFlag_D1;
UDP_Core_TFIRST_D2      <=  UDP_Core_TFIRST_D1;
UDP_Core_TVALID_D2      <=  UDP_Core_TVALID_D1;
UDP_Core_TERROR_D2      <=  UDP_Core_TERROR_D1;
UDP_Core_TLAST_D2       <=  UDP_Core_TLAST_D1;
UDP_Core_TDATA_D2       <=  UDP_Core_TDATA_D1;

if (UDP_Core_TFIRST_D2&&UDP_Core_TVALID_D2)  UDP_REMOTE_PORT_OUT    <= UDP_REMOTE_PORT;
if (UDP_Core_TFIRST_D2&&UDP_Core_TVALID_D2)  IP4_REMOTE_ADDR_OUT    <= IP4_REMOTE_ADDR_IN;
if (UDP_Core_TFIRST_D2&&UDP_Core_TVALID_D2)  MAC_REMOTE_ADDR_OUT    <= MAC_REMOTE_ADDR_IN;

UDP_Core_Source_TFIRST  <= UDP_Core_TFIRST_D2;
UDP_Core_Source_TVALID  <= UDP_Core_TVALID_D2;
UDP_Core_Source_TERROR  <= UDP_Core_TERROR_D2||((UDP_CheckSumDone!=16'hFFFF)&&UDP_Need2CheckFlag_D2);
UDP_Core_Source_TLAST   <= UDP_Core_TLAST_D2;
UDP_Core_Source_TDATA   <= UDP_Core_TDATA_D2;

UDP_Core_ERROR_Pulse    <= UDP_Core_TLAST_D2 && ((UDP_CheckSumDone!=16'hFFFF)&&UDP_Need2CheckFlag_D2);
end
    
endmodule
