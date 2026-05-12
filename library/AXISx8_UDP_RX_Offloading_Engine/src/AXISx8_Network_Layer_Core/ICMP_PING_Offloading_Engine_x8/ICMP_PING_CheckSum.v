`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.05.2026 13:27:21
// Design Name: 
// Module Name: ICMP_PING_CheckSum
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

module ICMP_PING_CheckSum
(
input wire            CLK,
input wire   [ 1-1:0] TFIRST,
input wire   [ 1-1:0] TVALID,
input wire   [32-1:0] TDATA,
output reg   [32-1:0] CheckSUM=0
);

(* KEEP = "TRUE" *)reg  [17-1:0] ICMP_PING_CheckSUM_Sub =0;
(* KEEP = "TRUE" *)wire [32-1:0]wICMP_PING_CheckSUM_FullPacket;
 (* KEEP_HIERARCHY = "TRUE" *)
 AXIS32_PayloadCheckSum AXIS32_PayloadCheckSum_inst
(
.CLK                    (CLK   ),
.TFIRST                 (TFIRST),
.TVALID                 (TVALID),
.TDATA                  (TDATA),
.CheckSUM               (wICMP_PING_CheckSUM_FullPacket)
);

always @(posedge CLK) 
begin
if (TVALID && TFIRST) ICMP_PING_CheckSUM_Sub <= TDATA[32-1:16] + TDATA[16-1:0 ];
CheckSUM<= wICMP_PING_CheckSUM_FullPacket - ICMP_PING_CheckSUM_Sub;
end

endmodule
