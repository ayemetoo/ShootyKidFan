
`timescale 1ns / 1ps

module tb_enemy_wave;

	// Inputs
	reg clk;
	reg dclk;
	reg rst;
	reg pause;
	reg game_start_on;
	reg game_over_on;
	reg p_on;
	reg hit_w_enemy;
	reg [9:0] x;
	reg [9:0] y;
	reg [23:0] wave_speed;

	// Outputs
	wire is_active;
	wire e_w_on;
	wire [7:0] rgb;

	integer i;

	// Instantiate the Unit Under Test (UUT)
	enemy_wave1 uut (
		.clk(clk), 
		.dclk(dclk), 
		.rst(rst), 
		.pause(pause),
		.game_start_on(game_start_on),
		.game_over_on(game_over_on),
		.p_on(p_on),
		.hit_w_enemy(hit_w_enemy),
		.x(x), 
		.y(y), 
		.wave_speed(wave_speed), 
		.is_active(is_active), 
		.e_w_on(e_w_on), 
		.rgb(rgb)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		dclk = 0;
		rst = 1;
		pause = 0;
		x = 0;
		y = 0;
		game_start_on = 0;
		game_over_on = 0;
		p_on = 0;
		hit_w_enemy = 0;
		wave_speed = 20'd948575;
				
		// Wait 100 ns for global reset to finish
		#100 rst = 0;
        
		// Add stimulus here
		for ( i = 32'd0; i < 32'd5; i = i + 1)
			#100000000;
		$finish;
	end
	
	always begin
		#5 clk <= ~clk;
	end
	always begin
		#20 dclk <= ~dclk;
	end
	
	always @ (posedge dclk or posedge rst)
	begin
		if (rst == 1) begin
		x <= 0;
		y <= 0;
		end else begin
			if (x < 743)
				x <= x + 1;
			else begin
				x <= 0;
				if (y < 520)
					y <= y + 1;
				else
					y <= 0;
			end	
		end
	end
endmodule
