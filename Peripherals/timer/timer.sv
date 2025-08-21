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
// Alex Grinshpun 2024 .Pure SystemVerilog version
//

`include "timer_defines.v"

module timer(
		input	logic			i_clk,
		input	logic			i_rst,

		input	logic			timer_cntr_Reg_sel,	// RPTC_CNTR select

		input	logic	[31:0]	timer_hrc_Reg,	// PTC HI Reference/Capture Register
		input	logic	[31:0]	timer_lrc_Reg,	// PTC LO Reference/Capture Register (or no register)
		input	logic	[8:0]	timer_ctrl_Reg,	// PTC Control Register
		input	logic	[31:0]	wb_data_reg_out,

		output	logic	[31:0]	timer_cntr_Reg,	// RPTC_CNTR register	
		output	logic			wb_inta_o,		// Interrupt request output
		output	logic			pwm_pad_o		// PWM output

);


//
// Internal logics & regs
//
logic			hrc_match;	// RPTC_HRC matches RPTC_CNTR
logic			lrc_match;	// RPTC_LRC matches RPTC_CNTR
logic			restart;	// Restart counter when asserted
logic			stop;		// Stop counter when asserted

logic			pwm_rst;	// Reset of a PWM output
logic			int_match;	// Interrupt match

//
// Write to or increment of RPTC_CNTR
//
always_ff @(posedge i_clk or posedge i_rst)
begin
	if (i_rst)
		timer_cntr_Reg <= #1 32'h0;
	else if (timer_cntr_Reg_sel )
		timer_cntr_Reg <= #1 wb_data_reg_out;
	else if (restart)
		timer_cntr_Reg <= #1 32'h0;
	else if (!stop && timer_ctrl_Reg[`TIMER_CTRL_EN])
		timer_cntr_Reg <= #1 timer_cntr_Reg + 1;
end

//
// A match when RPTC_HRC is equal to RPTC_CNTR
//
assign hrc_match = timer_ctrl_Reg[`TIMER_CTRL_EN] & (timer_cntr_Reg == timer_hrc_Reg);

//
// A match when RPTC_LRC is equal to RPTC_CNTR
//
assign lrc_match = timer_ctrl_Reg[`TIMER_CTRL_EN] & (timer_cntr_Reg == timer_lrc_Reg);

//
// Restart counter when lrc_match asserted and RPTC_CTRL[SINGLE] cleared
// or when RPTC_CTRL[CNTRRST] is set
//
assign restart = lrc_match & ~timer_ctrl_Reg[`TIMER_CTRL_SINGLE]
	| timer_ctrl_Reg[`TIMER_CTRL_CNTRRST];

//
// Stop counter when lrc_match and RPTC_CTRL[SINGLE] both asserted
//
assign stop = lrc_match & timer_ctrl_Reg[`TIMER_CTRL_SINGLE];

//
// PWM reset when lrc_match or system reset
//
assign pwm_rst = lrc_match | i_rst;

//
// PWM output
//
always_ff @(posedge i_clk)	// posedge pwm_rst or posedge hrc_match !!! Damjan
begin
	if (pwm_rst)
		pwm_pad_o <= #1 1'b0;
	else if (hrc_match)
		pwm_pad_o <= #1 1'b1;
end
//
// Generate an interrupt request
//
assign int_match = (lrc_match | hrc_match) & timer_ctrl_Reg[`TIMER_CTRL_INTE];

// Register interrupt request
always_ff @(posedge i_rst or posedge i_clk) // posedge int_match (instead of i_rst)
begin
	if (i_rst)
		wb_inta_o <= #1 1'b0;
	else if (int_match)
		wb_inta_o <= #1 1'b1;
	else
		wb_inta_o <= #1 1'b0;
end



endmodule
