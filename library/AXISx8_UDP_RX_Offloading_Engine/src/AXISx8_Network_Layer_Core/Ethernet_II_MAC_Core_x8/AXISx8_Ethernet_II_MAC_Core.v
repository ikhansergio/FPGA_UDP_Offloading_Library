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

module AXISx8_Ethernet_II_MAC_Core
#(
    parameter TxPortCount = 3    //  Number of UDP Tx Masters + ARP + ICMP PING
)
(
/////////////////////////////////////////////////////////////////////////////////////
//Rx Interface
	input wire 	                            RX_CLK,
	input wire 	                            RX_TVALID,
	input wire 	                            RX_TERROR,
	input wire 	                            RX_TLAST,
	input wire [ 8-1:0]                     RX_TDATA,
	
	output wire                             Source_TVALID,
	output wire                             Source_TERROR,
	output wire                             Source_TLAST,
	output wire [ 8-1 :0]                   Source_TDATA,
	
	input  wire [48-1:0]                    MAC_LOCAL_ADDR_IN ,
	output wire [48-1:0]                    MAC_REMOTE_ADDR_OUT,
	output wire [16-1:0]                    MAC_Eth_II_TypeCode,
	
/////////////////////////////////////////////////////////////////////////////////////
//Tx Interface
	input  wire 	                        TX_CLK,
	output wire [1*TxPortCount-1:0]	        Sink_TRDY,
	input  wire [1*TxPortCount-1:0]	        Sink_TVALID,
	input  wire [1*TxPortCount-1:0]	        Sink_TERROR,
	input  wire [1*TxPortCount-1:0]	        Sink_TLAST,
	input  wire [8*TxPortCount-1:0]         Sink_TDATA,
	
    input  wire                             TX_TRDY,
    output wire                             TX_TVALID,
    output wire                             TX_TERROR,
    output wire                             TX_TLAST,
    output wire [8-1:0]                     TX_TDATA
);

	wire 	       wMAC_FrameBody_TRDY;
	wire 	       wMAC_FrameBody_TVALID;
	wire 	       wMAC_FrameBody_TERROR;
	wire 	       wMAC_FrameBody_TLAST;
	wire [ 8-1:0]  wMAC_FrameBody_TDATA;

(* KEEP_HIERARCHY = "TRUE" *)
    EthTxScheduler #(.TxPortCount(TxPortCount)) EthTxScheduler_inst
    (
    .Clk                           (TX_CLK),

    .Sink_TRDY                     (Sink_TRDY),
    .Sink_TERROR                   (Sink_TERROR),
    .Sink_TVALID                   (Sink_TVALID),
    .Sink_TLAST                    (Sink_TLAST),
    .Sink_TDATA                    (Sink_TDATA),
    
    .Source_RDY                    (wMAC_FrameBody_TRDY),
    .Source_Val                    (wMAC_FrameBody_TVALID),
    .Source_Err                    (wMAC_FrameBody_TERROR),
    .Source_EoF                    (wMAC_FrameBody_TLAST),
    .Source_DAT                    (wMAC_FrameBody_TDATA)
    );
 
(* KEEP_HIERARCHY = "TRUE" *)
    Ethernet_II_FrameProcessing_x8     Ethernet_II_FrameProcessing_x8_inst(
	.RX_CLK                            (RX_CLK),
	.RX_TLAST                          (RX_TLAST),
	.RX_TVALID                         (RX_TVALID),
	.RX_TERROR                         (RX_TERROR),
	.RX_TDATA                          (RX_TDATA),
	
	.Ethernet_II_Frame_TLAST           (Source_TLAST            ),
	.Ethernet_II_Frame_TVALID          (Source_TVALID           ),
	.Ethernet_II_Frame_TERROR          (Source_TERROR           ),
	.Ethernet_II_Frame_TDATA           (Source_TDATA            ),
	.Ethernet_II_Internal_MAC          (MAC_LOCAL_ADDR_IN       ),

	.Ethernet_II_External_MAC          (MAC_REMOTE_ADDR_OUT     ),
	.Ethernet_II_TypeCode              (MAC_Eth_II_TypeCode     ),
    //////////////////////////////////////////////////////////////
    
    .TX_CLK                            (TX_CLK),
	.MAC_FrameBody_TRDY                (wMAC_FrameBody_TRDY),
	.MAC_FrameBody_TVALID              (wMAC_FrameBody_TVALID),
	.MAC_FrameBody_TERROR              (wMAC_FrameBody_TERROR),                                   
	.MAC_FrameBody_TLAST               (wMAC_FrameBody_TLAST),
	.MAC_FrameBody_TDATA               (wMAC_FrameBody_TDATA),
	
    .TX_TRDY                           (TX_TRDY),
    .TX_TVALID                         (TX_TVALID),
    .TX_TERROR                         (TX_TERROR),
    .TX_TLAST                          (TX_TLAST),
    .TX_TDATA                          (TX_TDATA)
    );

endmodule

