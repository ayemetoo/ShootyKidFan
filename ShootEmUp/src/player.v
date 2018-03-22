`timescale 1ns / 1ps

module player(
	input clk, dclk, bulletclk, rst, pause, 
	/* CONTROLLER */
	input left, right, a,					//input from controller
	
	/* DISPLAY */
	//game start/over
	input wire game_start_on,
	input wire game_over_on,
	//pixel position
	input wire [9:0] x, y,     			//current position of display
	//enemy
	input wire e_r_on,						//vga pixel in range of roaming enemy
	input wire [4:0] e_w_on,				//vga pixel in range of wave enemies
	input wire e_r_active,					//whether the roaming enemy is currently active
	input wire [4:0] e_w_active,			//whether the wave enemy is currently active
	
	/* OUTPUT */
	//player
	output wire [9:0] p_x, p_y,  		   //current position of player
	output reg p_on,							//currently in pixel range of the player
	output wire [4:0] b_on,					//currently in pixel range of bullet
	output reg [4:0] b_active,				//bullet is currently active
	//enemy
	output wire [4:0] hit_w_enemy,		//enemy hit status
	output wire hit_r_enemy,				//roam enemy hit status
	//lives
	output reg [1:0] p_lives,				//number of lives the player has left
	
	output reg [7:0] rgb					//output rgb signal for current vga pixel
    );

	/* -------------------------------------------------------------------------------------------- */
	/* CONSTANTS                                                                                    */
	/* -------------------------------------------------------------------------------------------- */
	//player movement
	localparam moveLeft = -1; //amount moved left each clock cycle
	localparam moveRight = 1; //amount moved right each clock cycle

	//pixel boundaries
	localparam boundLeft = 8'd144; //left horizontal bound for display
	localparam boundRight = 10'd784; //right horizontal bound for display

	//player size
	localparam p_w = 5'd16; 
	localparam p_h = 5'd16;

	//player movement
	reg [9:0] new_p_x, new_p_y;
	reg [9:0] p_x_next, p_y_next;

	initial begin
		p_x_next = 9'd436; 
		p_y_next = 9'd487; 
		p_lives = 2'd3;
	end



	/* -------------------------------------------------------------------------------------------- */
	/* PLAYER POSITION                                                                              */
	/* -------------------------------------------------------------------------------------------- */

	always @(posedge dclk) begin
		new_p_x <= p_x_next;
		new_p_y <= p_y_next;
	end

	reg [18:0] speed_clk;
	wire speed_tick;
		
	always @ (posedge clk or posedge rst)
	begin
		if (rst)
			speed_clk <= 0;
		else if (speed_clk < 19'b1110000000000000000) 
			speed_clk <= speed_clk + 19'd1;
		else if (speed_clk >= 19'b1110000000000000000)
			speed_clk <= 19'd0;
	end

	assign speed_tick = (speed_clk == 19'd0);

	always @(posedge speed_tick or posedge rst or posedge pause) begin
		if (rst) begin
			p_x_next <= 9'd436; 
			p_y_next <= 9'd487;
		end else if (pause) begin
			p_x_next <= p_x;
			p_y_next <= p_y;
		end
		/* player movement */
		else begin
			if (left) begin
				if ((p_x + moveLeft) > boundLeft) begin
					p_x_next <= p_x + moveLeft;
					p_y_next <= 9'd487;
				end else begin
					p_x_next <= p_x;
					p_y_next <= 9'd487;
				end
			end else if (right) begin
				if ((p_x_next + p_w + moveRight) < boundRight) begin
					p_x_next <= p_x + moveRight;
					p_y_next <= 9'd487;
				end else begin
					p_x_next <= p_x;
					p_y_next <= 9'd487;
				end
			end else begin
				p_x_next <= p_x;
				p_y_next <= 9'd487;
			end
		end 
	end

	assign p_x = new_p_x;
	assign p_y = new_p_y;

	/* -------------------------------------------------------------------------------------------- */
	/* PLAYER DISPLAY                                                                               */
	/* -------------------------------------------------------------------------------------------- */
	reg [3:0] row;
	reg [3:0] col;
	wire [7:0] color_data;

	player_rom player_rom(
		clk,
		row,
		col,
		color_data
	);

	always @(*) begin
		row <= y - p_y;
		col <= x - p_x;
		if ((x >= p_x) && (x <= p_x + p_w) && (y >= p_y) && (y <= p_y + p_h) && (color_data != 8'b10111011)) begin //in range of player
			if (p_lives == 0) begin //no lives, display black
				p_on <= 1'b0;
				rgb <= 8'b00011111;
			end else begin //has a life 
				p_on <= 1'b1;
				rgb <= color_data;
			end
		end else begin //not p_on
			p_on <= 1'b0;
			if (b_on[0] && b_active[0]) begin
				rgb <= 8'b11111111;
			end else if (b_on[1] && b_active[1]) begin
				rgb <= 8'b11111111;
			end else if (b_on[2] && b_active[2]) begin
				rgb <= 8'b11111111;
			end else if (b_on[3] && b_active[3]) begin
				rgb <= 8'b11111111;
			end else if (b_on[4] && b_active[4]) begin
				rgb <= 8'b11111111;
			end else begin
				rgb <= 8'b00000000;
			end
		end
	end


	/* -------------------------------------------------------------------------------------------- */
	/* PLAYER COLLISION                                                                             */
	/* -------------------------------------------------------------------------------------------- */
	/* SEND A SIGNAL TO PLAYER IF AN ENEMY IS HIT */
	wire  	  on_enemy;
	reg        on_enemy_d;
	reg 		  lose_life;

	//register player as hit if it is also on and is active
	assign on_enemy = p_on && ((e_w_on[4] && e_w_active[4]) || (e_w_on[3] && e_w_active[3]) || (e_w_on[2] && e_w_active[2]) || (e_w_on[1] && e_w_active[1]) || 
							(e_w_on[0] && e_w_active[0]) || (e_r_on && e_r_active));

	//store previous state
	always @(posedge dclk) begin
		if (rst) begin
			on_enemy_d <= 1'b0;
			lose_life <= 1'b0;
		end else begin
			on_enemy_d <= on_enemy;
			lose_life <= ~on_enemy_d & on_enemy;
		end
	end

	//
	always @(posedge lose_life or posedge rst) begin
		if (rst)
			p_lives <= 2'd3;
		else
			if (p_lives == 0)
				p_lives <= 0;
			else
				p_lives <= p_lives - 1'b1;
	end



	/* -------------------------------------------------------------------------------------------- */
	/* BULLET GENERATION                                                                            */
	/* -------------------------------------------------------------------------------------------- */

	wire [4:0] b_active_d;

	always @(posedge bulletclk or posedge rst or posedge pause or posedge game_start_on or posedge game_over_on) begin
		if (rst || (p_lives == 0) || game_start_on || game_over_on) begin //if reseting or player is dead, no bullets should be active
			b_active <= 5'b0;
		end else if (pause) begin
			b_active <= b_active_d;
		end else if (a) begin //player wants to generate a bullet and is alive
			if (b_active_d[0] != 1'b1) 
				//b_active[0] <= 1'b1;
				b_active <= {b_active_d[4:1], 1'b1};
			else if (b_active_d[1] != 1'b1) 
				//b_active[1] <= 1'b1;
				b_active <= {b_active_d[4:2], 1'b1, b_active_d[0]};
			else if (b_active_d[2] != 1'b1) 
				//b_active[2] <= 1'b1;
				b_active <= {b_active_d[4:3], 1'b1, b_active_d[1:0]};
			else if (b_active_d[3] != 1'b1) 
				//b_active[3] <= 1'b1;
				b_active <= {b_active_d[4], 1'b1, b_active_d[2:0]};
			else if (b_active_d[4] != 1'b1) 
				//b_active[4] <= 1'b1;
				b_active <= {1'b1, b_active_d[3:0]};
		end else 
			b_active <= b_active_d;
	end

	/* hit registers */
	wire [4:0] hit_w_enemy1, hit_w_enemy2, hit_w_enemy3, hit_w_enemy4, hit_w_enemy5;
	wire 		  hit_r_enemy1, hit_r_enemy2, hit_r_enemy3, hit_r_enemy4, hit_r_enemy5;

	player_bullet player_bullet1(
		clk, dclk, bulletclk, rst, pause,
		b_active[0],							//bullet is currently active
		x, y,     								//current position of display
		p_x, p_y,  		   					//current position of player
		
		e_r_on,						//vga pixel in range of roaming enemy
		e_w_on,					//vga pixel in range of wave enemies
		e_r_active,					//whether the roaming enemy is currently active
		e_w_active,			//whether the wave enemy is currently active
		
		b_on[0],									//currently in pixel range of the bullet
		b_active_d[0],								//next state of bullet
			
		hit_w_enemy1,				//enemy hit status
		hit_r_enemy1				//roam enemy hit status
		);
		
	player_bullet player_bullet2(
		clk, dclk, bulletclk, rst, pause,
		b_active[1],							//bullet is currently active
		x, y,     								//current position of display
		p_x, p_y,  		   					//current position of player
		
		e_r_on,						//vga pixel in range of roaming enemy
		e_w_on,					//vga pixel in range of wave enemies
		e_r_active,					//whether the roaming enemy is currently active
		e_w_active,			//whether the wave enemy is currently active
		
		b_on[1],									//currently in pixel range of the bullet
		b_active_d[1],								//next state of bullet
		
		hit_w_enemy2,				//enemy hit status
		hit_r_enemy2    			//roam enemy hit status
		);
		
	player_bullet player_bullet3(
		clk, dclk, bulletclk, rst, pause,
		b_active[2],							//bullet is currently active
		x, y,     								//current position of display
		p_x, p_y,  		   					//current position of player
		
		e_r_on,						//vga pixel in range of roaming enemy
		e_w_on,					//vga pixel in range of wave enemies
		e_r_active,					//whether the roaming enemy is currently active
		e_w_active,			//whether the wave enemy is currently active
		
		b_on[2],									//currently in pixel range of the bullet
		b_active_d[2],								//next state of bullet
			
		hit_w_enemy3,				//enemy hit status
		hit_r_enemy3				//roam enemy hit status
		);
		
	player_bullet player_bullet4(
		clk, dclk, bulletclk, rst, pause,
		b_active[3],							//bullet is currently active
		x, y,     								//current position of display
		p_x, p_y,  		   					//current position of player
		
		e_r_on,						//vga pixel in range of roaming enemy
		e_w_on,					//vga pixel in range of wave enemies
		e_r_active,					//whether the roaming enemy is currently active
		e_w_active,			//whether the wave enemy is currently active
		
		b_on[3],									//currently in pixel range of the bullet
		b_active_d[3],								//next state of bullet
		
		hit_w_enemy4,				//enemy hit status
		hit_r_enemy4				//roam enemy hit status
		);
		
	player_bullet player_bullet5(
		clk, dclk, bulletclk, rst, pause,
		b_active[4],							//bullet is currently active
		x, y,     								//current position of display
		p_x, p_y,  		   					//current position of player
		
		e_r_on,						//vga pixel in range of roaming enemy
		e_w_on,					//vga pixel in range of wave enemies
		e_r_active,					//whether the roaming enemy is currently active
		e_w_active,			//whether the wave enemy is currently active
		
		b_on[4],									//currently in pixel range of the bullet
		b_active_d[4],								//next state of bullet
			
		hit_w_enemy5,				//enemy hit status
		hit_r_enemy5				//roam enemy hit status
		);
		
	assign hit_w_enemy = hit_w_enemy1 | hit_w_enemy2 | hit_w_enemy3 | hit_w_enemy4 | hit_w_enemy5;
	assign hit_r_enemy = hit_r_enemy1 | hit_r_enemy2 | hit_r_enemy3 | hit_r_enemy4 | hit_r_enemy5;

endmodule
