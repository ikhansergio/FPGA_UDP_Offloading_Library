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

module AXISx8_UDP_TG_Controller
#(
    parameter COMAND_CODE = 8'h01
) 
(
    input                           CLK ,
    
    input [32-1:0]                  TDATA ,
    input                           TVALID,
    input                           TFIRST,
    input                           TLAST,
    input                           TERROR,
    input [16-1:0]                  POSITION,
    input [ 8-1:0]                  CommandCode,
    
    output  reg                     TG_Start_Pulse=0,
    output  reg [32-1:0]            TG_PacketCount=0,
    output  reg [16-1:0]            TG_PacketSize=0, 
    output  reg [16-1:0]            TG_PacketGap=0     
                 
);


(* keep = "true" *) reg CommandCodeFlag =0;

(* keep = "true" *) reg [15:0]PacketSize=0;
(* keep = "true" *) reg [15:0]PacketGap=0;
(* keep = "true" *) reg [31:0]PacketCount=0;

always @(posedge CLK)
begin

if (TVALID && (POSITION == 0) )  CommandCodeFlag        <= ( CommandCode == COMAND_CODE );

if (TVALID && (POSITION == 1) )  {PacketGap,PacketSize} <= TDATA[31:0];
if (TVALID && (POSITION == 2) )  PacketCount            <= TDATA[31:0];

TG_Start_Pulse <= CommandCodeFlag&&TLAST&&TVALID&&!TERROR;

if (CommandCodeFlag&&TLAST&&TVALID&&!TERROR)
    begin
    TG_PacketSize  <= PacketSize;
    TG_PacketCount <= PacketCount;
    TG_PacketGap   <= PacketGap;
    end
end


endmodule

