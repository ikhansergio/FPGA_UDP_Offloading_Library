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

module DataBuffer_DistRAM_512_x36
#(parameter ARCH = "XLX_ULTRASCALE")
(
input  wire          WrClk       ,
input  wire          WrEna       ,
input  wire [ 0:0]   WrWea       ,
input  wire [ 6:0]   WrAddress   ,
input  wire [35:0]   WrData      ,

input  wire          RdClk       ,
input  wire          RdEna       ,
input  wire [ 6:0]   RdAddress   ,
output wire [35:0]   RdData     

);

generate

    if (ARCH == "XLX_SERIES7")
    begin
        (* KEEP_HIERARCHY = "TRUE" *)
		
		XLX_x36_512_DIST XLX_x36_512_DIST_inst (
		.a						(WrAddress		),  // input wire [6 : 0] a
		.d						(WrData			),  // input wire [35 : 0] d
		.dpra					(RdAddress		),  // input wire [6 : 0] dpra
		.clk					(WrClk			),  // input wire clk
		.we						(WrWea			),  // input wire we
		.i_ce					(WrEna			),  // input wire i_ce
		.qdpo_ce				(RdEna			),  // input wire qdpo_ce
		.qdpo_clk				(RdClk			),  // input wire qdpo_clk
		.qdpo					(RdData			)   // output wire [35 : 0] qdpo
		);

    end else if (ARCH == "XLX_ULTRASCALE")
        begin
        (* KEEP_HIERARCHY = "TRUE" *)
		XLX_x36_512_DIST XLX_x36_512_DIST_inst (
		.a						(WrAddress		),  // input wire [6 : 0] a
		.d						(WrData			),  // input wire [35 : 0] d
		.dpra					(RdAddress		),  // input wire [6 : 0] dpra
		.clk					(WrClk			),  // input wire clk
		.we						(WrWea			),  // input wire we
		.i_ce					(WrEna			),  // input wire i_ce
		.qdpo_ce				(RdEna			),  // input wire qdpo_ce
		.qdpo_clk				(RdClk			),  // input wire qdpo_clk
		.qdpo					(RdData			)   // output wire [35 : 0] qdpo
		);
    end else  // if (ARCH == "DEFAULT_LOGIC")
    begin
        (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_Fabric_REG_x36   
    #(
    . RAM_DEPTH ( 128 )
    )DataBuffer_Fabric_REG_x36_inst
    (
    .WrClk              (WrClk),
    .WrEna              (WrEna),
    .WrWea              (WrWea),
    .WrAddress          (WrAddress),
    .WrData             (WrData),

    .RdClk              (RdClk),
    .RdEna              (RdEna),
    .RdAddress          (RdAddress),
    .RdData             (RdData)   
    );
    end

endgenerate

endmodule