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

module EthTxSchedulerRequestEncoder
#(
parameter INDEX_WIDTH = 4
)
(
 input  wire     Clk,
 input  wire    [REQUEST_COUNT(INDEX_WIDTH)-1:0]    ValidRequest,
 input  wire    [INDEX_WIDTH-1:0]                   CurrentCheckIndex,
 
 output reg                                         HasValidRequest     =0,        // Set to 1, if has any Valid Request
 output reg     [INDEX_WIDTH-1:0]                   CurrentValidIndex   =0      // Index of first ValidRequest greater than or equal to CurrentCheckIndex
 );
 
function integer REQUEST_COUNT (input integer Value);                  
    REQUEST_COUNT = 1 << Value;                                                        
endfunction 
localparam MAX_TxPortCount  = REQUEST_COUNT(INDEX_WIDTH);
 
integer i=0; 
reg    [REQUEST_COUNT(INDEX_WIDTH)-1:0]    wValidRequest;
reg    [REQUEST_COUNT(INDEX_WIDTH)-1:0]    wValidMask;

always @(*) begin
    for (i = 0; i <= MAX_TxPortCount-1; i = i + 1) 
    begin
        if (i>=CurrentCheckIndex) wValidRequest[i]<=ValidRequest[i];
            else wValidRequest[i]<=1'b0;
            
        if (i==0) wValidMask[i]<=wValidRequest[i];
            else  wValidMask[i]<=wValidRequest[i]||wValidMask[i-1];
    end
end
 
integer j=0;  
always @(posedge Clk)
begin
HasValidRequest<=|wValidRequest;

    for (j = 0; j <= MAX_TxPortCount-1; j = j + 1) 
    begin
    if ((j==0)&&(wValidMask[j]==1)) CurrentValidIndex<=0;
        else if ((j!=0)&&(wValidMask[j]==1)&&(wValidMask[j-1]==0))  CurrentValidIndex<=j;
          //  else CurrentValidIndex<=0;
    end
end

endmodule
