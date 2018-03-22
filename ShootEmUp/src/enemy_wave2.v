`timescale 1ns / 1ps

module enemy_wave2(
	input clk, dclk, rst, pause,
	input wire game_start_on,
	input wire game_over_on,
	input wire p_on,						// vga pixel in range of player
	input wire hit_w_enemy,				// wave enemy hit status
	input wire [9:0] x, y, 				// x and y counters for position (from vga)
	input wire [23:0] wave_speed,		// speed of wave enemy (calculated from score)
	output reg is_active, 				// if enemy is alive or not
	output wire e_w_on,					// pixel signal
	output wire [7:0] rgb
	);
	
	localparam boundLeft = 144;	//left horizontal bound for display
	localparam boundRight = 784;	//right horizontal bound for display
	localparam boundUp = 31;		//up vertical bound for display
	localparam boundDown = 511;	//down vertical bound for display
	
	// registers for position
	reg [9:0] new_x, new_y;
	reg [9:0] new_y_next;
	
	initial begin
		new_x = 308;
		new_y_next = boundUp;
	end

	// alive status
	reg is_active_next;
	
	always @ (posedge clk)
	begin
		new_y <= new_y_next;
		is_active <= is_active_next;
	end

	/* -------------------------------------------------------------------------------------------- */
	/* COLLISION		                                                                              */
	/* -------------------------------------------------------------------------------------------- */
	
	// if an enemy encounters a player or bullet, it should die (is_active = 0)
	
	always @ (posedge dclk or posedge rst)
	begin
		if (rst) begin
			is_active_next <= 0;
		end else if (is_active) begin
			if ( (e_w_on && p_on) || (e_w_on && hit_w_enemy) || (new_y >= boundDown - 1) )
				is_active_next <= 0;
		end else if (!is_active) begin
			if (!game_start_on && !game_over_on && new_y == boundUp)
				is_active_next <= 1;
		end
	end
	
	/* -------------------------------------------------------------------------------------------- */
	/* MOVEMENT			                                                                              */
	/* -------------------------------------------------------------------------------------------- */
	
	// set a variable based on score parameter
	reg [23:0] speed_clk;
	wire speed_tick;

	always @ (posedge clk or posedge rst)
	begin
		if (rst)
			speed_clk <= 0;
		else if (speed_clk < wave_speed)
			speed_clk <= speed_clk + 1;
		else if (speed_clk >= wave_speed)
			speed_clk <= 0;
	end

	assign speed_tick = (speed_clk == 0);
	
	always @ (posedge speed_tick or posedge rst)
	begin
		if (rst) begin
			new_y_next = boundUp;
		end else if (is_active && !pause) begin
			if (new_y < boundDown - 1)
				new_y_next = new_y + 1; // moves down the screen (positive)
			else if (new_y >= boundDown - 1) begin
				new_y_next = boundUp;
			end
		end else if (!is_active) begin
			new_y_next = boundUp;
		end
	end
	
	/* -------------------------------------------------------------------------------------------- */
	/* SPRITE DISPLAY	                                                                              */
	/* -------------------------------------------------------------------------------------------- */
	
	// sprite coordinate addresses
	wire [3:0] row;
	wire [3:0] col;
	wire [7:0] color_data;
  
	assign col = x - new_x;
	assign row = y - new_y;
  
	enemy_wave_rom enemy_wave_rom(
		.clk(clk),
		.row(row),
		.col(col),
		.color_data(color_data)
	);
	
	// border of enemy sprites
	wire pixel_range;
	assign pixel_range = (x >= new_x && x < new_x + 16 && y >= new_y && y < new_y + 16) ? 1 : 0;
	
	// outputs the signal when it's not the background color of the sprite (so it's essentially transparent)
	assign e_w_on = (pixel_range && color_data != 8'b10111011 && is_active) ? 1 : 0;

	assign rgb = color_data;

endmodule
