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

module UDP_CheckSumCalc
(
input  wire          CLK,
input  wire [ 1-1:0] TFIRST,
input  wire [ 1-1:0] TVALID,
input  wire [32-1:0] TDATA,
input  wire [16-1:0] IP4_DataLength_IN,
input  wire [32-1:0] IP4_LOCAL_ADDR_IN,
input  wire [32-1:0] IP4_REMOTE_ADDR_IN,
output wire [16-1:0] CheckSUM_UDP
);

(* keep = "true" *) reg [18-1:0] UDP_CheckSUM_IP4_SUM               =0;
(* keep = "true" *) reg [20-1:0] UDP_CheckSUM_IP4_PseudoHeader      =0;
(* keep = "true" *) reg [32-1:0] UDP_CheckSUM_FULL                  =0;


(* KEEP = "TRUE" *)wire [32-1:0]wUDP_CheckSUM_Data;
 (* KEEP_HIERARCHY = "TRUE" *)
 AXIS32_PayloadCheckSum AXIS32_PayloadCheckSum_inst
(
.CLK                    (CLK   ),
.TFIRST                 (TFIRST),
.TVALID                 (TVALID),
.TDATA                  (TDATA),
.CheckSUM               (wUDP_CheckSUM_Data)
);

always @(posedge CLK) 
begin
    UDP_CheckSUM_IP4_SUM            <=  {2'b00,IP4_LOCAL_ADDR_IN  [16-1: 0]   }   +   {2'b00,IP4_LOCAL_ADDR_IN  [32-1:16]} 
                                            + {2'b00,IP4_REMOTE_ADDR_IN  [16-1: 0]  }   +   {2'b00,IP4_REMOTE_ADDR_IN  [32-1:16]};
	UDP_CheckSUM_IP4_PseudoHeader   <=  {2'b0,UDP_CheckSUM_IP4_SUM      }   +   { 4'b0, IP4_DataLength_IN}  + 20'd17;

    UDP_CheckSUM_FULL               <=  wUDP_CheckSUM_Data                   +   {12'b0, UDP_CheckSUM_IP4_PseudoHeader }; 	
    
    //CheckSUM                        <=  wUDP_CheckSUM_Data                   +   {12'b0, UDP_CheckSUM_IP4_PseudoHeader }; 
end

assign CheckSUM_UDP = ~(UDP_CheckSUM_FULL[16-1: 0] + UDP_CheckSUM_FULL[32-1:16]) ;

endmodule

