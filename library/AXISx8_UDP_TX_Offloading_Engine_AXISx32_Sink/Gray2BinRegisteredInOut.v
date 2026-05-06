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

module Gray2BinRegisteredInOut
#(
 parameter WIDTH = 8
)
(
    input  wire             Clk,
    input  wire [WIDTH-1:0] GrayIn,
    output reg  [WIDTH-1:0] BinOut =0
 );

wire [WIDTH-1:0] wGray;
reg  [WIDTH-1:0] wBin =0;

// Ñlock domains crossing
reg  [WIDTH-1:0] gray_reg0 =0 ;
reg  [WIDTH-1:0] gray_reg1 =0 ;
reg  [WIDTH-1:0] gray_reg2 =0 ;

assign wGray = gray_reg0;
integer i;

always @(*) 
begin
    wBin [WIDTH-1] <= wGray[WIDTH-1];
    for (i = WIDTH-2; i >= 0; i = i - 1) 
        begin
        wBin[i] <= wBin[i+1] ^ wGray[i];
        end
end

always @(posedge Clk)
begin
gray_reg2 <= GrayIn;
gray_reg1 <= gray_reg2;
gray_reg0 <= gray_reg1;

BinOut <= wBin;
end 

endmodule