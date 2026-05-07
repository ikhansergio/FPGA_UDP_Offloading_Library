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

module NetworkLayerCore_x8
#(
    parameter TxPortCount = 2    //  Number of UDP Tx Masters + ARP
)
(
/////////////////////////////////////////////////////////////////////////////////////
// Rx Interface                                                                   ///
/////////////////////////////////////////////////////////////////////////////////////
input wire 	           RX_CLK,
input wire 	           RX_TVALID,
input wire 	           RX_TERROR,
input wire 	           RX_TLAST,
input wire [ 8-1:0]    RX_TDATA,

output wire			   IPv4_Core_Source_TVALID,
output wire			   IPv4_Core_Source_TERROR,
output wire			   IPv4_Core_Source_TLAST,
output wire [ 8-1:0]   IPv4_Core_Source_TDATA,
	
input  wire [48-1:0]   MAC_LOCAL_ADDR_IN ,
input  wire [32-1:0]   IP4_LOCAL_ADDR_IN,

output wire [48-1:0]   MAC_REMOTE_ADDR_OUT ,
output wire [32-1:0]   IP4_REMOTE_ADDR_OUT,
output wire [ 8-1:0]   IP4_Used_Protocol_OUT,	

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

wire            wARP_Core_TRDY ;
wire            wARP_Core_TVALID;
wire            wARP_Core_TLAST;
wire [8-1:0]    wARP_Core_TDATA;

wire            wICMP_PING_Core_TRDY ;
wire            wICMP_PING_Core_TVALID;
wire            wICMP_PING_Core_TLAST;
wire [8-1:0]    wICMP_PING_Core_TDATA;


wire            wEthernet_II_Frame_TVALID;
wire            wEthernet_II_Frame_TLAST;
wire            wEthernet_II_Frame_TERROR;
wire [ 8-1 :0]  wEthernet_II_Frame_TDATA;
wire [16-1:0]   wEthernet_TypeCode;
wire [48-1:0]   wExternal_MAC_ADDR;



(* KEEP_HIERARCHY = "TRUE" *)
Ethernet_II_MAC_Core_x8  #(.TxPortCount(TxPortCount+2)) Ethernet_II_MAC_Core_x8_inst(
/////////////////////////////////////////////////////////////////////////////////////
// MAC Rx Interface                                                               ///
/////////////////////////////////////////////////////////////////////////////////////
.RX_CLK                                                (RX_CLK                     ),
.RX_TLAST                                              (RX_TLAST                   ),
.RX_TVALID                                             (RX_TVALID                  ),
.RX_TERROR                                             (RX_TERROR                  ),
.RX_TDATA                                              (RX_TDATA                   ),

.Ethernet_II_Frame_TVALID                              (wEthernet_II_Frame_TVALID  ),
.Ethernet_II_Frame_TERROR                              (wEthernet_II_Frame_TERROR  ),
.Ethernet_II_Frame_TLAST                               (wEthernet_II_Frame_TLAST   ),
.Ethernet_II_Frame_TDATA                               (wEthernet_II_Frame_TDATA   ),
.Ethernet_II_TypeCode                                  (wEthernet_TypeCode         ),
.Ethernet_II_Internal_MAC                              ( MAC_LOCAL_ADDR_IN         ),
.Ethernet_II_External_MAC                              (wExternal_MAC_ADDR         ),
/////////////////////////////////////////////////////////////////////////////////////
// MAC Tx Interface                                                               ///
/////////////////////////////////////////////////////////////////////////////////////
.TX_CLK                                                (TX_CLK),
.MAC_FrameBody_TRDY                                    ({MAC_TxFrameBody_TRDY   ,wARP_Core_TRDY  ,wICMP_PING_Core_TRDY  } ),
.MAC_FrameBody_TVALID                                  ({MAC_TxFrameBody_TVALID ,wARP_Core_TVALID,wICMP_PING_Core_TVALID} ),
.MAC_FrameBody_TLAST                                   ({MAC_TxFrameBody_TLAST  ,wARP_Core_TLAST ,wICMP_PING_Core_TLAST } ),
.MAC_FrameBody_TDATA                                   ({MAC_TxFrameBody_TDATA  ,wARP_Core_TDATA ,wICMP_PING_Core_TDATA } ),

.TX_TRDY                                               (TX_TRDY),
.TX_TVALID                                             (TX_TVALID),
.TX_TLAST                                              (TX_TLAST),
.TX_TDATA                                              (TX_TDATA)
);

(* KEEP_HIERARCHY = "TRUE" *)
ARP_Offloading_Engine_x8            ARP_Offloading_Engine_x8_inst
(
/////////////////////////////////////////////////////////////////////////////////////
// ARP Rx Interface                                                               ///
/////////////////////////////////////////////////////////////////////////////////////
.RX_CLK                             (RX_CLK                     ),
.RX_TVALID                          (wEthernet_II_Frame_TVALID  ),
.RX_TERROR                          (wEthernet_II_Frame_TERROR  ),
.RX_TLAST                           (wEthernet_II_Frame_TLAST   ),
.RX_TDATA                           (wEthernet_II_Frame_TDATA   ),
	
.Ethernet_TypeCode                  (wEthernet_TypeCode         ),
.Internal_MAC_ADDR                  ( MAC_LOCAL_ADDR_IN         ),
.External_MAC_ADDR                  (wExternal_MAC_ADDR         ),
.Internal_IP4_ADDR                  ( IP4_LOCAL_ADDR_IN         ),
/////////////////////////////////////////////////////////////////////////////////////
// ARP Tx Interface                                                               ///
/////////////////////////////////////////////////////////////////////////////////////
.TX_CLK                             (TX_CLK),
.TX_TRDY                            (wARP_Core_TRDY             ),
.TX_TVALID                          (wARP_Core_TVALID           ),
.TX_TLAST                           (wARP_Core_TLAST            ),
.TX_TDATA                           (wARP_Core_TDATA            )
);

/////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------//
//      Network Layer. Rx IPv4 packets processing IP core.                         //
//---------------------------------------------------------------------------------//
//      Check IP address, packet size, padding and checksum.                       //
//---------------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////
(* KEEP_HIERARCHY = "TRUE" *)
IPv4_Core_x8                        IPv4_Core_x8_inst
(
.CLK                                (RX_CLK                     ),
.IPv4_Core_Sink_TVALID              (wEthernet_II_Frame_TVALID  ),
.IPv4_Core_Sink_TERROR              (wEthernet_II_Frame_TERROR  ),
.IPv4_Core_Sink_TLAST               (wEthernet_II_Frame_TLAST   ),
.IPv4_Core_Sink_TDATA               (wEthernet_II_Frame_TDATA   ),

.Ethernet_TypeCode                  (wEthernet_TypeCode         ),
.IP4_Used_Protocol                  ( IP4_Used_Protocol_OUT     ),
.Internal_IP4_ADDR                  ( IP4_LOCAL_ADDR_IN         ),
.External_MAC_ADDR_IN               (wExternal_MAC_ADDR         ),
.External_MAC_ADDR_OUT              (MAC_REMOTE_ADDR_OUT        ),
.External_IP4_ADDR                  ( IP4_REMOTE_ADDR_OUT       ),

.IPv4_Core_Source_TFIRST             (),
.IPv4_Core_Source_TVALID            (IPv4_Core_Source_TVALID    ),
.IPv4_Core_Source_TERROR            (IPv4_Core_Source_TERROR    ),
.IPv4_Core_Source_TLAST             (IPv4_Core_Source_TLAST     ),
.IPv4_Core_Source_TDATA             (IPv4_Core_Source_TDATA     )
);

/////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------//
//      Network Layer. PING offloading engine                                      //
//---------------------------------------------------------------------------------//
//                                                                                 //
//---------------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////
(* KEEP_HIERARCHY = "TRUE" *)
ICMP_PING_Offloading_Engine_x8  ICMP_PING_Offloading_Engine_x8_inst
(
.ICMP_PING_Sink_CLK         (RX_CLK                             ),
.ICMP_PING_Sink_TVALID      (IPv4_Core_Source_TVALID            ),
.ICMP_PING_Sink_TERROR      (IPv4_Core_Source_TERROR            ),
.ICMP_PING_Sink_TLAST       (IPv4_Core_Source_TLAST             ),
.ICMP_PING_Sink_TDATA       (IPv4_Core_Source_TDATA             ),
	
.IP4_Used_Protocol_IN       (IP4_Used_Protocol_OUT              ),
	
.MAC_LOCAL_ADDR_IN          (MAC_LOCAL_ADDR_IN                  ),
.MAC_REMOTE_ADDR_IN         (MAC_REMOTE_ADDR_OUT                ),
.IP4_LOCAL_ADDR_IN          (IP4_LOCAL_ADDR_IN                  ),
.IP4_REMOTE_ADDR_IN         (IP4_REMOTE_ADDR_OUT                ),

.ICMP_PING_Source_CLK       (TX_CLK                             ),
.ICMP_PING_Source_TRDY      (wICMP_PING_Core_TRDY               ),
.ICMP_PING_Source_TVALID    (wICMP_PING_Core_TVALID             ),
.ICMP_PING_Source_TLAST     (wICMP_PING_Core_TLAST              ),
.ICMP_PING_Source_TDATA     (wICMP_PING_Core_TDATA              )
);

endmodule
