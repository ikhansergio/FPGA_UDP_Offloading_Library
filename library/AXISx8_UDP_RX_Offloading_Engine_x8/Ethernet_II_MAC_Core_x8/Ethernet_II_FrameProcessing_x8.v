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

module Ethernet_II_FrameProcessing_x8
(
/////////////////////////////////////////////////////////////////////////////////////
//Rx Interface
	input wire 	           RX_CLK,
	input wire 	           RX_TVALID,
	input wire 	           RX_TERROR,
	input wire 	           RX_TLAST,
	input wire [ 8-1:0]    RX_TDATA,
	
	output wire            Ethernet_II_Frame_TLAST,
	output wire            Ethernet_II_Frame_TVALID,
	output wire            Ethernet_II_Frame_TERROR,
	output wire [ 8-1 :0]  Ethernet_II_Frame_TDATA,
	input  wire [48-1:0]   Ethernet_II_Internal_MAC ,

	output wire [48-1:0]   Ethernet_II_External_MAC,
	output wire [16-1:0]   Ethernet_II_TypeCode,
	
/////////////////////////////////////////////////////////////////////////////////////
//Tx Interface
	input  wire 	      TX_CLK,
	output wire 	      MAC_FrameBody_TRDY,
	input  wire 	      MAC_FrameBody_TVALID,
	input  wire 	      MAC_FrameBody_TLAST,
	input  wire [ 8-1:0]  MAC_FrameBody_TDATA,
	
    input  wire           TX_TRDY,
    output wire           TX_TVALID,
    output wire           TX_TLAST,
    output wire  [8-1:0]  TX_TDATA

);

(* KEEP_HIERARCHY = "TRUE" *)
 Ethernet_II_FrameDecoder_x8    Ethernet_II_FrameDecoder_x8_inst(
.CLK                                                   (RX_CLK),
.TLAST                                                 (RX_TLAST),
.TVALID                                                (RX_TVALID),
.TERROR                                                (RX_TERROR),
.TDATA                                                 (RX_TDATA),
	
.Ethernet_II_Frame_TLAST                               (Ethernet_II_Frame_TLAST),
.Ethernet_II_Frame_TVALID                              (Ethernet_II_Frame_TVALID),
.Ethernet_II_Frame_TERROR                              (Ethernet_II_Frame_TERROR),
.Ethernet_II_Frame_TDATA                               (Ethernet_II_Frame_TDATA),
.Ethernet_II_Internal_MAC                              (Ethernet_II_Internal_MAC),

.Ethernet_II_External_MAC                              (Ethernet_II_External_MAC),
.Ethernet_II_TypeCode                                  (Ethernet_II_TypeCode)
);

(* KEEP_HIERARCHY = "TRUE" *)
MAC_FrameBody2EthernetPhysicalFrameConverter_x8 MAC_FrameBody2EthernetPhysicalFrameConverter_x8_inst
(
.clk                            (TX_CLK),
.MAC_FrameBody_TRDY             (MAC_FrameBody_TRDY),
.MAC_FrameBody_TVALID           (MAC_FrameBody_TVALID),
.MAC_FrameBody_TLAST            (MAC_FrameBody_TLAST),
.MAC_FrameBody_TDATA            (MAC_FrameBody_TDATA),

.EthernetPhysicalFrame_TRDY     (TX_TRDY),
.EthernetPhysicalFrame_TVALID   (TX_TVALID),
.EthernetPhysicalFrame_TLAST    (TX_TLAST),
.EthernetPhysicalFrame_TDATA    (TX_TDATA)
);
    
endmodule
