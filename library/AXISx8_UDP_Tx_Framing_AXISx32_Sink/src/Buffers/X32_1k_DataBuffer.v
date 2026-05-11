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


module X32_1k_DataBuffer
#(parameter ARCH = "XLX_ULTRASCALE")
(
input  wire          WrClk       ,
input  wire          WrEna       ,
input  wire [ 3:0]   WrWea       ,
input  wire [ 7:0]   WrAddress   ,
input  wire [31:0]   WrData      ,

input  wire          RdClk       ,
input  wire          RdEna       ,
input  wire [ 7:0]   RdAddress   ,
output wire [31:0]   RdData     

);

    if (ARCH == "XLX_SERIES7")
    begin
        (* KEEP_HIERARCHY = "TRUE" *)
        XLX_ULTRASCALE_x32_1k_BLK XLX_ULTRASCALE_x32_1k_BLK_inst  
        (
        .clka              (WrClk           ),
        .ena               (WrEna           ),
        .wea               (WrWea           ),
        .addra             (WrAddress       ),
        .dina              (WrData          ),

        .clkb              (RdClk           ),
        .enb               (RdEna           ),
        .addrb             (RdAddress       ),
        .doutb             (RdData          )
        );
    end else if (ARCH == "XLX_ULTRASCALE")
        begin
        (* KEEP_HIERARCHY = "TRUE" *)
        XLX_ULTRASCALE_x32_1k_BLK XLX_ULTRASCALE_x32_1k_BLK_inst   
        (
        .clka              (WrClk           ),
        .ena               (WrEna           ),
        .wea               (WrWea           ),
        .addra             (WrAddress       ),
        .dina              (WrData          ),

        .clkb              (RdClk           ),
        .enb               (RdEna           ),
        .addrb             (RdAddress       ),
        .doutb             (RdData          )
        );
    end else  // if (ARCH == "DEFAULT_LOGIC")
    begin

    end



endmodule