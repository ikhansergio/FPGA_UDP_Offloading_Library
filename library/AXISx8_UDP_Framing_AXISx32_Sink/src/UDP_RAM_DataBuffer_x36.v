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

module UDP_RAM_DataBuffer_x36
#(  
    parameter ARCH = "XLX_ULTRASCALE",
    parameter BUFFER_COUNT_1K = 3  
 )  
(
input  wire                                             WrClk       ,
input  wire                                             WrEna       ,
input  wire [ 1-1:0]                                    WrWea       ,
input  wire [UDP_RAM_BitWidth(BUFFER_COUNT_1K)-1:0]     WrAddress   ,
input  wire [36-1:0]                                    WrData      ,

input  wire                                             RdClk       ,
input  wire                                             RdEna       ,
input  wire [UDP_RAM_BitWidth(BUFFER_COUNT_1K)-1:0]     RdAddress   ,
output wire [36-1:0]                                    RdData   
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

generate

if (BUFFER_COUNT_1K == 0 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_512_x36  #(.ARCH(ARCH)) UDP_DataBuffer_512_x36_inst
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
    DataBuffer_1k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_1k_x36_inst
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
    DataBuffer_2k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_2k_x36_inst
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
    DataBuffer_3k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_3k_x36_inst
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
    DataBuffer_4k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_4k_x36_inst
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
    DataBuffer_5k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_5k_x36_inst
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
    DataBuffer_6k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_6k_x36_inst
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
    DataBuffer_7k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_7k_x36_inst
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
    DataBuffer_8k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_8k_x36_inst
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
else if (BUFFER_COUNT_1K == 9 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_9k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_9k_x36_inst
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
else if (BUFFER_COUNT_1K == 10 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_10k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_10k_x36_inst
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
else if (BUFFER_COUNT_1K == 11 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_11k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_11k_x36_inst
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
    DataBuffer_12k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_12k_x36_inst
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
else if (BUFFER_COUNT_1K == 13 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_13k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_13k_x36_inst
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
else if (BUFFER_COUNT_1K == 14 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_14k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_14k_x36_inst
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
else if (BUFFER_COUNT_1K == 15 )        
    begin
    (* KEEP_HIERARCHY = "TRUE" *)
    DataBuffer_15k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_15k_x36_inst
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
    DataBuffer_16k_x36  #(.ARCH(ARCH)) UDP_DataBuffer_16k_x36_inst
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
        UDP_Framing_Error UDP_Framing_BufferSizeError ( );
    end    

endgenerate

endmodule
