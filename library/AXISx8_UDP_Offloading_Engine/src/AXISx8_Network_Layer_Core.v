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

module AXISx8_Network_Layer_Core
#(
    parameter TxPortCount = 2     ,    //  Number of UDP Tx Masters + ARP
    parameter Has_ARP_Proc = "YES",
    parameter HasICMP_PING = "YES"
)
(
/////////////////////////////////////////////////////////////////////////////////////
// Rx Interface                                                                   ///
/////////////////////////////////////////////////////////////////////////////////////
input wire 	                          Sink_PHY_RX_CLK              ,
input wire 	                          Sink_PHY_RX_TVALID           ,
input wire 	                          Sink_PHY_RX_TERROR           ,
input wire 	                          Sink_PHY_RX_TLAST            ,
input wire [ 8-1:0]                   Sink_PHY_RX_TDATA            ,

output wire			                  Source_TVALID                ,
output wire			                  Source_TERROR                ,
output wire			                  Source_TLAST                 ,
output wire [ 8-1:0]                  Source_TDATA                 ,
	
/////////////////////////////////////////////////////////////////////////////////////
//  Tx Interface                                                                  ///
/////////////////////////////////////////////////////////////////////////////////////

input  wire 	                      Source_PHY_TX_CLK      ,	
input  wire                           Source_PHY_TX_TRDY     ,
output wire                           Source_PHY_TX_TVALID   ,
output wire                           Source_PHY_TX_TERROR   ,
output wire                           Source_PHY_TX_TLAST    ,
output wire [8-1:0]                   Source_PHY_TX_TDATA    ,

output wire [1*TxPortCount-1:0]	      Sink_TRDY   ,
input  wire [1*TxPortCount-1:0]	      Sink_TVALID ,
input  wire [1*TxPortCount-1:0]	      Sink_TERROR ,
input  wire [1*TxPortCount-1:0]	      Sink_TLAST  ,
input  wire [8*TxPortCount-1:0]       Sink_TDATA  ,

/////////////////////////////////////////////////////////////////////////////////////
//  MACs,IPv4s,Ports                                                              ///
/////////////////////////////////////////////////////////////////////////////////////

input  wire [48-1:0]   MAC_LOCAL_ADDR_IN        ,
input  wire [32-1:0]   IP4_LOCAL_ADDR_IN        ,

output wire [48-1:0]   MAC_REMOTE_ADDR_OUT      ,
output wire [32-1:0]   IP4_REMOTE_ADDR_OUT      ,
output wire [ 8-1:0]   IP4_Used_Protocol_OUT    
);

wire            wARP_Core_TRDY ;
wire            wARP_Core_TVALID;
wire            wARP_Core_TERROR;
wire            wARP_Core_TLAST;
wire [8-1:0]    wARP_Core_TDATA;

wire            wICMP_PING_Core_TRDY ;
wire            wICMP_PING_Core_TVALID;
wire            wICMP_PING_Core_TERROR;
wire            wICMP_PING_Core_TLAST;
wire [8-1:0]    wICMP_PING_Core_TDATA;


wire            wEthernet_II_Frame_TVALID;
wire            wEthernet_II_Frame_TLAST;
wire            wEthernet_II_Frame_TERROR;
wire [ 8-1 :0]  wEthernet_II_Frame_TDATA;
wire [16-1:0]   wMAC_Eth_II_TypeCode;
wire [48-1:0]   wMAC_REMOTE_ADDR;



(*KEEP_HIERARCHY = "TRUE"*)
AXISx8_Ethernet_II_MAC_Core  
#(
.TxPortCount(TxPortCount+2)
) AXISx8_Ethernet_II_MAC_Core_inst
(
/////////////////////////////////////////////////////////////////////////////////////
// MAC Rx Interface                                                               ///
/////////////////////////////////////////////////////////////////////////////////////
.RX_CLK                             (Sink_PHY_RX_CLK            ),
.RX_TLAST                           (Sink_PHY_RX_TLAST          ),
.RX_TVALID                          (Sink_PHY_RX_TVALID         ),
.RX_TERROR                          (Sink_PHY_RX_TERROR         ),
.RX_TDATA                           (Sink_PHY_RX_TDATA          ),

.Source_TVALID                      (wEthernet_II_Frame_TVALID  ),
.Source_TERROR                      (wEthernet_II_Frame_TERROR  ),
.Source_TLAST                       (wEthernet_II_Frame_TLAST   ),
.Source_TDATA                       (wEthernet_II_Frame_TDATA   ),
.MAC_Eth_II_TypeCode                (wMAC_Eth_II_TypeCode       ),
.MAC_LOCAL_ADDR_IN                  ( MAC_LOCAL_ADDR_IN         ),
.MAC_REMOTE_ADDR_OUT                (wMAC_REMOTE_ADDR           ),
/////////////////////////////////////////////////////////////////////////////////////
// MAC Tx Interface                                                               ///
/////////////////////////////////////////////////////////////////////////////////////
.TX_CLK                   (Source_PHY_TX_CLK        ),
.Sink_TRDY                ({Sink_TRDY   ,wARP_Core_TRDY  ,wICMP_PING_Core_TRDY  } ),
.Sink_TVALID              ({Sink_TVALID ,wARP_Core_TVALID,wICMP_PING_Core_TVALID} ),
.Sink_TERROR              ({Sink_TERROR ,wARP_Core_TERROR,wICMP_PING_Core_TERROR} ),
.Sink_TLAST               ({Sink_TLAST  ,wARP_Core_TLAST ,wICMP_PING_Core_TLAST } ),
.Sink_TDATA               ({Sink_TDATA  ,wARP_Core_TDATA ,wICMP_PING_Core_TDATA } ),

.TX_TRDY                  (Source_PHY_TX_TRDY       ),
.TX_TVALID                (Source_PHY_TX_TVALID     ),
.TX_TERROR                (Source_PHY_TX_TERROR     ),
.TX_TLAST                 (Source_PHY_TX_TLAST      ),
.TX_TDATA                 (Source_PHY_TX_TDATA      )
);

/////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------//
//      Network Layer. Rx IPv4 packets processing IP core.                         //
//---------------------------------------------------------------------------------//
//      Check IP address, packet size, padding and checksum.                       //
//---------------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////
(*KEEP_HIERARCHY = "TRUE"*)
IPv4_Core_x8                        IPv4_Core_x8_inst
(
.CLK                                (Sink_PHY_RX_CLK            ),
.IPv4_Core_Sink_TVALID              (wEthernet_II_Frame_TVALID  ),
.IPv4_Core_Sink_TERROR              (wEthernet_II_Frame_TERROR  ),
.IPv4_Core_Sink_TLAST               (wEthernet_II_Frame_TLAST   ),
.IPv4_Core_Sink_TDATA               (wEthernet_II_Frame_TDATA   ),

.Ethernet_TypeCode                  (wMAC_Eth_II_TypeCode       ),
.IP4_Used_Protocol                  ( IP4_Used_Protocol_OUT     ),
.Internal_IP4_ADDR                  ( IP4_LOCAL_ADDR_IN         ),
.External_MAC_ADDR_IN               (wMAC_REMOTE_ADDR           ),
.External_MAC_ADDR_OUT              (MAC_REMOTE_ADDR_OUT        ),
.External_IP4_ADDR                  ( IP4_REMOTE_ADDR_OUT       ),

.IPv4_Core_Source_TFIRST             (),
.IPv4_Core_Source_TVALID            (Source_TVALID              ),
.IPv4_Core_Source_TERROR            (Source_TERROR              ),
.IPv4_Core_Source_TLAST             (Source_TLAST               ),
.IPv4_Core_Source_TDATA             (Source_TDATA               )
);
generate
if (Has_ARP_Proc == "YES") 
begin
    (*KEEP_HIERARCHY = "TRUE"*)
    ARP_Offloading_Engine_x8            ARP_Offloading_Engine_x8_inst
    (
    /////////////////////////////////////////////////////////////////////////////////////
    // ARP Rx Interface                                                               ///
    /////////////////////////////////////////////////////////////////////////////////////
    .Sink_CLK                           (Sink_PHY_RX_CLK            ),
    .Sink_TVALID                        (wEthernet_II_Frame_TVALID  ),
    .Sink_TERROR                        (wEthernet_II_Frame_TERROR  ),
    .Sink_TLAST                         (wEthernet_II_Frame_TLAST   ),
    .Sink_TDATA                         (wEthernet_II_Frame_TDATA   ),
	
    .Ethernet_TypeCode                  (wMAC_Eth_II_TypeCode       ),
    .MAC_LOCAL_ADDR_IN                  ( MAC_LOCAL_ADDR_IN         ),
    .MAC_REMOTE_ADDR_IN                 (wMAC_REMOTE_ADDR           ),
    .IP4_LOCAL_ADDR_IN                  ( IP4_LOCAL_ADDR_IN         ),
    /////////////////////////////////////////////////////////////////////////////////////
    // ARP Tx Interface                                                               ///
    /////////////////////////////////////////////////////////////////////////////////////
    .Source_CLK                         (Source_PHY_TX_CLK          ),
    .Source_TRDY                        (wARP_Core_TRDY             ),
    .Source_TERROR                      (wARP_Core_TERROR           ),
    .Source_TVALID                      (wARP_Core_TVALID           ),
    .Source_TLAST                       (wARP_Core_TLAST            ),
    .Source_TDATA                       (wARP_Core_TDATA            )
    );
end
else 
begin
    assign wARP_Core_TVALID =0;
    assign wARP_Core_TERROR =0;
    assign wARP_Core_TLAST  =0;
    assign wARP_Core_TDATA  =0;
end

endgenerate

/////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------//
//      Network Layer. PING offloading engine                                      //
//---------------------------------------------------------------------------------//
//                                                                                 //
//---------------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////

generate

if (HasICMP_PING == "YES") 
begin
    (*KEEP_HIERARCHY = "TRUE"*)
    ICMP_PING_Offloading_Engine_x8  ICMP_PING_Offloading_Engine_x8_inst
    (
    .Sink_CLK                   (Sink_PHY_RX_CLK                    ),
    .Sink_TVALID                (Source_TVALID                      ),
    .Sink_TERROR                (Source_TERROR                      ),
    .Sink_TLAST                 (Source_TLAST                       ),
    .Sink_TDATA                 (Source_TDATA                       ),
	
    .IP4_Used_Protocol_IN       (IP4_Used_Protocol_OUT              ),
	
    .MAC_LOCAL_ADDR_IN          (MAC_LOCAL_ADDR_IN                  ),
    .MAC_REMOTE_ADDR_IN         (MAC_REMOTE_ADDR_OUT                ),
    .IP4_LOCAL_ADDR_IN          (IP4_LOCAL_ADDR_IN                  ),
    .IP4_REMOTE_ADDR_IN         (IP4_REMOTE_ADDR_OUT                ),

    .Source_CLK                 (Source_PHY_TX_CLK                  ),
    .Source_TRDY                (wICMP_PING_Core_TRDY               ),
    .Source_TVALID              (wICMP_PING_Core_TVALID             ),
    .Source_TERROR              (wICMP_PING_Core_TERROR             ),
    .Source_TLAST               (wICMP_PING_Core_TLAST              ),
    .Source_TDATA               (wICMP_PING_Core_TDATA              )
    );
end
else 
begin
    assign wICMP_PING_Core_TVALID =0;
    assign wICMP_PING_Core_TERROR =0;
    assign wICMP_PING_Core_TLAST  =0;
    assign wICMP_PING_Core_TDATA  =0;
end

endgenerate

endmodule
