
//Provided AS IS without any warranty of any kind nor EXPLICIT nor IMPLIED

module accelerator_core
(
    // Control signals
	input	logic				clk,
	input	logic				wb_rst_i,


	input	logic		[15:0]		reg_a,
	input	logic		[15:0]		reg_b,
	output	logic				    overflow,
	output	logic		[15:0]		reg_result
);

//-------------------------------------------------------------------------------
// Local signal declaration
//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------------
// Core interface
//-------------------------------------------------------------------------------
 

logic signed [31:0] result_32_bit;

 
//////////////CALCULATE RESULT////////////////////////////	 
	assign result_32_bit = reg_a * reg_b;
//////////////////////////////////////////
							 
	always_ff @(posedge clk or posedge wb_rst_i) begin
		if(wb_rst_i) begin
			reg_result	<=	32'h0;
			overflow	<=	1'b0;
		end
		else	begin
			reg_result <= result_32_bit[15:0];
			if (|result_32_bit[31:16])  
				overflow <=	1'b1;
			else
				overflow <=	1'b0;
		end
	end
		

endmodule
