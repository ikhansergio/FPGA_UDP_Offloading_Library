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

module Ethernet_II_MAC_Header_Generator
#(
parameter EtherTypeValue = 16'h0800                       
)
(
input  wire              CLK,

input  wire              MAC_TRY,

input  wire              MAC_Header_PreSet,
input  wire [ 6-1:0]     MAC_Header_Position,
input  wire	[48-1:0]     MAC_LOCAL_ADDR    ,
input  wire	[48-1:0]     MAC_REMOTE_ADDR   ,

output wire    [8-1:0]   MAC_Header
);

(* keep = "true" *) reg [8-1:0]     TX_SwitchREG_Ethernet_II_External_MAC     =   0;
(* keep = "true" *) reg [8-1:0]     TX_SwitchREG_Ethernet_II_Internal_MAC     =   0;

(* keep = "true" *) reg [3-1:0]     TX_SwitchREG_Decoder                      =   0;


wire [15:0] wEtherTypeValue;
assign wEtherTypeValue = EtherTypeValue;

always @(posedge CLK)
begin
    if (MAC_Header_PreSet)
        begin
        TX_SwitchREG_Ethernet_II_External_MAC       <= MAC_REMOTE_ADDR [39:32] ;
        TX_SwitchREG_Decoder   <=0;
        end else
        if (MAC_TRY)
            begin
            if (MAC_Header_Position==7'd00) TX_SwitchREG_Ethernet_II_External_MAC<= MAC_REMOTE_ADDR [47:40] ;                         // never used condition
                else if (MAC_Header_Position==7'd01) TX_SwitchREG_Ethernet_II_External_MAC<= MAC_REMOTE_ADDR [39:32] ;                // never used condition
	               else if (MAC_Header_Position==7'd02) TX_SwitchREG_Ethernet_II_External_MAC<= MAC_REMOTE_ADDR [31:24] ;
	                   else if (MAC_Header_Position==7'd03) TX_SwitchREG_Ethernet_II_External_MAC<= MAC_REMOTE_ADDR [23:16] ;
	                       else if (MAC_Header_Position==7'd04) TX_SwitchREG_Ethernet_II_External_MAC<= MAC_REMOTE_ADDR [15: 8] ;
	                           else if (MAC_Header_Position==7'd05) TX_SwitchREG_Ethernet_II_External_MAC<= MAC_REMOTE_ADDR [ 7: 0] ;
	                               else TX_SwitchREG_Ethernet_II_External_MAC<=0;
	        
	         if (MAC_Header_Position==7'd06) TX_SwitchREG_Ethernet_II_Internal_MAC<= MAC_LOCAL_ADDR  [47:40] ;
                else if (MAC_Header_Position==7'd07) TX_SwitchREG_Ethernet_II_Internal_MAC<= MAC_LOCAL_ADDR  [39:32] ;
	               else if (MAC_Header_Position==7'd08) TX_SwitchREG_Ethernet_II_Internal_MAC<= MAC_LOCAL_ADDR  [31:24] ;
	                   else if (MAC_Header_Position==7'd09) TX_SwitchREG_Ethernet_II_Internal_MAC<= MAC_LOCAL_ADDR  [23:16] ;
	                       else if (MAC_Header_Position==7'd10) TX_SwitchREG_Ethernet_II_Internal_MAC<= MAC_LOCAL_ADDR  [15: 8] ;
	                           else if (MAC_Header_Position==7'd11) TX_SwitchREG_Ethernet_II_Internal_MAC<= MAC_LOCAL_ADDR  [ 7: 0] ;
	                               else if (MAC_Header_Position==7'd12) TX_SwitchREG_Ethernet_II_Internal_MAC<=wEtherTypeValue[15:8];
	                                   else if (MAC_Header_Position==7'd13) TX_SwitchREG_Ethernet_II_Internal_MAC<=wEtherTypeValue[7:0];
	                                       else TX_SwitchREG_Ethernet_II_Internal_MAC<=0;
	                                       
	         if ((MAC_Header_Position>=7'd00)&& (MAC_Header_Position<=7'd05)) TX_SwitchREG_Decoder <= 0;
                else if ((MAC_Header_Position>=7'd06)&& (MAC_Header_Position<=7'd13)) TX_SwitchREG_Decoder <= 1;
                    else if ((MAC_Header_Position>=7'd14)&& (MAC_Header_Position<=7'd23)) TX_SwitchREG_Decoder <= 2;
                        else if ((MAC_Header_Position>=7'd24)&& (MAC_Header_Position<=7'd33)) TX_SwitchREG_Decoder <= 3;
                            else if ((MAC_Header_Position>=7'd34)&& (MAC_Header_Position<=7'd41)) TX_SwitchREG_Decoder <= 4;
                                else TX_SwitchREG_Decoder <= 5;
            end
end

assign MAC_Header = (TX_SwitchREG_Decoder==0) ? TX_SwitchREG_Ethernet_II_External_MAC :
                                    (TX_SwitchREG_Decoder==1) ? TX_SwitchREG_Ethernet_II_Internal_MAC :0;


endmodule
