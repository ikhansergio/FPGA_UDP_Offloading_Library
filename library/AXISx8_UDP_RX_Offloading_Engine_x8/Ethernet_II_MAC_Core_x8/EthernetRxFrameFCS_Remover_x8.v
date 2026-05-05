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

module EthernetRxFrameFCS_Remover_x8
(
	input              CLK,

	input   wire       FCS_Remover_Sink_Val,
	input   wire       FCS_Remover_Sink_EoF,
	input   wire       FCS_Remover_Sink_Err,  
	input   wire [7:0] FCS_Remover_Sink_Dat,

	output 	reg        FCS_Remover_Source_Val=0,
	output 	reg        FCS_Remover_Source_EoF=0,
	output 	reg        FCS_Remover_Source_Err=0,
    output  reg [7:0]  FCS_Remover_Source_Dat=0
 );
 
reg [ 8-1:0] FCS_Remover_Sink_Dat_REG0 =0;
reg [ 8-1:0] FCS_Remover_Sink_Dat_REG1 =0;
reg [ 8-1:0] FCS_Remover_Sink_Dat_REG2 =0;
reg [ 8-1:0] FCS_Remover_Sink_Dat_REG3 =0;

reg FCS_Remover_Sink_Val_REG0 =0;
reg FCS_Remover_Sink_Val_REG1 =0;
reg FCS_Remover_Sink_Val_REG2 =0;
reg FCS_Remover_Sink_Val_REG3 =0;

always @(posedge CLK)
begin 


        if (FCS_Remover_Source_EoF)
            begin
            FCS_Remover_Sink_Dat_REG0<=0;
            FCS_Remover_Sink_Dat_REG1<=0;
            FCS_Remover_Sink_Dat_REG2<=0;
            FCS_Remover_Sink_Dat_REG3<=0;
            FCS_Remover_Source_Dat  <= 0;
        
            FCS_Remover_Sink_Val_REG0<=0;
            FCS_Remover_Sink_Val_REG1<=0;
            FCS_Remover_Sink_Val_REG2<=0;
            FCS_Remover_Sink_Val_REG3<=0;
            end
        else if (FCS_Remover_Sink_Val)
            begin
            FCS_Remover_Sink_Dat_REG0<=FCS_Remover_Sink_Dat;
            FCS_Remover_Sink_Dat_REG1<=FCS_Remover_Sink_Dat_REG0;
            FCS_Remover_Sink_Dat_REG2<=FCS_Remover_Sink_Dat_REG1;
            FCS_Remover_Sink_Dat_REG3<=FCS_Remover_Sink_Dat_REG2;
            FCS_Remover_Source_Dat   <= FCS_Remover_Sink_Dat_REG3;
        
            FCS_Remover_Sink_Val_REG0<=FCS_Remover_Sink_Val;
            FCS_Remover_Sink_Val_REG1<=FCS_Remover_Sink_Val_REG0;
            FCS_Remover_Sink_Val_REG2<=FCS_Remover_Sink_Val_REG1;
            FCS_Remover_Sink_Val_REG3<=FCS_Remover_Sink_Val_REG2;
            end

    
FCS_Remover_Source_EoF   <= FCS_Remover_Sink_EoF&&FCS_Remover_Sink_Val;
FCS_Remover_Source_Err   <= FCS_Remover_Sink_Err;    
FCS_Remover_Source_Val   <= FCS_Remover_Sink_Val_REG3&&FCS_Remover_Sink_Val;
end

endmodule
