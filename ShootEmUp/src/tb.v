`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:41:19 03/09/2018
// Design Name:   game_top
// Module Name:   C:/Users/Leila/Documents/CSM152A/ShootEmUp/src/tb.v
// Project Name:  ShootEmUp
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: game_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb;

	// Inputs
	reg clk;
	reg rst;
	reg a;
	reg b;
	reg pause;

	// Outputs
	wire [7:0] rgb;
	wire hsync;
	wire vsync;

	//reg dclk;
	//reg enemy_clk;
	integer i;

	// Instantiate the Unit Under Test (UUT)
	game_top uut (
		.clk(clk), 
		.rst(rst),
		.a(a),
		.b(b),
		.pause(pause),
		.rgb(rgb),
		.hsync(hsync), 
		.vsync(vsync)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		a = 0;
		b = 0;
		pause = 0;

		// Wait 100 ns for global reset to finish
		#100 rst = 0;
		
		#10000000 pause = 1;
		
		#100 pause = 0;
		
		// Add stimulus here
		for ( i = 32'd0; i < 32'd2; i = i + 1)
			#100000000;
		$finish;
	end
   
	always begin
		#5 clk <= ~clk;
	end
	/*
	always begin
		#20 dclk <= ~dclk;
	end
	always begin
		#335544320 enemy_clk <= ~enemy_clk;
	end
	*/
endmodule

