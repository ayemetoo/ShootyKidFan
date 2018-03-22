`timescale 1ns / 1ps

module game_over(
	input clk, rst,
	input wire [9:0] x, y,
	input wire [1:0] p_lives,
	output wire game_display_on,
	output reg game_over_reg,
	output wire [7:0] rgb
	);

	always @ (posedge clk or posedge rst)
	begin
		if (rst) begin
			game_over_reg <= 0;
		end else if (p_lives == 0) begin
			game_over_reg <= 1;
		end
	end

	// sprite coordinate addresses
	wire [4:0] row;
	wire [7:0] col;
	wire [7:0] color_data;

	assign col = x - 384;
	assign row = y - 75;

	game_over_rom game_over_rom(
		.clk(clk),
		.row(row),
		.col(col),
		.color_data(color_data)
	);
	
	assign game_display_on = (x >= 384 && x < 544 && y >= 75 && y < 93 && color_data != 8'b01011101 && game_over_reg == 1) ? 1 : 0;
	assign rgb = color_data;

endmodule
