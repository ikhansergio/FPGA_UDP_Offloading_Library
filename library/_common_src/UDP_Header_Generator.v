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

module UDP_Header_Generator
(
input  wire              CLK,

input  wire              UDP_TRY,

input  wire [16-1:0]     UDP_LOCAL_PORT_IN ,
input  wire [16-1:0]   	 UDP_REMOTE_PORT_IN,
input  wire [16-1:0]   	 UDP_TotalLength,
input  wire [16-1:0]   	 UDP_Checksum,
input  wire [ 6-1:0]     UDP_Position,

output reg  [ 8-1:0]     UDP_Header =0 
);

always @(posedge CLK)
begin
if (UDP_TRY)
    begin
    if (UDP_Position==7'd34) UDP_Header<=UDP_LOCAL_PORT_IN  [15:8];                                                  // Source Port High
        else if (UDP_Position==7'd35) UDP_Header<=UDP_LOCAL_PORT_IN  [ 7:0];                                         // Source Port Low
            else if (UDP_Position==7'd36) UDP_Header<=UDP_REMOTE_PORT_IN  [15:8];                                    // Destination Port High
	           else if (UDP_Position==7'd37) UDP_Header<=UDP_REMOTE_PORT_IN  [ 7:0];                                 // Destination Port Low
	               else if (UDP_Position==7'd38) UDP_Header<=UDP_TotalLength[15: 8];                                 // Length High
	                   else if (UDP_Position==7'd39) UDP_Header<=UDP_TotalLength[ 7: 0];                             // Length Low
	                       else if (UDP_Position==7'd40) UDP_Header<=UDP_Checksum[15:8];                             // Checksum High
	                           else if (UDP_Position==7'd41) UDP_Header<=UDP_Checksum[ 7:0];                         // Checksum Low
	                               else UDP_Header<=0;    
    end                
end 
                                     
endmodule


