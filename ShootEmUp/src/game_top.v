`timescale 1ns / 1ps
module game_top(
	input clk, rst, a, pause,
	output wire [7:0] rgb,	//output rgb signal for current vga pixel
	output wire hsync,		//horizontal sync out
	output wire vsync, 		//vertical sync out
	input wire MISO,
   output wire SS,
   output wire MOSI,
   output wire SCLK,
	output wire [2:0] LED,
	output wire [6:0] SEG,
	output wire [3:0] AN
	);

	/* INITIALIZATION */
	// clocks
	wire dclk, bullet_clk, fast_clk;

	// controller info
	wire left;
	wire right;

	//call the clock divider, which should divide for: VGA, player movement, bullet movement, wave enemy movement, and roam enemy movement
	clock_div clock_div(
		.clk(clk),						//master clock: 100MHz
		.rst(rst),						//asynchronous reset
		.dclk(dclk),					//pixel clock: 25MHz
		.bullet_clk(bullet_clk),	//bullet clock: ~2.98Hz
		.fast_clk(fast_clk)
	);


	//call the controller, which will also be passed into the display to control the player
	controller controller(
		.clk(clk),
		.rst(rst),
		.MISO(MISO),
		.SS(SS),
		.MOSI(MOSI),
		.SCLK(SCLK),
		.LED(LED),
		.AN(AN),
		.SEG(SEG),
		.left(left),
		.right(right)
	);

	/* -------------------------------------------------------------------------------------------- */
	/* DEBOUNCING		                                                                              */
	/* -------------------------------------------------------------------------------------------- */

	wire a_db, b_db, pause_db;

	
	debouncer debouncer_A(
		.clk(clk),
		.fast_clk(fast_clk),
		.rst(rst),
		.b_in(a),
		.b_out(a_db)
	);
	debouncer debouncer_pause(
		.clk(clk),
		.fast_clk(fast_clk),
		.rst(rst),
		.b_in(pause),
		.b_out(pause_db)
	);

	reg pause_enable;

	initial begin
		pause_enable = 1'b0;
	end

	always @ (posedge pause_db)
	begin
		pause_enable <= ~pause_enable;
	end

	/* -------------------------------------------------------------------------------------------- */
	/* DISPLAY			                                                                              */
	/* -------------------------------------------------------------------------------------------- */

	//call the display, which should have as submodules the players and stuff, as well as controller data
	display display(
		.clk(clk),											//master clock: 100MHz
		.dclk(dclk),										//pixel clock: 25MHz
		.bullet_clk(bullet_clk),						//bullet clock: ~2.98Hz
		.rst(rst),											//asynchronous reset
		.hsync(hsync),										//horizontal sync out
		.vsync(vsync),										//vertical sync out
		.rgb(rgb),											//output rgb signal for current vga pixel
		.left(left), .right(right), .a(a_db), .pause(pause_enable)	//input from controller
	);

	//cry ;-;

endmodule
