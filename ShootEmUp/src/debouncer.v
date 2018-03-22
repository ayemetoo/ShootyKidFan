`timescale 1ns / 1ps

module debouncer(
	input clk,			// 10MHz clock? or just clk
	input fast_clk,	// fast clock for down sampling
	input rst,
	input b_in, 		// input that will be debounced
	output reg b_out 	// debounced output
);

	reg [1:0] DFF;		// D flip flops
	
	always @ (posedge clk)
	begin
		if (rst) begin
			DFF[0] <= 1'b0;
			DFF[1] <= 1'b0;
		end else begin
			DFF[0] <= b_in;
			DFF[1] <= DFF[0];
		end
	end
	

	// FF output based on state and a high frequency clock (clk_fast from clk_divider)
	always @ (posedge fast_clk)
	begin
		b_out <= DFF[1];
		//b_out <= b_in;
	end

endmodule 