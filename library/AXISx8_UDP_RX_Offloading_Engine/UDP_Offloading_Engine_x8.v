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

module UDP_Offloading_Engine_x8
#(
    parameter TxPortCount = 3    //  Number of UDP Tx Masters + ARP
)
(
/////////////////////////////////////////////////////////////////////////////////////
// Rx Interface                                                                   ///
/////////////////////////////////////////////////////////////////////////////////////
input wire 	                            RX_CLK,
input wire 	                            RX_TLAST,
input wire 	                            RX_TVALID,
input wire 	                            RX_TERROR,
input wire  [ 8-1:0]                    RX_TDATA,

input  wire [48-1:0]                    MAC_LOCAL_ADDR_IN,
input  wire [32-1:0]                    IP4_LOCAL_ADDR_IN,
input  wire [16-1:0]                    UDP_LOCAL_PORT_IN,

output wire [48-1:0]                    MAC_REMOTE_ADDR_OUT,
output wire [32-1:0]                    IP4_REMOTE_ADDR_OUT,
output wire [16-1:0]                    UDP_REMOTE_PORT_OUT,

output wire  					        UDP_Data_Source_TFIRST,
output wire 					        UDP_Data_Source_TVALID,
output wire 					        UDP_Data_Source_TERROR,
output wire				                UDP_Data_Source_TLAST ,
output wire [ 8-1:0]		            UDP_Data_Source_TDATA ,
/////////////////////////////////////////////////////////////////////////////////////
//  Tx Interface                                                                  ///
/////////////////////////////////////////////////////////////////////////////////////
input  wire 	                        TX_CLK,
output wire [1*TxPortCount-1:0]	        MAC_TxFrameBody_TRDY,
input  wire [1*TxPortCount-1:0]	        MAC_TxFrameBody_TVALID,
input  wire [1*TxPortCount-1:0]	        MAC_TxFrameBody_TLAST,
input  wire [8*TxPortCount-1:0]         MAC_TxFrameBody_TDATA,
	
input  wire                             TX_TRDY,
output wire                             TX_TVALID,
output wire                             TX_TLAST,
output wire [8-1:0]                     TX_TDATA
);

    
wire            wNetworkLayerCore_Source_TLAST;
wire            wNetworkLayerCore_Source_TVALID;
wire            wNetworkLayerCore_Source_TERROR;
wire [ 8-1:0]   wNetworkLayerCore_Source_TDATA;

wire [ 8-1:0]   wNetwork_Layer_IP4_Used_Protocol;
wire [32-1:0]   wIP4_REMOTE_ADDR;
wire [48-1:0]   wDataLinkLayer_Remote_MAC_ADDR;

/////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------//
//                                                                                  //
//---------------------------------------------------------------------------------//
//                                                                                  //
//---------------------------------------------------------------------------------//
///////////////////////////////////////////////////////////////////////////////////// 
(* KEEP_HIERARCHY = "TRUE" *)  
NetworkLayerCore_x8   #(.TxPortCount(TxPortCount))   NetworkLayerCore_x8_inst
(
/////////////////////////////////////////////////////////////////////////////////////
// Rx Interface                                                                   ///
/////////////////////////////////////////////////////////////////////////////////////
    .RX_CLK                                (RX_CLK),
    .RX_TLAST                              (RX_TLAST),
    .RX_TVALID                             (RX_TVALID),
    .RX_TERROR                             (RX_TERROR),
    .RX_TDATA                              (RX_TDATA),

    .IPv4_Core_Source_TVALID               (wNetworkLayerCore_Source_TVALID ),
    .IPv4_Core_Source_TERROR               (wNetworkLayerCore_Source_TERROR ),
    .IPv4_Core_Source_TLAST                (wNetworkLayerCore_Source_TLAST  ),
    .IPv4_Core_Source_TDATA                (wNetworkLayerCore_Source_TDATA  ),

    .IP4_Used_Protocol_OUT                 (wNetwork_Layer_IP4_Used_Protocol),
    .IP4_LOCAL_ADDR_IN                     ( IP4_LOCAL_ADDR_IN),	
    .IP4_REMOTE_ADDR_OUT                   (wIP4_REMOTE_ADDR),
    .MAC_LOCAL_ADDR_IN                     ( MAC_LOCAL_ADDR_IN),
    .MAC_REMOTE_ADDR_OUT                   (wDataLinkLayer_Remote_MAC_ADDR),
/////////////////////////////////////////////////////////////////////////////////////
//  Tx Interface                                                                  ///
/////////////////////////////////////////////////////////////////////////////////////
    .TX_CLK                                (TX_CLK),
    .MAC_TxFrameBody_TRDY                  (MAC_TxFrameBody_TRDY),
    .MAC_TxFrameBody_TVALID                (MAC_TxFrameBody_TVALID),
    .MAC_TxFrameBody_TLAST                 (MAC_TxFrameBody_TLAST),
    .MAC_TxFrameBody_TDATA                 (MAC_TxFrameBody_TDATA),

    .TX_TRDY                               (TX_TRDY),
    .TX_TVALID                             (TX_TVALID),
    .TX_TLAST                              (TX_TLAST),
    .TX_TDATA                              (TX_TDATA)
 );
/////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------//
//      Transport Layer. Rx UDP datagrams processing IP core.                      //
//---------------------------------------------------------------------------------//
//      Check port, datagram size and checksum.                                    //
//---------------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////   
(* KEEP_HIERARCHY = "TRUE" *)
UDP_RxDatagramProcessing_Core_x8           UDP_RxDatagramProcessing_Core_x8_inst
(
	.CLK                                   (RX_CLK),
	
	.UDP_Core_Sink_TVALID                  (wNetworkLayerCore_Source_TVALID),
	.UDP_Core_Sink_TERROR                  (wNetworkLayerCore_Source_TERROR ),
	.UDP_Core_Sink_TLAST                   (wNetworkLayerCore_Source_TLAST),
	.UDP_Core_Sink_TDATA                   (wNetworkLayerCore_Source_TDATA),
	
	.UDP_LOCAL_PORT_IN                     (UDP_LOCAL_PORT_IN ),
    .IP4_Used_Protocol_IN                  (wNetwork_Layer_IP4_Used_Protocol),
	.IP4_LOCAL_ADDR_IN                     ( IP4_LOCAL_ADDR_IN),
	.IP4_REMOTE_ADDR_IN                    (wIP4_REMOTE_ADDR),
	.MAC_REMOTE_ADDR_IN                    (wDataLinkLayer_Remote_MAC_ADDR),
	
	.UDP_REMOTE_PORT_OUT                   ( UDP_REMOTE_PORT_OUT           ),
	.IP4_REMOTE_ADDR_OUT                   ( IP4_REMOTE_ADDR_OUT           ),
	.MAC_REMOTE_ADDR_OUT                   ( MAC_REMOTE_ADDR_OUT           ),
    	
	.UDP_Core_Source_TFIRST                (UDP_Data_Source_TFIRST),
	.UDP_Core_Source_TVALID                (UDP_Data_Source_TVALID),
	.UDP_Core_Source_TERROR                (UDP_Data_Source_TERROR),
	.UDP_Core_Source_TLAST                 (UDP_Data_Source_TLAST),
	.UDP_Core_Source_TDATA                 (UDP_Data_Source_TDATA)
);

    
endmodule
