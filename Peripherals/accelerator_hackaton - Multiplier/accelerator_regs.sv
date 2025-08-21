
// Register addresses
// Provided AS IS without any warranty of any kind nor EXPLICIT nor IMPLIED

`define ACCELERATOR_REG_A		    8'h0	 
`define ACCELERATOR_REG_B		    8'h4	 
`define ACCELERATOR_REG_RESULT		8'h8	 
`define ACCELERATOR_REG_STATUS		8'hc	 


module accelerator_regs
#(parameter SIM = 0)
 (
	input	logic				clk,
	input	logic				wb_rst_i,
	input	logic	[7:0]		wb_addr_i,
	input	logic	[31:0]	  	wb_dat_i,
	output	logic	[31:0]		wb_dat_o,
	input	logic				wb_we_i,
	input	logic				wb_re_i,
	
  
  // These is user defined interface
    input	logic				overflow,
	output	logic	[15:0]	    reg_a,
	output	logic	[15:0]	    reg_b,
	input	logic	[15:0]	    reg_result
);


// Asynchronous reading here because the outputs are sampled in uart_wb.v file 
always_comb   // asynchrounous reading
begin
	case (wb_addr_i)
		`ACCELERATOR_REG_STATUS	    :	wb_dat_o = {31'h0,overflow};
		`ACCELERATOR_REG_A		      :	wb_dat_o = {16'h0,reg_a};
		`ACCELERATOR_REG_B		      :	wb_dat_o = {16'h0,reg_b};
		`ACCELERATOR_REG_RESULT		  :	wb_dat_o = {16'h0,reg_result};
		default				          :	wb_dat_o = 32'b0; // ??
	endcase // 
end // 

//
//   WRITES AND RESETS   //
//
	always_ff @(posedge clk or posedge wb_rst_i) begin
		if (wb_rst_i)	begin
			reg_a			<= '0;
			reg_b			<= '0;
        end
		else
			if (wb_we_i ) begin
				case (wb_addr_i)
				`ACCELERATOR_REG_A		:	reg_a		<= wb_dat_i[15:0];
				`ACCELERATOR_REG_B		:	reg_b		<= wb_dat_i[15:0];
				endcase // case(wb_addr_i)			
			end
	end

endmodule
