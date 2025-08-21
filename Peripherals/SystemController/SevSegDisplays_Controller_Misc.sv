module SevSegDisplays_Controller_Misc # (COUNT_MAX = 18)
								(
									input	logic	[23:0]				OneHerzCount,
									input	logic	[(COUNT_MAX-1):0]	countSelection,
									input	logic	[15:0]       		CharEns, //Alex Grinshpun LSB - every bit "1" ASCII deciding, MSB - every bit "1" corresponds to Seven Segment Blinking
																		
									input	logic	[7:0]	     		Enables_Reg,
									output	logic	[ 7:0] [3:0]		digits_concat,
									input	logic	[63:0]				Digits_Reg, //Alex Grinshpun
									output	logic	[7:0]				AN,
									output	logic	[6:0]				Digits_Bits,
									output	logic	[ 3:0]				DecNumber,
									output	logic	[7:0]				blinkReg,
									output	logic	[ 7:0]	        	CharLetter,//Alex Grinshpun ASCII char
									output	logic			        	CharEn    //Alex Grinshpun enable ASCII strings decode

									);
									
logic						OneHerzCountEnable;
logic	[ 7:0] [7:0]		enable;
logic	[ 7:0] [7:0]		char_concat; //Alex Grinshpun ASCII string
									
	assign	OneHerzCountEnable	= OneHerzCount[23];	
	assign	enable[0] = (Enables_Reg | 8'hfe);
	assign	enable[1] = (Enables_Reg | 8'hfd);
	assign	enable[2] = (Enables_Reg | 8'hfb);
	assign	enable[3] = (Enables_Reg | 8'hf7);
	assign	enable[4] = (Enables_Reg | 8'hef);
	assign	enable[5] = (Enables_Reg | 8'hdf);
	assign	enable[6] = (Enables_Reg | 8'hbf);
	assign	enable[7] = (Enables_Reg | 8'h7f);

  assign AN = enable[countSelection[(COUNT_MAX-1):(COUNT_MAX-3)]]; //Alex Grinshpun

always_comb begin //Alex Grinshpun
	if (!CharEn) begin                               //Alex Grinshpun all seven segments are DIGITS
		digits_concat[0] = Digits_Reg[3:0];
		digits_concat[1] = Digits_Reg[7:4];
		digits_concat[2] = Digits_Reg[11:8];
		digits_concat[3] = Digits_Reg[15:12];
		digits_concat[4] = Digits_Reg[19:16];
		digits_concat[5] = Digits_Reg[23:20];
		digits_concat[6] = Digits_Reg[27:24];
		digits_concat[7] = Digits_Reg[31:28];
		
		char_concat[0] = Digits_Reg[7:0];
		char_concat[1] = Digits_Reg[15:8];
		char_concat[2] = Digits_Reg[23:16];
		char_concat[3] = Digits_Reg[31:24];
		char_concat[4] = Digits_Reg[39:32];
		char_concat[5] = Digits_Reg[47:40];
		char_concat[6] = Digits_Reg[55:48];
		char_concat[7] = Digits_Reg[63:56];
	end
	else begin
		//Alex Grinshpun                                   /Alex Grinshpun strings are Little Endian convert to Big Endian
		digits_concat[3] = Digits_Reg[3:0];
		digits_concat[2] = Digits_Reg[7:4];
		digits_concat[1] = Digits_Reg[11:8];
		digits_concat[0] = Digits_Reg[15:12];
		digits_concat[7] = Digits_Reg[19:16];
		digits_concat[6] = Digits_Reg[23:20];
		digits_concat[5] = Digits_Reg[27:24];
		digits_concat[4] = Digits_Reg[31:28];
		
		char_concat[3] = Digits_Reg[7:0];
		char_concat[2] = Digits_Reg[15:8];
		char_concat[1] = Digits_Reg[23:16];
		char_concat[0] = Digits_Reg[31:24];
		char_concat[7] = Digits_Reg[39:32];
		char_concat[6] = Digits_Reg[47:40];
		char_concat[5] = Digits_Reg[55:48];
		char_concat[4] = Digits_Reg[63:56];	
	
	end
  end
  
  assign	blinkReg		= CharEns[15:8]; //Alex Grinshpun every bit corresponds to SevenSegment - "1" is blinking
  assign	DecNumber		= digits_concat[countSelection[(COUNT_MAX-1):(COUNT_MAX-3)]]; //Alex Grinshpun
  assign	CharLetter		= (blinkReg[countSelection[(COUNT_MAX-1):(COUNT_MAX-3)]] && OneHerzCountEnable) ? 8'b0 : char_concat[countSelection[(COUNT_MAX-1):(COUNT_MAX-3)]]; //Alex Grinshpun
  assign	CharEn			= CharEns[countSelection[(COUNT_MAX-1):(COUNT_MAX-3)]]; //Alex Grinshpun	
endmodule