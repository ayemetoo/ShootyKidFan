`timescale 1ns / 1ps

module enemy_roam(
	input clk, dclk, rst, pause,
	input wire game_start_on,			// game start screen is active
	input wire game_over_on,			// game over screen is active
	input wire [9:0] p_x, p_y, 		// current pixel location of player
	input wire p_on,
	input wire hit_r_enemy,				// roam enemy hit status
	input wire [9:0] x, y, 				// x and y counters for position (from vga)
	output reg is_active, 				// if enemy is alive or not
	output e_r_on,							// pixel signal
	output wire [7:0] rgb
	);
	
	localparam boundLeft = 144;	// left horizontal bound for display
	localparam boundRight = 784;	// right horizontal bound for display
	localparam boundUp = 31;		// up vertical bound for display
	localparam boundDown = 511;	// down vertical bound for display
		
	// registers for position
	reg [9:0] new_x, new_y;
	reg [9:0] new_x_next, new_y_next;
	
	wire [9:0] e_r_x, e_r_y; 	// output vector of enemy position; only y moves for the wave enemies
	
	initial begin
		new_x_next = 244;
		new_y_next = boundUp;
		position_num = 1;
	end
	
	always @ (posedge clk)
	begin
		new_x = new_x_next;
		new_y = new_y_next;
	end

	// alive status
	reg is_active_next;
	always @ (posedge clk)
	begin
		is_active <= is_active_next;
	end	

	/* -------------------------------------------------------------------------------------------- */
	/* COLLISION		                                                                              */
	/* -------------------------------------------------------------------------------------------- */
	
	// if an enemy encounters a player or bullet, it should die (is_active = 0)
	
	reg [2:0] position_num;
	
	always @ (posedge dclk or posedge rst)
	begin
		if (rst) begin
			is_active_next <= 0;
		end else if (is_active) begin
			if ( (e_r_on && p_on) || (e_r_on && hit_r_enemy) || (new_y >= boundDown - 1) )
				is_active_next <= 0;
		end else if (!is_active) begin
			if (!game_start_on && !game_over_on && new_y == boundUp)
				is_active_next <= 1;			
		end
	end
	
	/* -------------------------------------------------------------------------------------------- */
	/* MOVEMENT			                                                                              */
	/* -------------------------------------------------------------------------------------------- */
	
	// sets the speed of the roam enemy
	reg [18:0] speed_clk;
	wire speed_tick;
	
	always @ (posedge clk or posedge rst)
	begin
		if (rst)
			speed_clk <= 0;
		else if (speed_clk < {19 {1'b1} }) // roaming enemies are fixed to ~190.74Hz
			speed_clk <= speed_clk + 1;
		else if (speed_clk >= {19 {1'b1} })
			speed_clk <= 0;
	end

	assign speed_tick = (speed_clk == 0);
	
	always @ (posedge speed_tick or posedge rst)
	begin
		if (rst) begin
			new_y_next = boundUp;
			new_x_next = 244;
			position_num = 1;
		end else if (is_active && !pause) begin			
			if (new_y < boundDown - 1)
				new_y_next = new_y + 1; // moves down the screen (positive)
			else if (new_y >= boundDown - 1) begin
				new_y_next = boundUp;
			end
			
			// tracks the player and moves accordingly
			// (since the player is at the bottom of the screen, it does not need to be applied to the y position)
			if (new_x < boundRight && new_x > boundLeft) begin				
				if (p_x < new_x) 
					new_x_next = new_x - 1;
				else if (p_x > new_x)
					new_x_next = new_x + 1;
				else if (p_x == new_x)
					new_x_next = new_x;
			end
			
		end else if (!is_active) begin
			// sets position_num to a number between 0 and 3 (for spawn points)
			if (position_num == 3'b100) begin
				position_num = 3'b000;
			end else if (position_num < 3'b100) begin			
				position_num = position_num + 1;
			end
		
			// sets the x position to the next spot
			case (position_num)
				3'b000: new_x_next = 244;
				3'b001: new_x_next = 372;
				3'b010: new_x_next = 380;
				3'b011: new_x_next = 500;
				default: new_x_next = 244;
			endcase

			// sets the y position to the top of the screen
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
  
	enemy_roam_rom enemy_roam_rom(
		.clk(clk),
		.row(row),
		.col(col),
		.color_data(color_data)
	);
	
	// border of enemy sprites
	wire pixel_range;
	assign pixel_range = (x >= new_x && x < new_x + 16 && y >= new_y && y < new_y + 16) ? 1 : 0;
	
	// outputs the signal when it's not the background color of the sprite (so it's essentially transparent)
	assign e_r_on = (pixel_range && color_data != 8'b10111011 && is_active) ? 1 : 0;

	assign rgb = color_data;

endmodule
