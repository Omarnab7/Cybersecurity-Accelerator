// SPDX-License-Identifier: Apache-2.0
// Copyright 2019-2020 Western Digital Corporation or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//********************************************************************************
// $Id$
//
// Function: VeeRwolf Timer Registers
// Comments:
//
//********************************************************************************
// Alex Grinshpun 2023 .Pure SystemVerilog version

`include "timer_defines.v"
module timer_registers
  (
		input	logic			i_clk,
		input	logic			i_rst,

		input	logic	[3:0]	wb_sel_out,
		input	logic			we_o, 
		input	logic			re_o, // Write and read enable output for the core		
		input	logic	[7:0]	wb_adr_reg,  // internal signal for address bus
		output	logic	[31:0]	wb_data_reg_in, 
		input	logic	[31:0]	wb_data_reg_out,

	
		input	logic	[31:0]	timer_cntr_Reg,	// RPTC_CNTR register
		output	logic			timer_cntr_Reg_sel,
		output	logic	[31:0]	timer_hrc_Reg,	// PTC HI Reference/Capture Register
		output	logic	[31:0]	timer_lrc_Reg,	// PTC LO Reference/Capture Register (or no register)
		output	logic	[8:0]	timer_ctrl_Reg,	// PTC Control Register
		output	logic			oen_padoen_o	// PWM output driver enable
	);

logic	[1:0]	addr;
//
// PWM output driver enable is inverted RPTC_CTRL[OE]
//
assign	oen_padoen_o = ~timer_ctrl_Reg[`TIMER_CTRL_OE];
assign	full_decoding = 1'b1;
assign	addr = wb_adr_reg[7:2];

//
// PTC registers address decoder
//
assign timer_cntr_Reg_sel = we_o & (addr == `TIMER_CNTR) ;

 // Asynchronous reading here because the outputs are sampled in uart_wb.v file 
	always_comb   // asynchrounous reading
	begin
		case (addr)
		`TIMER_CNTR		:	wb_data_reg_in = timer_cntr_Reg; 				
		`TIMER_HRC		: 	wb_data_reg_in = timer_hrc_Reg;		
		`TIMER_LRC		:	wb_data_reg_in = timer_lrc_Reg;				
		`TIMER_CTRL		:	wb_data_reg_in = timer_ctrl_Reg;		
		default			:	wb_data_reg_in = 32'hDEADBEEF;
		endcase // 
	end // 


   always_ff @(posedge i_clk) begin
		if (i_rst) begin
			timer_hrc_Reg	<=	32'h0;
			timer_lrc_Reg	<=	32'h0;
			timer_ctrl_Reg	<=	9'h0;
		end
		else	begin
			if (we_o ) begin
				case (addr)
				`TIMER_CTRL	: begin
					timer_ctrl_Reg		<= wb_data_reg_out; 
				end				
				`TIMER_HRC	: begin 
					timer_hrc_Reg		<= wb_data_reg_out; 
				end				
				`TIMER_LRC	: begin
					timer_lrc_Reg		<= wb_data_reg_out; 
				end				
				endcase			
			end
	end

    end
endmodule
	
	