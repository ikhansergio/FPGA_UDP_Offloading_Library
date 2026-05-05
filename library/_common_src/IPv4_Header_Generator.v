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

module IPv4_Header_Generator
#(
    parameter   IPv4_Protocol_Number      = 8'h1   
) 

(
input  wire              CLK,

input  wire              IPv4_TRY,

input  wire [16-1:0]     IPv4_TotalLength,

input  wire [ 6-1:0]     IPv4_Header_Position,
input  wire	[48-1:0]     IPv4_LOCAL_ADDR    ,
input  wire	[48-1:0]     IPv4_REMOTE_ADDR   ,

output wire    [8-1:0]   IPv4_Header
);

(* keep = "true" *) reg [16-1:0]    IPv4_HeaderChecksum                       =   0;
(* keep = "true" *) reg [24-1:0]    IPv4_HeaderChecksum_Step0                 =   0;
(* keep = "true" *) reg [24-1:0]    IPv4_HeaderChecksum_Step1                 =   0;
(* keep = "true" *) reg [24-1:0]    IPv4_HeaderChecksum_Step2                 =   0;
(* keep = "true" *) reg [24-1:0]    IPv4_HeaderChecksum_Step3                 =   0;
(* keep = "true" *) reg [17-1:0]    IPv4_HeaderChecksum_Step4                 =   0;

(* keep = "true" *) reg [8-1:0]     TX_SwitchREG_Ethernet_II_IP4_HeaderHi     =   0;
(* keep = "true" *) reg [8-1:0]     TX_SwitchREG_Ethernet_II_IP4_HeaderLo     =   0;

(* keep = "true" *) reg [3-1:0]     TX_SwitchREG_Decoder                      =   0;

(* keep = "true" *) reg [16-1:0]    IPv4_Identification =0;

always @(posedge CLK)
begin

IPv4_HeaderChecksum_Step0   <=  IPv4_REMOTE_ADDR[31:16]+IPv4_REMOTE_ADDR[15: 0];
IPv4_HeaderChecksum_Step1   <=  IPv4_Identification + IPv4_TotalLength ;
IPv4_HeaderChecksum_Step2   <=  IPv4_HeaderChecksum_Step0 + IPv4_HeaderChecksum_Step1 + 16'h4500 + (16'h8000  + IPv4_Protocol_Number);
IPv4_HeaderChecksum_Step3   <=  IPv4_LOCAL_ADDR[31:16] +IPv4_LOCAL_ADDR[15: 0] + IPv4_HeaderChecksum_Step2;
IPv4_HeaderChecksum_Step4   <=  (IPv4_HeaderChecksum_Step3[15:0]+{8'h00,IPv4_HeaderChecksum_Step3[23:16]});

IPv4_HeaderChecksum         <= ~(IPv4_HeaderChecksum_Step4[15:0]+{15'h00,IPv4_HeaderChecksum_Step4[16]});

if (IPv4_TRY && (IPv4_Header_Position==7'd33) ) IPv4_Identification  <= IPv4_Identification +1;
if (IPv4_TRY)
    begin                         
	if (IPv4_Header_Position==7'd14) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=8'h45;                                                                        // Version and IHL
        else if (IPv4_Header_Position==7'd15) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=8'h00;                                                                // DSCP	and ECN
            else if (IPv4_Header_Position==7'd16) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=IPv4_TotalLength[15:8];                                            // Total Length High
                else if (IPv4_Header_Position==7'd17) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=IPv4_TotalLength[ 7:0];                                        // Total Length Low
                    else if (IPv4_Header_Position==7'd18) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=IPv4_Identification[15:8];                                 // Identification High
                        else if (IPv4_Header_Position==7'd19) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=IPv4_Identification[ 7:0];                             // Identification Low
                            else if (IPv4_Header_Position==7'd20) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=8'h00;                                             // Flags	and Fragment Offset High
                                else if (IPv4_Header_Position==7'd21) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=8'h00;                                         // Flags	and Fragment Offset Low
                                    else if (IPv4_Header_Position==7'd22) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=8'h80;                                     // Time to Live
                                        else if (IPv4_Header_Position==7'd23) TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=IPv4_Protocol_Number;                                 // Protocol
                                            else TX_SwitchREG_Ethernet_II_IP4_HeaderHi<=0;  
	                                               
	if (IPv4_Header_Position==7'd24) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_HeaderChecksum[15:8];                                                    // Header Checksum High
        else if (IPv4_Header_Position==7'd25) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_HeaderChecksum[ 7:0];                                            // Header Checksum Low
            else if (IPv4_Header_Position==7'd26) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_LOCAL_ADDR[31:24];                                          // Source address
                else if (IPv4_Header_Position==7'd27) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_LOCAL_ADDR[23:16];                                      // Source address
                    else if (IPv4_Header_Position==7'd28) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_LOCAL_ADDR[15: 8];                                  // Source address
                        else if (IPv4_Header_Position==7'd29) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_LOCAL_ADDR[ 7: 0];                              // Source address
                            else if (IPv4_Header_Position==7'd30) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_REMOTE_ADDR[31:24];                          // Destination address
                                else if (IPv4_Header_Position==7'd31) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_REMOTE_ADDR[23:16];                      // Destination address
                                    else if (IPv4_Header_Position==7'd32) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_REMOTE_ADDR[15: 8];                  // Destination address
                                        else if (IPv4_Header_Position==7'd33) TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=IPv4_REMOTE_ADDR[ 7: 0];              // Destination address
                                            else TX_SwitchREG_Ethernet_II_IP4_HeaderLo<=0; 
	                                               
	         if ((IPv4_Header_Position>=7'd00)&& (IPv4_Header_Position<=7'd05)) TX_SwitchREG_Decoder <= 0;
                else if ((IPv4_Header_Position>=7'd06)&& (IPv4_Header_Position<=7'd13)) TX_SwitchREG_Decoder <= 1;
                    else if ((IPv4_Header_Position>=7'd14)&& (IPv4_Header_Position<=7'd23)) TX_SwitchREG_Decoder <= 2;
                        else if ((IPv4_Header_Position>=7'd24)&& (IPv4_Header_Position<=7'd33)) TX_SwitchREG_Decoder <= 3;
                            else if ((IPv4_Header_Position>=7'd34)&& (IPv4_Header_Position<=7'd41)) TX_SwitchREG_Decoder <= 4;
                                else TX_SwitchREG_Decoder <= 5;
                        
    end
    
    
end

assign IPv4_Header = (TX_SwitchREG_Decoder==2) ? TX_SwitchREG_Ethernet_II_IP4_HeaderHi :
                                    (TX_SwitchREG_Decoder==3) ? TX_SwitchREG_Ethernet_II_IP4_HeaderLo :0;

endmodule