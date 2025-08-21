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
// Function: VeeRwolf SoC-level controller
// Comments:
//
//********************************************************************************
// Alex Grinshpun 2023 .Pure SystemVerilog version and display Letters + Digits

module SevSegDisplays_Controller(
									input	logic			     	clk,
									input	logic			     	rst_n,
									input	logic	[15:0]       	CharEns, //Alex Grinshpun LSB - every bit "1" ASCII deciding, MSB - every bit "1" corresponds to Seven Segment Blinking
									
									input	logic	[7:0]	     	Enables_Reg,
									input	logic	[63:0]			Digits_Reg, //Alex Grinshpun
									output	logic	[7:0]			AN,
									output	logic	[6:0]			Digits_Bits,
									output	logic	[ 3:0]			DecNumber,
									output	logic	[ 7:0]	        CharLetter,//Alex Grinshpun ASCII char
									output	logic	[ 7:0] [7:0]	char_concat //Alex Grinshpun ASCII string
									);
`ifdef ViDBo
parameter COUNT_MAX = 3;
`elsif XSIM
parameter COUNT_MAX = 3;
`else 
parameter COUNT_MAX = 18;
`endif

logic	[(COUNT_MAX-1):0]	countSelection;
logic			        	CharEn;     //Alex Grinshpun enable ASCII strings decode

logic						overflow_o_count;
logic	[ 7:0] [7:0]		enable;
logic	[ 7:0] [3:0]		digits_concat;
logic						OneHerzCountEnable;
logic	[23:0]				OneHerzCount;
logic	[7:0]				blinkReg;





  SevenSegDecoder SevSegDec(
                            .CharEn			(CharEn),
							.CharLetter	(CharLetter),
							.data			(DecNumber), 
                            .seg			(Digits_Bits)
                            );

  counter #(COUNT_MAX)  counter20(
                                    .clk_i      (clk), 
									.rst_ni     (~rst_n), 
									.clear_i    (1'b0), // synchronous clear
									.en_i       (1'b1), // enable the counter
									.load_i     (1'b0), // load a new value
									.down_i     (1'b0), // downcount, default is up
									.d_i        (16'b0), 
									.q_o        (countSelection), 
									.overflow_o (overflow_o_count)
                                    );

// ALex Grinshpun Blinking Seven Segement

  counter #(24)  counter24(
                                    .clk_i      (clk), 
                                    .rst_ni     (~rst_n), 
                                    .clear_i    (1'b0), // synchronous clear
                                    .en_i       (1'b1), // enable the counter
                                    .load_i     (1'b0), // load a new value
                                    .down_i     (1'b0), // downcount, default is up
                                    .d_i        (16'b0), 
                                    .q_o        (OneHerzCount), //Alex Grinshpun ~ 0.5 Hz signal
                                    .overflow_o ()
                                    );
									
	SevSegDisplays_Controller_Misc # (
		.COUNT_MAX(COUNT_MAX))
	SevSegDisplays_Controller_Misc 
	(
		
		.OneHerzCount	(OneHerzCount	),
		.countSelection	(countSelection	),
		.CharEns		(CharEns		),
		                 
		.Enables_Reg	(Enables_Reg	),
		.digits_concat	(digits_concat	),
		.Digits_Reg		(Digits_Reg		),
		.AN				(AN				),
		.Digits_Bits	(Digits_Bits	),
		.DecNumber		(DecNumber		),
		.blinkReg		(blinkReg		),
		.CharLetter		(CharLetter		),
		.CharEn			(CharEn			)
	);



endmodule