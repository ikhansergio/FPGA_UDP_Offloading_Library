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

module AXIS_Width_Up_Converter
   #(
    parameter BIT_WIDTH = 8,
    parameter N = 4,
	parameter BIG_ENDIAN = 0,    	 
    parameter TFIRST_ReSTORE = 0,    // Altera/Intel Avalon stream  and AXI Stream Compatibility. If TFIRST_ReSTORE ==1 : TFIRST ignored else TFIRST is equivalent AVALON SOP signal
    localparam WordCount=clogb2(N)
   )
    (
    
    input CLK ,
    
    input [BIT_WIDTH-1:0] TDATA ,
    input TVALID,
    input TFIRST,
    input TLAST,
    input TERROR,
    
    output reg TFIRST_OUT,
    output reg TVALID_OUT,
    output reg TERROR_OUT,
    output reg TLAST_OUT,
	output reg [WordCount-1:0] EMPTY_OUT,
	output reg [N-1:0] TKEEP_OUT,
    output reg [(N*BIT_WIDTH)-1:0] TDATA_OUT 

    );
    
    function integer clogb2 (input integer depth);
    begin
    depth = depth - 1;
    for(clogb2=0; depth>0; clogb2=clogb2+1)
    depth = depth >> 1;
    end
    endfunction 
	//////////////////////////////////////////////////////////////////////////////////////
	// find the beginning of a package 
    wire wTFIRST0;   
    reg  TLAST_FLAG=1;
    wire wTFIRST;
	always @(posedge CLK) begin if (TVALID&&TLAST) TLAST_FLAG<=1; else if (TVALID) TLAST_FLAG<=0; end
	assign wTFIRST0=TLAST_FLAG&&TVALID;
    assign wTFIRST = (TFIRST_ReSTORE==0) ?   TFIRST&&TVALID : wTFIRST0;
	//////////////////////////////////////////////////////////////////////////////////////
    reg  [WordCount-1:0] ShiftPos;          // byte position pointer in the output word 
    reg  [BIT_WIDTH-1:0] TDATA_REG;         // Data in delay reg
    reg  SOP_REG_FLAG;                      // first output word flag
    reg  TVALID_REG;                        // Valid in delay reg
    reg  TLAST_REG;                         // Last in delay reg
    reg  TERROR_REG;                        // ErrorFlag in delay reg
    
    reg ZeroInitFlag;                       // default flag for initialization of the output word 
	
	always @(posedge CLK) 
    begin
    // byte position pointer logic
    if (wTFIRST) ShiftPos<=0;
        else if (TVALID&&(ShiftPos>=(N-1))) ShiftPos<=0;
            else if (TVALID) ShiftPos<=ShiftPos+1;
    // default flag  logic        
    if (wTFIRST) ZeroInitFlag<=1;
        else if (TVALID&&(ShiftPos>=(N-1))) ZeroInitFlag<=1;
            else ZeroInitFlag<=0;
	end
	// reverce  byte position if Big endian mode
	wire [WordCount-1:0] wShiftPos;
	assign wShiftPos = (BIG_ENDIAN==0) ? ShiftPos : ~ShiftPos;
 
	always @(posedge CLK) 
    begin    
    TDATA_REG<=TDATA;    
    // first output word flag set in beginning 
    if (wTFIRST)  SOP_REG_FLAG<=1'b1; else if  (TVALID&&(ShiftPos==(N-1))) SOP_REG_FLAG<=1'b0; 
    if (TLAST&&TVALID)  TLAST_REG<=1'b1;  else    TLAST_REG<=1'b0;
    TVALID_REG<=TVALID;
    TERROR_REG<=TERROR;
    
        
    TFIRST_OUT<=(SOP_REG_FLAG&&((ShiftPos==(N-1))||TLAST_REG))&&TVALID_REG;
    TVALID_OUT <=((ShiftPos==(N-1))||TLAST_REG)&&TVALID_REG;
    TLAST_OUT  <=TLAST_REG&&TVALID_REG;
    TERROR_OUT <=TERROR_REG;
	if (TLAST_REG&&TVALID_REG) EMPTY_OUT <= ~wShiftPos; else EMPTY_OUT <= 0; 
	
	
	if (BIG_ENDIAN==0)
	   begin
	        if (TVALID_REG&&ZeroInitFlag) TKEEP_OUT<=1; else if (TVALID_REG) TKEEP_OUT<={TKEEP_OUT[N-2:0],1'b1};
	   end else
    if (BIG_ENDIAN!=0)
       begin
            if (TVALID_REG&&ZeroInitFlag) TKEEP_OUT<= {1'b1,{(N-1){1'b0}}} ; else if (TVALID_REG) TKEEP_OUT<={1'b1,TKEEP_OUT[N-1:1]};
       end
    end

    genvar x;
    generate
    for (x = 0; x < N; x = x+1)  
    begin : Shift
        always @(posedge CLK) 
        begin
            if ((wShiftPos==x)&&TVALID_REG) TDATA_OUT[((x+1)*BIT_WIDTH)-1:x*BIT_WIDTH]<=TDATA_REG;
                else if (TVALID_REG&&ZeroInitFlag) TDATA_OUT[((x+1)*BIT_WIDTH)-1:x*BIT_WIDTH]<=0;
        end
    end
    endgenerate

endmodule
