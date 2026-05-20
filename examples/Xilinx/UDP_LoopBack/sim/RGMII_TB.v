`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.05.2026 11:43:21
// Design Name: 
// Module Name: RGMII_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RGMII_TB(

    );
    
    
reg         CLK125Mhz=1;      // RX clock (125 MHz)

localparam EthPackSize =64;

always #4.0  CLK125Mhz   = ~ CLK125Mhz;

wire DATA_TRDY;
reg  DATA_TVALID=0;
reg  DATA_TLAST=0;
reg  [ 3:0]DATA_TKEEP=1;
reg  [31:0]DATA_TDATA=15;

reg  [15:0]DATA_TDATA_Counter=0;
localparam StartValue  = 16;
localparam LenghValue = 1; //16
localparam GapValue = 256;

    always @(posedge CLK125Mhz)
    begin
    if (DATA_TRDY)
        begin
        if (DATA_TDATA_Counter == (StartValue + LenghValue - 1 + GapValue )) DATA_TDATA_Counter <=StartValue;
            else DATA_TDATA_Counter <= DATA_TDATA_Counter+1;
        DATA_TVALID <= (DATA_TDATA_Counter>=StartValue) && (DATA_TDATA_Counter<=(StartValue + LenghValue - 1 ));
        DATA_TLAST  <= (DATA_TDATA_Counter==(StartValue + LenghValue - 1 ));
        
        DATA_TDATA <= DATA_TDATA_Counter - StartValue +1 + 32'h55AA0000;
        end 
    end
   
    
(* KEEP_HIERARCHY = "TRUE" *)
AXISx8_UDP_Framing_AXISx32_Sink    
#(
    .ARCH     ( "XLX_ULTRASCALE" ),
    .DROP_IF_OVERFLOW   ( "YES"  ), // "YES" or "NO"
    .ETHERNET_MTU       ( 1500   ),
    .PADDING_INSERTION  ( "YES"  ),
    .BUFFER_COUNT_1K    ( 4      )  
) 
AXISx8_UDP_Framing_AXISx32_Sink_inst
(      
. Sink_CLK              (CLK125Mhz                  ),
. Sink_TRDY             (DATA_TRDY                  ),
. Sink_TVALID           (DATA_TVALID                ),
. Sink_TLAST            (DATA_TLAST                 ),
. Sink_TKEEP            (DATA_TKEEP                 ),
. Sink_TDATA            (DATA_TDATA                 ),
 
. UDP_LOCAL_PORT_IN     (16'h1234                   ),
. UDP_REMOTE_PORT_IN    (16'h5678                   ),
  
. IP4_LOCAL_ADDR_IN     (32'hFF112233               ),
. IP4_REMOTE_ADDR_IN    (32'hEEAABBCC               ),

. MAC_LOCAL_ADDR_IN     (48'h887777777777           ),  
. MAC_REMOTE_ADDR_IN    (48'h443333333333           ),

. Source_CLK            (CLK125Mhz                  ),    
. Source_TRDY           (1                          ),
. Source_TVALID         (                           ),
. Source_TLAST          (                           ),
. Source_TDATA          (                           )       
);    
endmodule
