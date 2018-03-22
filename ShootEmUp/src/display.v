`timescale 1ns / 1ps

/* takes all displayed objects */

module display(
	input clk, dclk, bullet_clk, rst,	// clocks from clock_div and asynchronous reset
	input left, right, a, pause,					// input from controller and board
	output wire hsync,									// horizontal sync out
	output wire vsync,									// vertical sync out
	output wire [7:0] rgb								// values of red, green, and blue bits
	);

	// video structure constants
	parameter hpixels = 800;	// horizontal pixels per line
	parameter vlines = 521; 	// vertical lines per frame
	parameter hpulse = 96; 		// hsync pulse length
	parameter vpulse = 2; 		// vsync pulse length
	parameter hbp = 144; 		// end of horizontal back porch
	parameter hfp = 784; 		// beginning of horizontal front porch
	parameter vbp = 31; 			// end of vertical back porch
	parameter vfp = 511; 		// beginning of vertical front porch
	// active horizontal video is therefore: 784 - 144 = 640
	// active vertical video is therefore: 511 - 31 = 480

	// registers for storing the horizontal & vertical counters
	reg [9:0] hc;
	reg [9:0] vc;

	/* -------------------------------------------------------------------------------------------- */
	/* VGA COUNTER		                                                                              */
	/* -------------------------------------------------------------------------------------------- */
	
	always @(posedge dclk or posedge rst)
	begin
		// reset condition
		if (rst == 1) begin
			hc <= 0;
			vc <= 0;
		end else begin
			// keep counting until the end of the line
			if (hc < hpixels - 1) begin
				hc <= hc + 1;
			end else begin
			// When we hit the end of the line, reset the horizontal
			// counter and increment the vertical counter.
			// If vertical counter is at the end of the frame, then
			// reset that one too.
				hc <= 0;
				if (vc < vlines - 1)
					vc <= vc + 1;
				else
					vc <= 0;
			end	
		end
	end	
	
	//wire [9:0] hc_out;							// horizontal pixel counter
	//wire [9:0] vc_out;						// vertical pixel counter

	// generate sync pulses (active low)
	// ----------------
	// "assign" statements are a quick way to
	// give values to variables of type: wire
	assign hsync = (hc < hpulse) ? 0:1;
	assign vsync = (vc < vpulse) ? 0:1;
	//assign hc_out = hc;
	//assign vc_out = vc;
	
	/* -------------------------------------------------------------------------------------------- */
	/* INITIALIZATION	                                                                              */
	/* -------------------------------------------------------------------------------------------- */
	
	// player initialization
	wire [9:0] p_x, p_y;  		   // current position of player
	wire p_on;							// currently in pixel range of the player
	wire [4:0] b_on;					// currently in pixel range of bullet
	wire [4:0] b_active;				// bullet is currently active
	wire [4:0] hit_w_enemy;			// wave enemy hit status
	wire hit_r_enemy;					// roam enemy hit status
	wire [1:0] p_lives;				// number of lives of the player
	
	// enemy initialization
	wire e_r_on;						// vga pixel in range of roaming enemy
	wire [4:0] e_w_on;				// vga pixel in range of wave enemies
	wire e_r_active;					// whether the roaming enemy is currently active
	wire [4:0] e_w_active;			// whether the wave enemy is currently active
	
	// score data
	wire [12:0] score;				// current score, based off of number of enemies hit
	wire [2:0] speed_level;			// current speed level of the enemy spawning
	wire score_on;
	
	// game over/start stuff
	wire game_sdisplay_on;
	wire game_odisplay_on;
	wire game_start_on;
	wire game_over_on;
	
	// enemy and player pixel data
	wire [7:0] p_rgb;
	wire [7:0] b1_rgb;
	wire [7:0] b2_rgb;
	wire [7:0] b3_rgb;
	wire [7:0] b4_rgb;
	wire [7:0] b5_rgb;
	wire [7:0] e_r_rgb;
	wire [7:0] e_w1_rgb;
	wire [7:0] e_w2_rgb;
	wire [7:0] e_w3_rgb;
	wire [7:0] e_w4_rgb;
	wire [7:0] e_w5_rgb;
	wire [7:0] score_rgb;
	wire [7:0] background_rgb;
	wire [7:0] game_start_rgb;
	wire [7:0] game_over_rgb;
	
	wire [23:0] current_speed;
	
	// starting tick: 95.37Hz ; max tick: 182.29Hz
	assign current_speed = {20 { 1'b1}} - ((3'd6 - speed_level) * 17'b11000011010100000); // 100,000 in dec

	/* -------------------------------------------------------------------------------------------- */
	/* INSTANTIATION	                                                                              */
	/* -------------------------------------------------------------------------------------------- */

	// sets a game start screen at beginning as a warning
	game_start game_start(
		.clk(clk),
		.rst(rst),
		.x(hc), .y(vc),
		.game_display_on(game_sdisplay_on),
		.game_start_reg(game_start_on),
		.rgb(game_start_rgb)
	);

	// sets a game over screen once the player has died
	game_over game_over(
		.clk(clk),
		.rst(rst),
		.x(hc), .y(vc),
		.p_lives(p_lives),
		.game_display_on(game_odisplay_on),
		.game_over_reg(game_over_on),
		.rgb(game_over_rgb)
	);
	
	// calls the enemy modules and keeps track of their movement and such
	enemy_wave1 enemy_wave1(
		.clk(clk), .dclk(dclk), .rst(rst), .pause(pause),
		.game_start_on(game_start_on),		// game start screen is active
		.game_over_on(game_over_on),			// game over screen is active
		.p_on(p_on),								// vga pixel in range of player
		.hit_w_enemy(hit_w_enemy[0]),			// signal that is 1 when a bullet has hit a wave enemy
		.x(hc), .y(vc), 							// x and y counters for position (from vga)
		.wave_speed(current_speed),			// speed of wave enemy (calculated from score)
		.is_active(e_w_active[0]),				// is on whenever an enemy is active/alive
		.e_w_on(e_w_on[0]),						// vga pixel in range of wave enemy
		.rgb(e_w1_rgb)								// color data
	);
	enemy_wave2 enemy_wave2(
		.clk(clk), .dclk(dclk), .rst(rst), .pause(pause),
		.game_start_on(game_start_on),		// game start screen is active
		.game_over_on(game_over_on),			// game over screen is active
		.p_on(p_on),								// vga pixel in range of player
		.hit_w_enemy(hit_w_enemy[1]),			// signal that is 1 when a bullet has hit a wave enemy
		.x(hc), .y(vc), 							// x and y counters for position (from vga)
		.wave_speed(current_speed),			// speed of wave enemy (calculated from score)
		.is_active(e_w_active[1]),				// is on whenever an enemy is active/alive
		.e_w_on(e_w_on[1]),						// vga pixel in range of wave enemy
		.rgb(e_w2_rgb)								// color data
	);
	enemy_wave3 enemy_wave3(
		.clk(clk), .dclk(dclk), .rst(rst), .pause(pause),
		.game_start_on(game_start_on),		// game start screen is active
		.game_over_on(game_over_on),			// game over screen is active
		.p_on(p_on),								// vga pixel in range of player
		.hit_w_enemy(hit_w_enemy[2]),			// signal that is 1 when a bullet has hit a wave enemy
		.x(hc), .y(vc), 							// x and y counters for position (from vga)
		.wave_speed(current_speed),			// speed of wave enemy (calculated from score)
		.is_active(e_w_active[2]),				// is on whenever an enemy is active/alive
		.e_w_on(e_w_on[2]),						// vga pixel in range of wave enemy
		.rgb(e_w3_rgb)								// color data
	);
	enemy_wave4 enemy_wave4(
		.clk(clk), .dclk(dclk), .rst(rst), .pause(pause),
		.game_start_on(game_start_on),		// game start screen is active
		.game_over_on(game_over_on),			// game over screen is active
		.p_on(p_on),								// vga pixel in range of player
		.hit_w_enemy(hit_w_enemy[3]),			// signal that is 1 when a bullet has hit a wave enemy
		.x(hc), .y(vc), 							// x and y counters for position (from vga)
		.wave_speed(current_speed),			// speed of wave enemy (calculated from score)
		.is_active(e_w_active[3]),				// is on whenever an enemy is active/alive
		.e_w_on(e_w_on[3]),						// vga pixel in range of wave enemy
		.rgb(e_w4_rgb)								// color data
	);
	enemy_wave5 enemy_wave5(
		.clk(clk), .dclk(dclk), .rst(rst), .pause(pause),
		.game_start_on(game_start_on),		// game start screen is active
		.game_over_on(game_over_on),			// game over screen is active
		.p_on(p_on),								// vga pixel in range of player
		.hit_w_enemy(hit_w_enemy[4]),			// signal that is 1 when a bullet has hit a wave enemy
		.x(hc), .y(vc), 							// x and y counters for position (from vga)
		.wave_speed(current_speed),			// speed of wave enemy (calculated from score)
		.is_active(e_w_active[4]),				// is on whenever an enemy is active/alive
		.e_w_on(e_w_on[4]),						// vga pixel in range of wave enemy
		.rgb(e_w5_rgb)								// color data
	);
	
	enemy_roam enemy_roam(
		.clk(clk), .dclk(dclk), .rst(rst), .pause(pause),
		.game_start_on(game_start_on),		// game start screen is active
		.game_over_on(game_over_on),			// game over screen is active
		.p_x(p_x), .p_y(p_y), 					// current pixel location of player
		.p_on(p_on),								// vga pixel in range of player
		.hit_r_enemy(hit_r_enemy),				// roam enemy hit status
		.x(hc), .y(vc), 							// x and y counters for position (from vga)
		.is_active(e_r_active),					// is on whenever the roam is active/alive
		.e_r_on(e_r_on),							// vga pixel in range of wave enemy
		.rgb(e_r_rgb)								// color data
	);

	// calls the player module and keeps track of the player's movement and bullets
	player player(
		.clk(clk), .dclk(dclk), .bulletclk(bullet_clk), .rst(rst), .pause(pause),
		.left(left), .right(right), .a(a),	// input from controller
		.game_start_on(game_start_on),		// game start screen is active
		.game_over_on(game_over_on),			// game over screen is active
		.x(hc), .y(vc),     						// current position of display
		.e_r_on(e_r_on),							// vga pixel in range of roaming enemy
		.e_w_on(e_w_on),			 				// vga pixel in range of wave enemies
		.e_r_active(e_r_active),				// whether the roaming enemy is active/alive
		.e_w_active(e_w_active),				// whether the wave enemies are active/alive
		.p_x(p_x), .p_y(p_y),  		   		// current position of player
		.p_on(p_on), .b_on(b_on),				// currently in pixel range of the player
		.b_active(b_active),						// bullet is currently active
		.hit_w_enemy(hit_w_enemy),				// wave enemy hit status
		.hit_r_enemy(hit_r_enemy),				// roam enemy hit status
		.p_lives(p_lives),						// number of lives
		.rgb(p_rgb)									// output rgb signal for current vga pixel
	);

	// call the score top module
	score score_(
		.clk(clk),
		.dclk(dclk),
		.rst(rst),
		.x(hc), .y(vc),							// position of display
		.hit_w_enemy(hit_w_enemy),				// number of wave enemies hit this clock cycle
		.hit_r_enemy(hit_r_enemy),				// roaming enemy hit this clock cycle
		.p_lives(p_lives),						// number of lives of the player
		.speed_level(speed_level),				// current speed level of the enemy spawning
		.score_on(score_on),
		.rgb(score_rgb)
	);
	
	// gets the background texture rgb data
	bg_rom bg_rom(
		.clk(clk),
		.row(vc[4:0]),
		.col(hc[4:0]),
		.color_data(background_rgb)
	);
		
	
	/* -------------------------------------------------------------------------------------------- */
	/* VGA DISPLAY		                                                                              */
	/* -------------------------------------------------------------------------------------------- */

	reg [7:0] rgb_prev, rgb_reg;
	
	always @*
	begin
		if (game_sdisplay_on)
			rgb_prev = game_start_rgb;
		else if (game_odisplay_on)
			rgb_prev = game_over_rgb;
		else if (score_on)
			rgb_prev = score_rgb;
		else if (p_on && !game_start_on)
			rgb_prev = p_rgb;
		else if (b_on[0] && b_active[0] && !game_start_on)
			rgb_prev = p_rgb;
		else if (b_on[1] && b_active[1] && !game_start_on)
			rgb_prev = p_rgb;
		else if (b_on[2] && b_active[2] && !game_start_on)
			rgb_prev = p_rgb;
		else if (b_on[3] && b_active[3] && !game_start_on)
			rgb_prev = p_rgb;
		else if (b_on[4] && b_active[4] && !game_start_on)
			rgb_prev = p_rgb;
		else if (e_w_on[0] && !game_start_on)
			rgb_prev = e_w1_rgb;
		else if (e_w_on[1] && !game_start_on)
			rgb_prev = e_w2_rgb;
		else if (e_w_on[2] && !game_start_on)
			rgb_prev = e_w3_rgb;
		else if (e_w_on[3] && !game_start_on)
			rgb_prev = e_w4_rgb;
		else if (e_w_on[4] && !game_start_on)
			rgb_prev = e_w5_rgb;
		else if (e_r_on && !game_start_on)
			rgb_prev = e_r_rgb;
		else
			rgb_prev = background_rgb;
	end

	always @ (posedge dclk)
	begin
		rgb_reg <= rgb_prev;
	end

	assign rgb = rgb_reg;

endmodule
