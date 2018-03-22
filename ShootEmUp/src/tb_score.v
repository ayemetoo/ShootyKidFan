`timescale 1ns / 1ps

module tb_score;

	// Inputs
	reg clk;
	reg dclk;
	reg rst;
	reg [9:0] x;
	reg [9:0] y;
	reg [4:0] hit_w_enemy;
	reg hit_r_enemy;
	reg [1:0] p_lives;

	// Outputs
	wire [2:0] speed_level;
	wire score_on;
	wire [7:0] rgb;

	// Instantiate the Unit Under Test (UUT)
	score uut (
		.clk(clk), 
		.dclk(dclk), 
		.rst(rst), 
		.x(x), 
		.y(y), 
		.hit_w_enemy(hit_w_enemy), 
		.hit_r_enemy(hit_r_enemy), 
		.p_lives(p_lives), 
		.speed_level(speed_level), 
		.score_on(score_on),
		.rgb(rgb)
	);

	//Misc
	integer i, j;

	initial begin
		// Initialize Inputs
		clk = 1;
		dclk = 1;
		rst = 1;
		x = 0;
		y = 0;
		hit_w_enemy = 0;
		hit_r_enemy = 0;
		p_lives = 3;

		// Wait 10 ns for global reset to finish
		#10;
      rst = 0;
		// Add stimulus here
		for (j = 10'd31; j < 10'd511; j= j+1) begin
			for (i = 10'd144; i < 10'd784; i= i+1) begin
				@(posedge dclk);
				x = i;
				y = j;
			end
		end
		$finish;
	end
     
	always begin
		#5 clk = ~clk;
	end
	
	always begin
		#10 dclk = ~dclk;
	end
endmodule

