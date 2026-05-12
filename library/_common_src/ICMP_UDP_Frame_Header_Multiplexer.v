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

module ICMP_UDP_Frame_Header_Multiplexer
(
input  wire              CLK,

input  wire              Frame_TRY,
input  wire              Frame_PreSet,
input  wire [ 8-1:0]     Frame_PreSetValue,
input  wire [ 6-1:0]     Frame_Position,

input  wire [ 8-1:0]     Header_Ethernet_II_MAC_Part,
input  wire [ 8-1:0]     Header_IPv4_Part,
input  wire [ 8-1:0]     Header_ICMP_PING_Part,
input  wire [ 8-1:0]     Data_Payload_Part,

output reg   [8-1:0]     Tx_MAC_FrameBody_TDATA =   0
);

(* KEEP = "TRUE" *) reg [3-1:0] TX_SwitchREG_Decoder =   0;

always @(posedge CLK)
begin
if (Frame_PreSet)
    begin
        Tx_MAC_FrameBody_TDATA <= Frame_PreSetValue;
        TX_SwitchREG_Decoder   <=0;
    end 
    else if (Frame_TRY) 
    begin
        if ((Frame_Position>=7'd00)&& (Frame_Position<=7'd05)) TX_SwitchREG_Decoder <= 0;
            else if ((Frame_Position>=7'd06)&& (Frame_Position<=7'd13)) TX_SwitchREG_Decoder <= 1;
                else if ((Frame_Position>=7'd14)&& (Frame_Position<=7'd23)) TX_SwitchREG_Decoder <= 2;
                    else if ((Frame_Position>=7'd24)&& (Frame_Position<=7'd33)) TX_SwitchREG_Decoder <= 3;
                        else if ((Frame_Position>=7'd34)&& (Frame_Position<=7'd41)) TX_SwitchREG_Decoder <= 4;
                            else TX_SwitchREG_Decoder <= 5;
                                
        if (TX_SwitchREG_Decoder==0) Tx_MAC_FrameBody_TDATA <= Header_Ethernet_II_MAC_Part;
            else if (TX_SwitchREG_Decoder==1)  Tx_MAC_FrameBody_TDATA <= Header_Ethernet_II_MAC_Part;
                else if (TX_SwitchREG_Decoder==2)  Tx_MAC_FrameBody_TDATA <= Header_IPv4_Part;
                    else if (TX_SwitchREG_Decoder==3)  Tx_MAC_FrameBody_TDATA <= Header_IPv4_Part;
                        else if (TX_SwitchREG_Decoder==4)  Tx_MAC_FrameBody_TDATA <= Header_ICMP_PING_Part;
                            else if (TX_SwitchREG_Decoder==5)  Tx_MAC_FrameBody_TDATA <= Data_Payload_Part;//0;
                    
    end
end

endmodule

