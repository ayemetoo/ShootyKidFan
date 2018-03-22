`timescale 1ns / 1ps

module player_bullet(
	input clk, dclk, bulletclk, rst, pause,
	input wire b_active,						//bullet is currently active
	
	/* DISPLAY */
	input wire [9:0] x, y,     			//current position of display
	//player
	input wire [9:0] p_x, p_y,  		   //current position of player
	//enemy
	input wire e_r_on,						//vga pixel in range of roaming enemy
	input wire [4:0] e_w_on,				//vga pixel in range of wave enemies
	input wire e_r_active,					//whether the roaming enemy is currently active
	input wire [4:0] e_w_active,			//whether the wave enemy is currently active
	
	/* OUTPUT */
	//bullet
	output wire b_on,							//currently in pixel range of the bullet
	output reg b_active_d,					//next state of bullet
	//collision
	output wire [4:0] hit_w_enemy,		//enemy hit status
	output wire hit_r_enemy					//roam enemy hit status
    );

/* -------------------------------------------------------------------------------------------- */
/* CONSTANTS                                                                                    */
/* -------------------------------------------------------------------------------------------- */
	//player movement
	localparam speed = -2; //amount moved towards enemy each clock cycle

	//pixel boundaries
	localparam boundTop = 5'd31; //left horizontal bound for display
	localparam boundBottom = 9'd511; //right horizontal bound for display

	//bullet size
	localparam b_w = 2'd2; 
	localparam b_h = 3'd4;

	//bullet 
	wire [9:0] b_x, b_y;		   //current position of the bullet
	reg [9:0] b_x_next, b_y_next;
	reg [9:0] new_b_x, new_b_y;

	initial begin
		b_active_d = 1'b0;
		b_x_next = p_x + 4'd8;
		b_y_next = p_y - 4'd8; //might be the top
	end



/* -------------------------------------------------------------------------------------------- */
/* BULLET POSITION                                                                              */
/* -------------------------------------------------------------------------------------------- */

	always @(*) begin
		new_b_x <= b_x_next;
		new_b_y <= b_y_next;
	end

	reg [17:0] speed_clk;
	wire speed_tick;
		
	always @ (posedge clk or posedge rst)
	begin
		if (rst)
			speed_clk <= 0;
		else if (speed_clk < {18 {1'b1} }) //double the speed of a roaming enemy
			speed_clk <= speed_clk + 1'b1;
		else if (speed_clk >= {18 {1'b1} })
			speed_clk <= 18'b0;
	end

	assign speed_tick = (speed_clk == 18'b0);

	always @(posedge speed_tick or posedge rst or posedge pause) begin
		if (rst) begin
			b_active_d <= 1'b0;
			b_x_next <= p_x + 4'd8;
			b_y_next <= p_y - 4'd8; 
		end else if (pause) begin
			b_active_d <= b_active;
			b_x_next <= b_x;
			b_y_next <= b_y;
		end
		else if (b_active) begin
			if ((b_y + speed) > boundTop) begin
				b_x_next <= p_x + 4'd8;
				b_y_next <= b_y + speed;
				b_active_d <= 1'b1;
			end
			else begin
				b_x_next <= p_x + 4'd8;
				b_y_next <= p_y - 4'd8;
				b_active_d <= 1'b0;
			end
		end else if (!b_active) begin
			b_x_next <= p_x + 4'd8;
			b_y_next <= p_y - 4'd8;
			b_active_d <= 1'b0;
		end	
	end
	
	assign b_x = new_b_x;
	assign b_y = new_b_y;

	/* -------------------------------------------------------------------------------------------- */
	/* BULLET GENERATION                                                                            */
	/* -------------------------------------------------------------------------------------------- */
	assign b_on = ((x >= b_x) && (x <= b_x + b_w)) && ((y >= b_y) && (y <= b_y + b_h));



	/* -------------------------------------------------------------------------------------------- */
	/* BULLET COLLISION                                                                            */
	/* -------------------------------------------------------------------------------------------- */
	wire [4:0] on_w_enemy;
	wire  	  on_r_enemy;
	reg  [4:0] on_w_enemy_d;
	reg        on_r_enemy_d;

	//register enemy as hit if it is also on and is active
	assign on_w_enemy = {b_on && b_active && e_w_on[4] && e_w_active[4], 
								b_on && b_active && e_w_on[3] && e_w_active[3], 
								b_on && b_active && e_w_on[2] && e_w_active[2], 
								b_on && b_active && e_w_on[1] && e_w_active[1], 
								b_on && b_active &&  e_w_on[0] && e_w_active[0]};
	assign on_r_enemy = b_on && b_active && e_r_on && e_r_active;

	//store previous state
	always @(posedge dclk) begin
		if (rst) begin
			on_w_enemy_d <= 5'b00000;
			on_r_enemy_d <= 1'b0;
		end else begin
			on_w_enemy_d <= on_w_enemy;
			on_r_enemy_d <= on_r_enemy;
		end
	end

	//calculate if an enemy was hit or not
	assign hit_w_enemy = ~on_w_enemy_d & on_w_enemy;
	assign hit_r_enemy = ~on_r_enemy_d & on_r_enemy;
endmodule
