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

module ICMP_PING_RAM_DataBuffer_x32
#(  
    parameter ARCH = "XLX_ULTRASCALE",
    parameter BUFFER_COUNT_1K = 4  
 )  
(
input  wire                                             WrClk       ,
input  wire                                             WrEna       ,
input  wire [ 1-1:0]                                    WrWea       ,
input  wire [UDP_RAM_BitWidth(BUFFER_COUNT_1K)-1:0]     WrAddress   ,
input  wire [31-1:0]                                    WrData      ,

input  wire                                             RdClk       ,
input  wire                                             RdEna       ,
input  wire [UDP_RAM_BitWidth(BUFFER_COUNT_1K)-1:0]     RdAddress   ,
output wire [31-1:0]                                    RdData   
);

function integer UDP_RAM_BitWidth (input integer BUFF_COUNT);                  
    if (BUFF_COUNT==0)
        begin
            UDP_RAM_BitWidth = 7; 
        end
    else 
        begin
            BUFF_COUNT=BUFF_COUNT*256-1;                                                            
            for(UDP_RAM_BitWidth=0; BUFF_COUNT>0; UDP_RAM_BitWidth=UDP_RAM_BitWidth+1) BUFF_COUNT = BUFF_COUNT >> 1;                                                     
        end                                                          
endfunction 

if (BUFFER_COUNT_1K == 0 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_512_x36  #(.ARCH(ARCH)) PING_DataBuffer_512_x36_inst
    (
    .WrClk       (WrClk),
    .WrEna       (WrEna),
    .WrWea       (WrWea),
    .WrAddress   (WrAddress),
    .WrData      (WrData),

    .RdClk       (RdClk),
    .RdEna       (RdEna),
    .RdAddress   (RdAddress),
    .RdData      (RdData)
    );       
    end 
else if (BUFFER_COUNT_1K == 1 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_1k_x36  #(.ARCH(ARCH)) PING_DataBuffer_1k_x36_inst
    (
    .WrClk       (WrClk),
    .WrEna       (WrEna),
    .WrWea       (WrWea),
    .WrAddress   (WrAddress),
    .WrData      (WrData),

    .RdClk       (RdClk),
    .RdEna       (RdEna),
    .RdAddress   (RdAddress),
    .RdData      (RdData)
    );       
    end 
else if (BUFFER_COUNT_1K == 2 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_2k_x36  #(.ARCH(ARCH)) PING_DataBuffer_2k_x36_inst
    (
    .WrClk       (WrClk),
    .WrEna       (WrEna),
    .WrWea       (WrWea),
    .WrAddress   (WrAddress),
    .WrData      (WrData),

    .RdClk       (RdClk),
    .RdEna       (RdEna),
    .RdAddress   (RdAddress),
    .RdData      (RdData)
    );       
    end 
else if (BUFFER_COUNT_1K == 3 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_3k_x36  #(.ARCH(ARCH)) PING_DataBuffer_3k_x36_inst
    (
    .WrClk       (WrClk),
    .WrEna       (WrEna),
    .WrWea       (WrWea),
    .WrAddress   (WrAddress),
    .WrData      (WrData),

    .RdClk       (RdClk),
    .RdEna       (RdEna),
    .RdAddress   (RdAddress),
    .RdData      (RdData)
    );       
    end  
else if (BUFFER_COUNT_1K == 4 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_4k_x36  #(.ARCH(ARCH)) PING_DataBuffer_4k_x36_inst
    (
    .WrClk       (WrClk),
    .WrEna       (WrEna),
    .WrWea       (WrWea),
    .WrAddress   (WrAddress),
    .WrData      (WrData),

    .RdClk       (RdClk),
    .RdEna       (RdEna),
    .RdAddress   (RdAddress),
    .RdData      (RdData)
    );       
    end
else if (BUFFER_COUNT_1K == 8 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_8k_x36  #(.ARCH(ARCH)) PING_DataBuffer_8k_x36_inst
    (
    .WrClk       (WrClk),
    .WrEna       (WrEna),
    .WrWea       (WrWea),
    .WrAddress   (WrAddress),
    .WrData      (WrData),

    .RdClk       (RdClk),
    .RdEna       (RdEna),
    .RdAddress   (RdAddress),
    .RdData      (RdData)
    );       
    end
else if (BUFFER_COUNT_1K == 16 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_16k_x36  #(.ARCH(ARCH)) PING_DataBuffer_16k_x36_inst
    (
    .WrClk       (WrClk),
    .WrEna       (WrEna),
    .WrWea       (WrWea),
    .WrAddress   (WrAddress),
    .WrData      (WrData),

    .RdClk       (RdClk),
    .RdEna       (RdEna),
    .RdAddress   (RdAddress),
    .RdData      (RdData)
    );       
    end
else  
    begin
        ICMP_PING_Error ICMP_PING_BufferSizeError ( );
    end    

endmodule
