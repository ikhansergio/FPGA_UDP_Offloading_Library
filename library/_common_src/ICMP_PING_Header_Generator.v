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

module ICMP_PING_IPv4_Header_Generator_x8
(
input  wire              CLK,

input  wire              ICMP_PING_TRY,

input  wire [ 6-1:0]     ICMP_PING_Position,

input  wire [32-1:0]     ICMP_PING_CheckSUM_Reply,
input  wire [16-1:0]     ICMP_PING_Identifier,
input  wire [16-1:0]     ICMP_PING_Sequence_Number,

output reg  [ 8-1:0]     ICMP_PING_Header =0 
);

(* KEEP = "TRUE" *)reg [16-1:0] ICMP_CheckSUM_CalkRes=0;

always @(posedge CLK)
begin

ICMP_CheckSUM_CalkRes <= ~(ICMP_PING_CheckSUM_Reply[32-1:16] +  ICMP_PING_CheckSUM_Reply[16-1: 0]);

if (ICMP_PING_Position==7'd34) ICMP_PING_Header<=8'b0;                                                        // Source Port High
    else if (ICMP_PING_Position==7'd35) ICMP_PING_Header<=8'b0;                                                // Source Port Low
        else if (ICMP_PING_Position==7'd36) ICMP_PING_Header<=ICMP_CheckSUM_CalkRes[15:8];                                             // Destination Port High
	       else if (ICMP_PING_Position==7'd37) ICMP_PING_Header<=ICMP_CheckSUM_CalkRes[ 7:0];                                         // Destination Port Low
	           else if (ICMP_PING_Position==7'd38) ICMP_PING_Header<=ICMP_PING_Identifier[15:8];                                      // Length High
	               else if (ICMP_PING_Position==7'd39) ICMP_PING_Header<=ICMP_PING_Identifier[ 7:0];                                  // Length Low
	                   else if (ICMP_PING_Position==7'd40) ICMP_PING_Header<=ICMP_PING_Sequence_Number[15:8];                                  // Checksum High
	                       else if (ICMP_PING_Position==7'd41) ICMP_PING_Header<=ICMP_PING_Sequence_Number[ 7:0];                              // Checksum Low
	                           else ICMP_PING_Header<=0;                    
end 
                                     
endmodule
