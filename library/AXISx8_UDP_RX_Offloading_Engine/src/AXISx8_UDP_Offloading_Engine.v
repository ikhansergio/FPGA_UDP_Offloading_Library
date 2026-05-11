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

module AXISx8_UDP_Offloading_Engine
#(
parameter TxPortCount  = 3              ,  //  Number of  Tx Masters 
parameter NumberOf_RX_UDP_Ports  = 1    ,  //  Number of  RX UDP Chanels
parameter Has_ARP_Proc = "YES"          ,
parameter HasICMP_PING = "YES"
)
(
/////////////////////////////////////////////////////////////////////////////////////
// Rx Interface                                                                   ///
/////////////////////////////////////////////////////////////////////////////////////
input  wire 	                            Sink_PHY_RX_CLK,
input  wire 	                            Sink_PHY_RX_TLAST,
input  wire 	                            Sink_PHY_RX_TVALID,
input  wire 	                            Sink_PHY_RX_TERROR,
input  wire [ 8-1:0]                        Sink_PHY_RX_TDATA,

input  wire [48-1:0]                        MAC_LOCAL_ADDR_IN,
input  wire [32-1:0]                        IP4_LOCAL_ADDR_IN,
input  wire [ NumberOf_RX_UDP_Ports*16-1:0] UDP_LOCAL_PORT_IN,

output wire [ NumberOf_RX_UDP_Ports*48-1:0] MAC_REMOTE_ADDR_OUT,
output wire [ NumberOf_RX_UDP_Ports*32-1:0] IP4_REMOTE_ADDR_OUT,
output wire [ NumberOf_RX_UDP_Ports*16-1:0] UDP_REMOTE_PORT_OUT,

output wire [ NumberOf_RX_UDP_Ports*1-1:0 ] Source_TFIRST,
output wire [ NumberOf_RX_UDP_Ports*1-1:0 ] Source_TVALID,
output wire [ NumberOf_RX_UDP_Ports*1-1:0 ] Source_TERROR,
output wire [ NumberOf_RX_UDP_Ports*1-1:0 ] Source_TLAST ,
output wire [ NumberOf_RX_UDP_Ports*8-1:0 ] Source_TDATA ,
/////////////////////////////////////////////////////////////////////////////////////
//  Tx Interface                                                                  ///
/////////////////////////////////////////////////////////////////////////////////////
output wire [1*TxPortCount-1:0]	            Sink_TRDY,
input  wire [1*TxPortCount-1:0]	            Sink_TVALID,
input  wire [1*TxPortCount-1:0]	            Sink_TLAST,
input  wire [8*TxPortCount-1:0]             Sink_TDATA,

input  wire 	                            Source_PHY_TX_CLK,	
input  wire                                 Source_PHY_TX_TRDY,
output wire                                 Source_PHY_TX_TVALID,
output wire                                 Source_PHY_TX_TLAST,
output wire [8-1:0]                         Source_PHY_TX_TDATA
);

wire            wNetworkLayerCore_TLAST;
wire            wNetworkLayerCore_TVALID;
wire            wNetworkLayerCore_TERROR;
wire [ 8-1:0]   wNetworkLayerCore_TDATA;

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
AXISx8_Network_Layer_Core
#(
.TxPortCount    (TxPortCount),
.Has_ARP_Proc   (Has_ARP_Proc),
.HasICMP_PING   (HasICMP_PING)
) AXISx8_Network_Layer_Core_inst
(
/////////////////////////////////////////////////////////////////////////////////////
// Rx Interface                                                                   ///
/////////////////////////////////////////////////////////////////////////////////////
    .Sink_PHY_RX_CLK                       (Sink_PHY_RX_CLK                         ),
    .Sink_PHY_RX_TLAST                     (Sink_PHY_RX_TLAST                       ),
    .Sink_PHY_RX_TVALID                    (Sink_PHY_RX_TVALID                      ),
    .Sink_PHY_RX_TERROR                    (Sink_PHY_RX_TERROR                      ),
    .Sink_PHY_RX_TDATA                     (Sink_PHY_RX_TDATA                       ),

    .Source_TVALID                         (wNetworkLayerCore_TVALID                ),
    .Source_TERROR                         (wNetworkLayerCore_TERROR                ),
    .Source_TLAST                          (wNetworkLayerCore_TLAST                 ),
    .Source_TDATA                          (wNetworkLayerCore_TDATA                 ),

    .IP4_Used_Protocol_OUT                 (wNetwork_Layer_IP4_Used_Protocol        ),
    .IP4_LOCAL_ADDR_IN                     ( IP4_LOCAL_ADDR_IN                      ),	
    .IP4_REMOTE_ADDR_OUT                   (wIP4_REMOTE_ADDR                        ),
    .MAC_LOCAL_ADDR_IN                     ( MAC_LOCAL_ADDR_IN                      ),
    .MAC_REMOTE_ADDR_OUT                   (wDataLinkLayer_Remote_MAC_ADDR          ),
/////////////////////////////////////////////////////////////////////////////////////
//  Tx Interface                                                                  ///
/////////////////////////////////////////////////////////////////////////////////////
    .Sink_TRDY                             (Sink_TRDY                               ),
    .Sink_TVALID                           (Sink_TVALID                             ),
    .Sink_TLAST                            (Sink_TLAST                              ),
    .Sink_TDATA                            (Sink_TDATA                              ),
    
    .Source_PHY_TX_CLK                     (Source_PHY_TX_CLK                       ),
    .Source_PHY_TX_TRDY                    (Source_PHY_TX_TRDY                      ),
    .Source_PHY_TX_TVALID                  (Source_PHY_TX_TVALID                    ),
    .Source_PHY_TX_TLAST                   (Source_PHY_TX_TLAST                     ),
    .Source_PHY_TX_TDATA                   (Source_PHY_TX_TDATA                     )
 );
 
/////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------//
//      Transport Layer. Rx UDP datagrams processing IP core.                      //
//---------------------------------------------------------------------------------//
//      This module checks port, datagram size and checksum.                       //
//---------------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////   
genvar i;
generate
for (i = 0; i < NumberOf_RX_UDP_Ports; i = i+1)  
begin : UDP_RX

(* KEEP_HIERARCHY = "TRUE" *)
UDP_RxDatagramProcessing_Core_x8           UDP_RxDatagramProcessing_Core_x8_inst
(
	.CLK                                   (Sink_PHY_RX_CLK                        ),
	
	.UDP_Core_Sink_TVALID                  (wNetworkLayerCore_TVALID               ),
	.UDP_Core_Sink_TERROR                  (wNetworkLayerCore_TERROR               ),
	.UDP_Core_Sink_TLAST                   (wNetworkLayerCore_TLAST                ),
	.UDP_Core_Sink_TDATA                   (wNetworkLayerCore_TDATA                ),
	

    .IP4_Used_Protocol_IN                  (wNetwork_Layer_IP4_Used_Protocol       ),
	.IP4_LOCAL_ADDR_IN                     ( IP4_LOCAL_ADDR_IN                     ),
	.IP4_REMOTE_ADDR_IN                    (wIP4_REMOTE_ADDR                       ),
	.MAC_REMOTE_ADDR_IN                    (wDataLinkLayer_Remote_MAC_ADDR         ),
	.UDP_LOCAL_PORT_IN                     (UDP_LOCAL_PORT_IN[16*i+:16]            ),	
	
	.UDP_REMOTE_PORT_OUT                   ( UDP_REMOTE_PORT_OUT[16*i+:16]         ),
	.IP4_REMOTE_ADDR_OUT                   ( IP4_REMOTE_ADDR_OUT[32*i+:32]         ),
	.MAC_REMOTE_ADDR_OUT                   ( MAC_REMOTE_ADDR_OUT[48*i+:48]         ),
    	
	.UDP_Core_Source_TFIRST                (Source_TFIRST[1*i+:1]                  ),
	.UDP_Core_Source_TVALID                (Source_TVALID[1*i+:1]                  ),
	.UDP_Core_Source_TERROR                (Source_TERROR[1*i+:1]                  ),
	.UDP_Core_Source_TLAST                 (Source_TLAST [1*i+:1]                  ),
	.UDP_Core_Source_TDATA                 (Source_TDATA [8*i+:8]                  )
);

end
endgenerate
 
endmodule