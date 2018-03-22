`timescale 1ns / 1ps

module tb_enemy_roam;

	// Inputs
	reg clk;
	reg dclk;
	reg rst;
	reg pause;
	reg game_start_on;
	reg game_over_on;
	reg [9:0] p_x;
	reg [9:0] p_y;
	reg p_on;
	reg hit_r_enemy;
	reg [9:0] x;
	reg [9:0] y;

	// Outputs
	wire is_active;
	wire e_r_on;
	wire [7:0] rgb;
	
	// Local
	integer i;

	// Instantiate the Unit Under Test (UUT)
	enemy_roam uut (
		.clk(clk), 
		.dclk(dclk),
		.rst(rst), 
		.pause(pause), 
		.game_start_on(game_start_on), 
		.game_over_on(game_over_on), 
		.p_x(p_x), 
		.p_y(p_y), 
		.p_on(p_on), 
		.hit_r_enemy(hit_r_enemy),
		.x(x), 
		.y(y), 
		.is_active(is_active), 
		.e_r_on(e_r_on), 
		.rgb(rgb)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		dclk = 0;
		rst = 1;
		pause = 0;
		game_start_on = 0;
		game_over_on = 0;
		p_x = 244;
		p_y = 50;
		p_on = 0;
		hit_r_enemy = 0;
		x = 0;
		y = 0;

		// Wait 100 ns for global reset to finish
		#100 rst = 0;
        
		// Add stimulus here
		for ( i = 32'd0; i < 32'd5; i = i + 1) begin
			#100000000;// rst = 1;
			//#100 rst = 0;
		end
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
			if (x < 799) begin
				if (y >= p_y && y < (p_y + 16) && x >= p_x && x < (p_x + 16))
					p_on <= 1;
				else
					p_on <= 0;
				
				x <= x + 1;
			end else begin
				x <= 0;
				if (y < 520)
					y <= y + 1;
				else
					y <= 0;
			end	
		end
	end

endmodule

