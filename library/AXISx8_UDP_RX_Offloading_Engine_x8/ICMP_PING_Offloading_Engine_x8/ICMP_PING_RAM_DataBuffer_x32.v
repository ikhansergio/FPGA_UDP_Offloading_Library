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
    parameter BUFFER_COUNT_1K = 3  
 )  
(
input  wire                                     WrClk       ,
input  wire                                     WrEna       ,
input  wire [ 3:0]                              WrWea       ,
input  wire [BitWidth(BUFFER_COUNT_1K*256)-1:0]  WrAddress   ,
input  wire [31:0]                              WrData      ,

input  wire                                     RdClk       ,
input  wire                                     RdEna       ,
input  wire [BitWidth(BUFFER_COUNT_1K*256)-1:0]  RdAddress   ,
output wire [31:0]                              RdData   
);

function integer BitWidth (input integer Value);                  
    if (Value<3)
        begin
            BitWidth = 1; 
        end
    else 
        begin
            Value=Value-1;                                                            
            for(BitWidth=0; Value>0; BitWidth=BitWidth+1) Value = Value >> 1;                                                     
        end                                                          
endfunction 


localparam TestSize = BitWidth(16*1024+1);

if (BUFFER_COUNT_1K == 1 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    UDP_1k_DataBuffer_x32  #(.ARCH(ARCH)) UDP_1k_DataBuffer_x32_inst
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
    UDP_2k_DataBuffer_x32  #(.ARCH(ARCH)) UDP_2k_DataBuffer_x32_inst
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
    UDP_3k_DataBuffer_x32  #(.ARCH(ARCH)) UDP_3k_DataBuffer_x32_inst
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
    UDP_4k_DataBuffer_x32  #(.ARCH(ARCH)) UDP_4k_DataBuffer_x32_inst
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
else if (BUFFER_COUNT_1K == 5 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    UDP_5k_DataBuffer_x32  #(.ARCH(ARCH)) UDP_5k_DataBuffer_x32_inst
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
else if (BUFFER_COUNT_1K == 6 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    UDP_6k_DataBuffer_x32  #(.ARCH(ARCH)) UDP_6k_DataBuffer_x32_inst
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
else if (BUFFER_COUNT_1K == 7 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    UDP_7k_DataBuffer_x32  #(.ARCH(ARCH)) UDP_7k_DataBuffer_x32_inst
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
    UDP_8k_DataBuffer_x32  #(.ARCH(ARCH)) UDP_8k_DataBuffer_x32_inst
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
else if (BUFFER_COUNT_1K == 12 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    UDP_12k_DataBuffer_x32  #(.ARCH(ARCH)) UDP_12k_DataBuffer_x32_inst
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
    UDP_16k_DataBuffer_x32  #(.ARCH(ARCH)) UDP_16k_DataBuffer_x32_inst
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
        RGMII_Error REFERENCE_PHY_RXC_ERROR ( );
    end    

endmodule