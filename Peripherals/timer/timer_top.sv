//////////////////////////////////////////////////////////////////////
////                                                              ////
////  WISHBONE PWM/Timer/Counter                                  ////
////                                                              ////
////  This file is part of the PTC project                        ////
////  http://www.opencores.org/cores/ptc/                         ////
////                                                              ////
////  Description                                                 ////
////  Implementation of PWM/Timer/Counter IP core according to    ////
////  PTC IP core specification document.                         ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.4  2001/09/18 18:48:29  lampret
// Changed top level ptc into ptc_top. Changed defines.v into ptc_defines.v. Reset of the counter is now synchronous.
//
// Revision 1.3  2001/08/21 23:23:50  lampret
// Changed directory structure, defines and port names.
//
// Revision 1.2  2001/07/17 00:18:10  lampret
// Added new parameters however RTL still has some issues related to hrc_match and int_match
//
// Revision 1.1  2001/06/05 07:45:36  lampret
// Added initial RTL and test benches. There are still some issues with these files.
// Alex Grinshpun 2024 SystemVerilog version
//

// synopsys translate_off
//`include "timescale.v"
// synopsys translate_on
`include "timer_defines.v"

module timer_top
(
	// WISHBONE Interface
	input	logic						wb_clk_i, 
	input	logic						wb_rst_i, 
	input	logic						wb_cyc_i, 
	input	logic	[3:0]				wb_sel_i, 
	input	logic						wb_we_i, 
    input	logic	[2:0]				wb_cti_i,
    input	logic	[1:0]				wb_bte_i,
	input	logic						wb_stb_i,
	input	logic	[31:0]	            wb_adr_i, 
	input	logic	[31:0]				wb_dat_i, 
		
	output	logic	[31:0]				wb_dat_o, 
	output	logic						wb_ack_o, 
	output	logic						wb_err_o,
	output	logic						wb_rty_o,	
	output	logic						wb_inta_o,
				
// External PTC Interface	
	output	logic						pwm_pad_o, 		// PWM output
	output	logic						oen_padoen_o	// PWM output driver enable
);
				
logic						wb_inta_i;
logic						wb_err_i;
		
logic	[7:0]				wb_adr_reg;  // internal signal for address bus
logic	[31:0]				wb_data_reg_in; 
logic	[31:0]				wb_data_reg_out;

logic	[3:0]				wb_sel_out;
logic						we_o; 
logic						re_o; // Write and read enable output for the core

logic	[31:0]				timer_cntr_Reg;	
logic	[31:0]				timer_hrc_Reg;	
logic	[31:0]				timer_lrc_Reg;	
logic	[8:0]				timer_ctrl_Reg;	
logic						timer_cntr_Reg_sel;	// RPTC_CNTR select

wb_module_timer wb_module_timer (
		.clk				(wb_clk_i		), 
							
		.wb_rst_i			(wb_rst_i		), 
		.wb_we_i			(wb_we_i		), 
		.wb_stb_i			(wb_stb_i		), 
		.wb_cti_i			(wb_cti_i		),
		.wb_bte_i			(wb_bte_i		),
		.wb_cyc_i			(wb_cyc_i		), 
		.wb_ack_o			(wb_ack_o		), 
		.wb_sel_i			(wb_sel_i		),
		.wb_adr_i			(wb_adr_i		),	//WISHBONE address line
		.wb_dat_i			(wb_dat_i		),   //input WISHBONE bus 
		.wb_dat_o			(wb_dat_o		), 	
		.wb_inta_o			(wb_inta_o		),
		.wb_err_o			(wb_err_o		),
		.wb_rty_o			(wb_rty_o		),
							
		.wb_err_i			(1'b0			),
							
		.wb_adr_reg			(wb_adr_reg		),  // internal signal for address bus
		.wb_data_reg_in		(wb_data_reg_in	), 
		.wb_data_reg_out	(wb_data_reg_out),
		.wb_inta_i			(wb_inta_i		),  // Interrupt request output
		.wb_sel_out			(wb_sel_out		),

		.we_o				(we_o			), 
		.re_o				(re_o			) // Write and read enable output for the core
);

timer_registers timer_registers
  (
		.i_clk				(wb_clk_i			),
		.i_rst				(wb_rst_i			),
									
		.wb_sel_out			(wb_sel_out			),
		.we_o				(we_o				), 
		.re_o				(re_o				), 	
		.wb_adr_reg			(wb_adr_reg			),
		.wb_data_reg_in		(wb_data_reg_in		), 
		.wb_data_reg_out	(wb_data_reg_out	),
		                 
		                 
		.timer_cntr_Reg_sel	(timer_cntr_Reg_sel	),
		.timer_cntr_Reg		(timer_cntr_Reg		),
		.timer_hrc_Reg		(timer_hrc_Reg		),
		.timer_lrc_Reg		(timer_lrc_Reg		),
		.timer_ctrl_Reg		(timer_ctrl_Reg		),
		.oen_padoen_o		(oen_padoen_o		)
	);


timer timer(
		.i_clk				(wb_clk_i			),
		.i_rst				(wb_rst_i			),
		                     
		.timer_cntr_Reg_sel	(timer_cntr_Reg_sel	),	// RPTC_CNTR select
		                     
		.timer_hrc_Reg		(timer_hrc_Reg		),	// PTC HI Reference/Capture Register
		.timer_lrc_Reg		(timer_lrc_Reg		),	// PTC LO Reference/Capture Register (or no register)
		.timer_ctrl_Reg		(timer_ctrl_Reg		),	// PTC Control Register
		.wb_data_reg_out	(wb_data_reg_out	),
		                     
		.timer_cntr_Reg		(timer_cntr_Reg		),	// RPTC_CNTR register	
		.wb_inta_o			(wb_inta_i			),		// Interrupt request output
		.pwm_pad_o			(pwm_pad_o			)		// PWM output

);	

endmodule
