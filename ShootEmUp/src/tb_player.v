`timescale 1ns / 1ps

module tb_player;

	// Inputs
	reg clk;
	reg dclk;
	reg bulletclk;
	reg rst;
	reg pause;
	reg left;
	reg right;
	reg a;
	reg game_start_on;
	reg game_over_on;
	reg [9:0] x;
	reg [9:0] y;
	reg e_r_on;
	reg [4:0] e_w_on;
	reg e_r_active;
	reg [4:0] e_w_active;

	// Outputs
	wire [9:0] p_x;
	wire [9:0] p_y;
	wire p_on;
	wire [4:0] b_on;
	wire [4:0] b_active;
	wire [4:0] hit_w_enemy;
	wire hit_r_enemy;
	wire [1:0] p_lives;
	wire [7:0] rgb;

	// Instantiate the Unit Under Test (UUT)
	player uut (
		.clk(clk), 
		.dclk(dclk), 
		.bulletclk(bulletclk), 
		.rst(rst), 
		.pause(pause),
		.left(left), 
		.right(right), 
		.a(a), 
		.game_start_on(game_start_on),
	   .game_over_on(game_over_on),
		.x(x), 
		.y(y), 
		.e_r_on(e_r_on), 
		.e_w_on(e_w_on), 
		.e_r_active(e_r_active), 
		.e_w_active(e_w_active), 
		.p_x(p_x), 
		.p_y(p_y), 
		.p_on(p_on), 
		.b_on(b_on), 
		.b_active(b_active), 
		.hit_w_enemy(hit_w_enemy), 
		.hit_r_enemy(hit_r_enemy), 
		.p_lives(p_lives), 
		.rgb(rgb)
	);

	//variables
	integer i, j, k;

	initial begin
		// Initialize Inputs
		clk = 1;
		dclk = 1;
		bulletclk = 1;
		rst = 1;
		pause = 0;
		left = 0;
		right = 0;
		a = 0;
		game_start_on = 0;
		game_over_on = 0;
		x = 0;
		y = 0;
		e_r_on = 0;
		e_w_on = 0;
		e_r_active = 0;
		e_w_active = 0;

		// Wait 100 ns for global reset to finish
		#10;
      rst = 0;  
		left = 1;
		a = 1;
		// Add stimulus here
		for (k = 8'd0; k < 9'd256; k = k+1) begin
			//move left, move right
			
			//shoot
			
			//pause
		
			for (j = 10'd31; j < 10'd511; j= j+1) begin
				for (i = 10'd144; i < 10'd784; i= i+1) begin
					@(posedge dclk);
					x = i;
					y = j;
				end
			end
		end
		$finish;
	end
	
	always begin
		#1 clk = ~clk;
	end
	
	always begin
		#2 dclk = ~dclk;
	end
	
		always begin
		#5 bulletclk = ~bulletclk;
	end
      
endmodule

