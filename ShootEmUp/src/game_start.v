`timescale 1ns / 1ps

module game_start(
	input clk, rst,
	input wire [9:0] x, y,
	output wire game_display_on,
	output reg game_start_reg,
	output wire [7:0] rgb
	);

	reg [25:0] idle_time;
	reg [2:0] count;
	reg tracker;

	// game_start is active for about 3 seconds
	always @ (posedge clk or posedge rst)
	begin
		if (rst) begin
			idle_time <= 0;
			count <= 0;
			tracker <= 0;
			game_start_reg <= 1;
		end else if (tracker == 0) begin
			if (idle_time < 26'd50000000 && count < 3'd5) begin
				idle_time <= idle_time + 1'b1;
			end else if (idle_time == 26'd50000000 && count < 3'd5) begin
				idle_time <= 0;
				count <= count + 1'd1;
			end else if (count == 3'd5) begin
				tracker <= 1;
			end
		end else if (tracker == 1) begin
			game_start_reg <= 0;
		end
	end

	// sprite coordinate addresses
	wire [4:0] row;
	wire [7:0] col;
	wire [7:0] color_data;

	assign col = x - 375;
	assign row = y - 74;

	game_start_rom game_start_rom(
		.clk(clk),
		.row(row),
		.col(col),
		.color_data(color_data)
	);
	
	assign game_display_on = (x >= 375 && x < 553 && y >= 74 && y < 93 && color_data != 8'b01011101 && game_start_reg == 1) ? 1 : 0;
	assign rgb = color_data;
	
endmodule
