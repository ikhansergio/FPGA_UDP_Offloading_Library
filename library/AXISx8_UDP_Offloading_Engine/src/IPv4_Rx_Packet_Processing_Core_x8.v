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

module IPv4_Core_x8
(
	input	wire					CLK						,
	input	wire					IPv4_Core_Sink_TVALID	,
	input	wire					IPv4_Core_Sink_TERROR	,
	input	wire					IPv4_Core_Sink_TLAST	,
	input	wire	[ 8-1:0]		IPv4_Core_Sink_TDATA	,
	
	

	input	wire	[32-1:0]		Internal_IP4_ADDR,
	output  reg 	[32-1:0] 		External_IP4_ADDR  = 0,
	output  reg 	[ 8-1:0] 		IP4_Used_Protocol  = 0,	
	
	input	wire	[16-1:0]        Ethernet_TypeCode,	
	input	wire	[48-1:0]		External_MAC_ADDR_IN,
	output  reg 	[48-1:0] 		External_MAC_ADDR_OUT  = 0,

	output	reg  					IPv4_Core_Source_TFIRST=0,
	output	reg 					IPv4_Core_Source_TVALID=0,
	output	reg 					IPv4_Core_Source_TERROR=0,
	output	reg					    IPv4_Core_Source_TLAST=0,
	output  reg  	[ 8-1:0]		IPv4_Core_Source_TDATA
	
	//output  reg 	[48-1:0] 		IPv4_Core_Source_Ethernet_II_External_MAC = 0
);

localparam EtherType        = 16'h0800;
localparam IPv4HeaderSize   = 4'd5;
//////////////////////////////////////////////////////////////////////////////////////
// find the beginning of a package 
reg  TLAST_DONE_FLAG=1;
wire IPv4_Core_Sink_TFIRST;
always @(posedge CLK) begin if (IPv4_Core_Sink_TVALID&&IPv4_Core_Sink_TLAST) TLAST_DONE_FLAG<=1; else if (IPv4_Core_Sink_TVALID) TLAST_DONE_FLAG<=0; end
assign IPv4_Core_Sink_TFIRST =  TLAST_DONE_FLAG && IPv4_Core_Sink_TVALID && (Ethernet_TypeCode == EtherType);
//////////////////////////////////////////////////////////////////////////////////////

reg         RX_REG_IP4_PackTypeFlag =0;

reg         RX_REG_TFIRST           =0;
reg         RX_REG_TVALID           =0;
reg         RX_REG_TERROR           =0;
reg         RX_REG_TLAST            =0;
reg [8-1:0] RX_REG_TDATA            =0;

reg         IP4_Core_TFIRST         =0;
reg         IP4_Core_TVALID         =0;
reg         IP4_Core_TERROR         =0;
reg         IP4_Core_TLAST          =0;
reg [8-1:0] IP4_Core_TDATA          =0;

reg         IP4_Core_TVALID_D0      =0;
reg         IP4_Core_TVALID_D1      =0;
reg         IP4_Core_TVALID_D2      =0;

reg         IP4_Core_TLAST_D0      =0;
reg         IP4_Core_TLAST_D1      =0;
reg         IP4_Core_TLAST_D2      =0;

reg         IP4_Core_TERROR_D0      =0;
reg         IP4_Core_TERROR_D1      =0;
reg         IP4_Core_TERROR_D2      =0;

reg [8-1:0] IP4_Core_TDATA_SHIFT    =0;

reg [8-1:0] IP4_Core_IP_SHIFT0   =0;
reg [8-1:0] IP4_Core_IP_SHIFT1   =0;
reg [8-1:0] IP4_Core_IP_SHIFT2   =0;
reg [8-1:0] IP4_Core_IP_SHIFT3   =0;

reg [8-1:0] IP4_Core_TDATA_D0       =0;
reg [8-1:0] IP4_Core_TDATA_D1       =0;
reg [8-1:0] IP4_Core_TDATA_D2       =0;


reg [16-1:0]    IPv4_Core_Total_ByteCounter         =1'b0;      //
reg [16-1:0]    IPv4_Total_Length                   =1'b0;

reg             IPv4_ByteCountValidationDoneFlag    =0;         // The received packet contains the same or more bytes as specified in the IPv4 header. 
reg             IPv4_PaddingValidationFlag          =0;

reg             IP4_Core_HalfwordFlag               =1'b0;      // The flag is used to calculate halfword boundaries in the checksum calculation.
reg [ 5-1:0]    IP4_Core_HeaderPosition             =1'b0;      

reg [24-1:0]    IPv4_CheckSumCounter                =1'b0;
reg             IPv4_CheckSumValidFlag              =1'b0;

reg             IPValid0 = 0;
reg             IPValid1 = 0;
reg             IPValid2 = 0;
reg             IPValid3 = 0;
reg             IPValid  = 0;

reg [ 3-1:0]    IPValidUniCast = 0;
reg [ 3-1:0]    IPValidBroadCast = 0;

reg             IPv4_IHL_ValidFlag          =1'b0;      // only 20 byte suported
reg             IPv4_Version_ValidFlag      =1'b0;     
reg             IPv4_NoFragmentationFlag    =1'b0;

reg             IPv4_ValidateCheckSumPulse  =0;
reg             IPv4_HeaderValidationPulse  =0;
reg             IPv4_HeaderValidationDonePulse  =0;
reg             IPv4_HeaderValidationDoneFlag  =0;


always @(posedge CLK)
begin
if (TLAST_DONE_FLAG&&IPv4_Core_Sink_TVALID) RX_REG_IP4_PackTypeFlag    <=  (Ethernet_TypeCode == EtherType);

RX_REG_TFIRST     <=	IPv4_Core_Sink_TFIRST;
RX_REG_TVALID     <=    IPv4_Core_Sink_TVALID;
RX_REG_TERROR     <=    IPv4_Core_Sink_TERROR;
RX_REG_TLAST      <=    IPv4_Core_Sink_TLAST;
RX_REG_TDATA      <=    IPv4_Core_Sink_TDATA;

if (RX_REG_TFIRST&&RX_REG_TVALID) IPv4_ByteCountValidationDoneFlag <= 0; 
    else if ((IPv4_Core_Total_ByteCounter>20)&&(IPv4_Core_Total_ByteCounter>=IPv4_Total_Length))   IPv4_ByteCountValidationDoneFlag <= 1'b1; 
 
if (RX_REG_TFIRST&&RX_REG_TVALID) IPv4_PaddingValidationFlag <= 1'b1;
    else if ((IPv4_Core_Total_ByteCounter>20)&&(IPv4_Core_Total_ByteCounter>=IPv4_Total_Length))  IPv4_PaddingValidationFlag <= 1'b0;   
         
if (RX_REG_TFIRST&&RX_REG_TVALID) IP4_Core_HeaderPosition<=0;
	else if (RX_REG_TVALID&&(IP4_Core_HeaderPosition<({4'd5,2'b00}+1))) IP4_Core_HeaderPosition<= IP4_Core_HeaderPosition+1'b1;
	
if (RX_REG_TFIRST&&RX_REG_TVALID) IPv4_Core_Total_ByteCounter<=1'b1;
    else if (RX_REG_TVALID) IPv4_Core_Total_ByteCounter<=IPv4_Core_Total_ByteCounter+1'b1;

if (RX_REG_TFIRST&&RX_REG_TVALID) IP4_Core_HalfwordFlag<=1'b0;
	else if (RX_REG_TVALID) IP4_Core_HalfwordFlag<=!IP4_Core_HalfwordFlag;


if (RX_REG_IP4_PackTypeFlag)  IP4_Core_TFIRST <= RX_REG_TFIRST;   else IP4_Core_TFIRST  <=  0;
if (RX_REG_IP4_PackTypeFlag)  IP4_Core_TVALID <= RX_REG_TVALID;   else IP4_Core_TVALID  <=  0;
if (RX_REG_IP4_PackTypeFlag)  IP4_Core_TLAST  <= RX_REG_TLAST;    else IP4_Core_TLAST   <=  0; 
if (RX_REG_IP4_PackTypeFlag)  IP4_Core_TERROR <= RX_REG_TERROR;   else IP4_Core_TERROR  <=  0;  
if (RX_REG_IP4_PackTypeFlag)  IP4_Core_TDATA  <= RX_REG_TDATA;    else IP4_Core_TDATA   <=  0; 	
end


always @(posedge CLK)
begin

IPv4_ValidateCheckSumPulse <= IP4_Core_TVALID && (IP4_Core_HeaderPosition==({4'd5,2'b00}));
IPv4_HeaderValidationPulse <= IPv4_ValidateCheckSumPulse;

// Padding  removing 
IP4_Core_TVALID_D0      <= IP4_Core_TVALID && (IPv4_PaddingValidationFlag&&(!(IPv4_Core_Total_ByteCounter==IPv4_Total_Length)) || IP4_Core_TLAST); 
IP4_Core_TLAST_D0       <= IP4_Core_TLAST;
IP4_Core_TERROR_D0      <= IP4_Core_TERROR;
if (IPv4_PaddingValidationFlag  )         IP4_Core_TDATA_D0       <= IP4_Core_TDATA;
    else if (IP4_Core_TVALID_D0&&IP4_Core_TLAST_D0) IP4_Core_TDATA_D0       <= 0;


IP4_Core_TVALID_D1      <=  IP4_Core_TVALID_D0; 
IP4_Core_TLAST_D1       <=  IP4_Core_TLAST_D0;
IP4_Core_TDATA_D1       <=  IP4_Core_TDATA_D0;
IP4_Core_TERROR_D1      <=  IP4_Core_TERROR_D0 || ~IPv4_ByteCountValidationDoneFlag;



IP4_Core_TVALID_D2  <=  IP4_Core_TVALID_D1;
IP4_Core_TLAST_D2   <=  IP4_Core_TLAST_D1;
IP4_Core_TDATA_D2   <=  IP4_Core_TDATA_D1;
IP4_Core_TERROR_D2    <= IP4_Core_TERROR_D1;



if (IP4_Core_TVALID&&(IP4_Core_HeaderPosition >= 12)&&(IP4_Core_HeaderPosition <= 15)) 
    begin
        IP4_Core_IP_SHIFT0 <=IP4_Core_TDATA;
        IP4_Core_IP_SHIFT1 <=IP4_Core_IP_SHIFT0;
        IP4_Core_IP_SHIFT2 <=IP4_Core_IP_SHIFT1;
        IP4_Core_IP_SHIFT3 <=IP4_Core_IP_SHIFT2;
    end
    

end

always @(posedge CLK)
begin

	
if (IP4_Core_TVALID)
    begin
    IP4_Core_TDATA_SHIFT <=IP4_Core_TDATA;
    
    if ((IP4_Core_HeaderPosition== 0))  IPv4_IHL_ValidFlag                  <=  (IP4_Core_TDATA[3:0]==4'd5);
    if ((IP4_Core_HeaderPosition== 0))  IPv4_Version_ValidFlag              <=  (IP4_Core_TDATA[7:4]==4'd4);	
    
    if ((IP4_Core_HeaderPosition== 3))  IPv4_Total_Length                   <=  {IP4_Core_TDATA_SHIFT,IP4_Core_TDATA};
    if ((IP4_Core_HeaderPosition== 7))  IPv4_NoFragmentationFlag            <= 1; // {IP4_Core_TDATA_SHIFT,IP4_Core_TDATA}==0;
    if ((IP4_Core_HeaderPosition== 9))  IP4_Used_Protocol                   <=   IP4_Core_TDATA;
    
//    if ((IP4_Core_HeaderPosition==16)) IPValid3<=(IP4_Core_TDATA==Internal_IP4_ADDR[31:24])||(IP4_Core_TDATA==8'hFF);
//    if ((IP4_Core_HeaderPosition==17)) IPValid2<=(IP4_Core_TDATA==Internal_IP4_ADDR[23:16])||(IP4_Core_TDATA==8'hFF);
//    if ((IP4_Core_HeaderPosition==18)) IPValid1<=(IP4_Core_TDATA==Internal_IP4_ADDR[15: 8])||(IP4_Core_TDATA==8'hFF);
//    if ((IP4_Core_HeaderPosition==19)) IPValid0<=(IP4_Core_TDATA==Internal_IP4_ADDR[ 7: 0])||(IP4_Core_TDATA==8'hFF);
    
//    IPValid<=IPValid0&&IPValid1&&IPValid2&&IPValid3;
    
    if ((IP4_Core_HeaderPosition==16)&&(IP4_Core_TDATA==Internal_IP4_ADDR[31:24])) IPValidUniCast <= 1;
        else if ((IP4_Core_HeaderPosition==17)&&(IP4_Core_TDATA==Internal_IP4_ADDR[23:16])) IPValidUniCast <= IPValidUniCast + 1;
            else if ((IP4_Core_HeaderPosition==18)&&(IP4_Core_TDATA==Internal_IP4_ADDR[15: 8])) IPValidUniCast <= IPValidUniCast + 1;
                else if ((IP4_Core_HeaderPosition==19)&&(IP4_Core_TDATA==Internal_IP4_ADDR[ 7: 0])) IPValidUniCast <= IPValidUniCast + 1;    
    
    if ((IP4_Core_HeaderPosition==16)&&(IP4_Core_TDATA==8'hFF)) IPValidBroadCast <= 1;
        else if ((IP4_Core_HeaderPosition==17)&&(IP4_Core_TDATA==8'hFF)) IPValidBroadCast <= IPValidBroadCast + 1;
            else if ((IP4_Core_HeaderPosition==18)&&(IP4_Core_TDATA==8'hFF)) IPValidBroadCast <= IPValidBroadCast + 1;
                else if ((IP4_Core_HeaderPosition==19)&&(IP4_Core_TDATA==8'hFF)) IPValidBroadCast <= IPValidBroadCast + 1;     
    
    
    IPValid<= (IPValidUniCast==4)||(IPValidBroadCast==4);
    
    if (IP4_Core_TFIRST) IPv4_CheckSumCounter<=1'b0;
	   else if (IP4_Core_HalfwordFlag) IPv4_CheckSumCounter<=IPv4_CheckSumCounter+{IP4_Core_TDATA_SHIFT,IP4_Core_TDATA};
    end
    
    if (IPv4_ValidateCheckSumPulse) IPv4_CheckSumValidFlag<=((IPv4_CheckSumCounter[15:0]+IPv4_CheckSumCounter[23:16])==16'hFFFF);
    IPv4_HeaderValidationDonePulse<=IPv4_HeaderValidationPulse && IPv4_CheckSumValidFlag && IPValid  && IPv4_NoFragmentationFlag && IPv4_Version_ValidFlag && IPv4_IHL_ValidFlag;
    
    if (IPv4_HeaderValidationPulse ) IPv4_HeaderValidationDoneFlag <= IPv4_CheckSumValidFlag && IPValid  && IPv4_NoFragmentationFlag && IPv4_Version_ValidFlag && IPv4_IHL_ValidFlag;
        else    if (IP4_Core_TLAST_D2) IPv4_HeaderValidationDoneFlag <= 1'b0;

    IPv4_Core_Source_TFIRST <= IP4_Core_TVALID_D2 && IPv4_HeaderValidationDonePulse ;
    IPv4_Core_Source_TVALID <= IP4_Core_TVALID_D2 && IPv4_HeaderValidationDoneFlag  ;
    IPv4_Core_Source_TLAST  <= IP4_Core_TVALID_D2 && IPv4_HeaderValidationDoneFlag && IP4_Core_TLAST_D2; 
    if (IPv4_HeaderValidationDoneFlag) IPv4_Core_Source_TERROR <= IP4_Core_TERROR_D2; else  IPv4_Core_Source_TERROR <=0;   
    if (IPv4_HeaderValidationDoneFlag) IPv4_Core_Source_TDATA  <= IP4_Core_TDATA_D2;  else  IPv4_Core_Source_TDATA  <=0;    
    
    
    if (IP4_Core_TVALID_D2 && IPv4_HeaderValidationDonePulse) External_MAC_ADDR_OUT   <= External_MAC_ADDR_IN;
    if (IP4_Core_TVALID_D2 && IPv4_HeaderValidationDonePulse) External_IP4_ADDR       <= {IP4_Core_IP_SHIFT3,IP4_Core_IP_SHIFT2,IP4_Core_IP_SHIFT1,IP4_Core_IP_SHIFT0};
end

endmodule