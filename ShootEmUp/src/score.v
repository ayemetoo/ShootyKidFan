`timescale 1ns / 1ps

/* calculate the current score of the player */
module score(
	input wire clk, dclk, rst, 
	input wire [9:0] x, y,				//position of display

	input wire [4:0] hit_w_enemy,		//number of wave enemies hit this clock cycle
	input wire hit_r_enemy,				//roaming enemy hit this clock cycle
	input wire [1:0] p_lives,				//number of lives of the player

	output reg [2:0] speed_level,	//current speed level of the enemy spawning

	output wire score_on,
	output reg [7:0] rgb		 		//display the current number of lives and such of the player
    );

	localparam boundLeft = 8'd144;	//left horizontal bound for display
	localparam boundRight = 10'd784;	//right horizontal bound for display
	localparam boundUp = 5'd31;		//up vertical bound for display
	localparam boundDown = 9'd511;	//down vertical bound for display

	localparam score_x = 8'd144;
	localparam score_y = 5'd31;
	localparam score_w = 10'd640;
	localparam score_h = 5'd20;

	reg [12:0] score;
	
	initial begin
		score = 13'd0;
		speed_level = 3'd5;
	end

	/* -------------------------------------------------------------------------------------------- */
	/* SCORE                                                                                        */
	/* -------------------------------------------------------------------------------------------- */
	always @(posedge dclk or posedge rst) begin
		if (rst)
			score <= 13'd0;
		else begin
			if (hit_w_enemy[4])
				score <= score + 13'd1;
			if (hit_w_enemy[3])
				score <= score + 13'd1;
			if (hit_w_enemy[2])
				score <= score + 13'd1;
			if (hit_w_enemy[1])
				score <= score + 13'd1;
			if (hit_w_enemy[0])
				score <= score + 13'd1;
			if (hit_r_enemy)
				score <= score + 13'd5;
		end
	end

	/* -------------------------------------------------------------------------------------------- */
	/* SPEED LEVEL                                                                                  */
	/* -------------------------------------------------------------------------------------------- */
	always @(posedge dclk) begin
		if (rst)
			speed_level <= 3'd5;
		else begin
			if (score < 7'd100)
				speed_level <= 3'd5;
			else if (score < 9'd500)
				speed_level <= 3'd4;
			else if (score < 10'd1000)
				speed_level <= 3'd3;
			else if (score < 13'd5000)
				speed_level <= 3'd2;
			else
				speed_level <= 3'd1;
		end
	end

   /* -------------------------------------------------------------------------------------------- */
   /* SCORE DISPLAY                                                                                */
   /* -------------------------------------------------------------------------------------------- */
	assign score_on = (x >= score_x) && (x <= score_x + score_w) && (y >= score_y) && (y <= score_y + score_h);

	// wires for each digit of score
	wire [3:0] s_thousand, s_hundred, s_ten, s_one;
	assign s_one = score%4'd10;
	assign s_ten = (score/4'd10)%4'd10;
	assign s_hundred = (score/7'd100)%4'd10;
	assign s_thousand = (score/10'd1000)%4'd10;

	reg [3:0] row_life;
	reg [3:0] col_life;
	wire [7:0] color_data_life, color_data_empty;

	reg [3:0] row_title;
	reg [6:0] col_title;
	wire [7:0] color_data_title;

	reg [6:0] row_digit;
	reg [3:0] col_digit;
	wire [7:0] color_data_digit;

	/* interpret life roms */
	life_full_rom life_full_rom
	(
		clk,
		row_life,
		col_life,
		color_data_life
	);

	life_empty_rom life_empty_rom
	(
		clk,
		row_life,
		col_life,
		color_data_empty
	);

	/* interpret title rom */
	title_rom title_rom
	(
		clk,
		row_title,
		col_title,
		color_data_title
	);

	/* interpret digit rom */
	digit_rom_large digit_rom_large
	(
		clk,
		row_digit,
		col_digit,
		color_data_digit
	);

	always @(*) begin
		if (score_on) begin
			/* draw lives */
			if ((x >= 8'd204) && (x < 8'd218) && (y >= 6'd38) && (y <= 6'd47)) begin //draw life 1
				row_life <= y - 6'd38;
				col_life <= x - 8'd204;
				row_digit <= 7'b0;
				col_digit <= 4'b0;
				row_title <= 4'b0;
				col_title <= 7'b0;
				if (p_lives > 0) begin //full heart
					if (color_data_life == 8'b10111011) begin //indicates transparency
						rgb <= 8'b00000000;
					end else begin
						rgb <= color_data_life;
					end
				end else begin //empty heart
					if (color_data_empty == 8'b10111011) begin //indicates transparency
						rgb <= 8'b00000000;
					end else begin
						rgb <= color_data_empty;
					end
				end
			end else if ((x >= 8'd224) && (x < 8'd238) && (y >= 6'd38) && (y <= 6'd47)) begin //draw life 2
				row_life <= y - 6'd38;
				col_life <= x - 8'd224;
				row_digit <= 7'b0;
				col_digit <= 4'b0;
				row_title <= 4'b0;
				col_title <= 7'b0;
				if (p_lives > 1) begin //full heart
					if (color_data_life == 8'b10111011) begin //indicates transparency
						rgb <= 8'b00000000;
					end else begin
						rgb <= color_data_life;
					end
				end else begin //empty heart
					if (color_data_empty == 8'b10111011) begin //indicates transparency
						rgb <= 8'b00000000;
					end else begin
						rgb <= color_data_empty;
					end
				end
			end else if ((x >= 8'd244) && (x < 9'd258) && (y >= 6'd38) && (y <= 6'd47)) begin //draw life 3
				row_life <= y - 6'd38;
				col_life <= x - 8'd244;
				row_digit <= 7'b0;
				col_digit <= 4'b0;
				row_title <= 4'b0;
				col_title <= 7'b0;
				if (p_lives > 2) begin //full heart
					if (color_data_life == 8'b10111011) begin //indicates transparency
						rgb <= 8'b00000000;
					end else begin
						rgb <= color_data_life;
					end
				end else begin //empty heart
					if (color_data_empty == 8'b10111011) begin //indicates transparency
						rgb <= 8'b00000000;
					end else begin
						rgb <= color_data_empty;
					end
				end
			end 
			
			/* draw title */
			else if ((x >= 9'd420) && (x < 9'd507) && (y >= 6'd36) && (y < 6'd49)) begin
				row_title <= y - 6'd36;
				col_title <= x - 9'd420;
				row_life  <= 4'b0;
				col_life  <= 4'b0;
				row_digit <= 7'b0;
				col_digit <= 4'b0;
				rgb <= color_data_title;
			end
			
			/* draw scores */
			else if ((x >= 10'd650) && ( x < 10'd664) && (y >= 6'd38) && (y < 6'd47)) begin //thousands
				row_digit <= (y - 6'd38) + (s_thousand * 4'd12);
				col_digit <= x - 10'd650;
				row_title <= 4'b0;
				col_title <= 7'b0;
				row_life  <= 4'b0;
				col_life  <= 4'b0;
				if (color_data_digit == 8'b10111011) begin //indicates transparency
					rgb <= 8'b00000000;
				end else begin
					rgb <= color_data_digit;
				end
			end else if ((x >= 10'd670) && ( x < 10'd684) && (y >= 6'd38) && (y < 6'd47)) begin //hundreds
				row_digit <= (y - 6'd38) + (s_hundred * 4'd12);
				col_digit <= x - 10'd670;
				row_title <= 4'b0;
				col_title <= 7'b0;
				row_life  <= 4'b0;
				col_life  <= 4'b0;
				if (color_data_digit == 8'b10111011) begin //indicates transparency
					rgb <= 8'b00000000;
				end else begin
					rgb <= color_data_digit;
				end
			end else if ((x >= 10'd690) && ( x < 10'd704) && (y >= 6'd38) && (y < 6'd47)) begin //tens
				row_digit <= (y - 6'd38) + (s_ten * 4'd12);
				col_digit <= x - 10'd690;
				row_title <= 4'b0;
				col_title <= 7'b0;
				row_life  <= 4'b0;
				col_life  <= 4'b0;
				if (color_data_digit == 8'b10111011) begin //indicates transparency
					rgb <= 8'b00000000;
				end else begin
					rgb <= color_data_digit;
				end
			end else if ((x >= 10'd710) && ( x < 10'd724) && (y >= 6'd38) && (y < 6'd47)) begin //ones
				row_digit <= (y - 6'd38) + (s_one * 4'd12);
				col_digit <= x - 10'd710;
				row_title <= 4'b0;
				col_title <= 7'b0;
				row_life  <= 4'b0;
				col_life  <= 4'b0;
				if (color_data_digit == 8'b10111011) begin //indicates transparency
					rgb <= 8'b00000000;
				end else begin
					rgb <= color_data_digit;
				end
			end else begin
				row_life  <= 4'b0;
				col_life  <= 4'b0;
				row_digit <= 7'b0;
				col_digit <= 4'b0;
				row_title <= 4'b0;
				col_title <= 7'b0;
				rgb <= 8'b00000000;
			end 
		end else begin //end score_on
			row_life  <= 4'b0;
			col_life  <= 4'b0;
			row_digit <= 7'b0;
			col_digit <= 4'b0;
			row_title <= 4'b0;
			col_title <= 7'b0;
			rgb <= 8'b00000000;
		end
	end //end always

endmodule
