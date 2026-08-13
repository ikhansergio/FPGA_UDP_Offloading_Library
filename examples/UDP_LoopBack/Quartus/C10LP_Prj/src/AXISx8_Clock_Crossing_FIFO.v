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

module AXISx8_Clock_Crossing_FIFO 
(
input 	wire 			s_axis_aresetn,
input 	wire 			s_axis_aclk,
input 	wire 			s_axis_tvalid,
output 	wire 			s_axis_tready,
input 	wire [7 : 0] 	s_axis_tdata,
input 	wire 			s_axis_tlast,
input 	wire [0 : 0] 	s_axis_tuser,

input 	wire 			m_axis_aclk,
output 	reg  			m_axis_tvalid,
input 	wire 			m_axis_tready,
output 	reg  [7 : 0] 	m_axis_tdata,
output 	reg  			m_axis_tlast,
output 	reg  [0 : 0] 	m_axis_tuser
);


wire 			 wRdEpt;
wire [10-1 : 0 ] ws_Data;
wire [10-1 : 0 ] wm_Data;
assign ws_Data = {s_axis_tuser, s_axis_tlast, s_axis_tdata};

   ALT_BLK_FIFO_36x256	ALT_BLK_FIFO_36x256_inst (
	.aclr              (~s_axis_aresetn ),
	.data              ( ws_Data        ),
	.rdclk             ( m_axis_aclk    ),
	.rdreq             ( m_axis_tready	),
	.wrclk             ( s_axis_aclk    ),
	.wrreq             ( s_axis_tvalid  ),
	.q                 ( wm_Data    	),
	.rdempty           ( wRdEpt     	),
	.rdusedw           ( 			  	),
	.wrfull            (~s_axis_tready	)
	); 
	
always @(posedge m_axis_aclk )
begin

if (wRdEpt) m_axis_tdata  <= 8'd0; 
	else m_axis_tdata  <= wm_Data[7:0] ;

m_axis_tvalid <= ~wRdEpt;
m_axis_tlast  <= ~wRdEpt && wm_Data[8];
m_axis_tuser  <= ~wRdEpt && wm_Data[9];
end	

endmodule
