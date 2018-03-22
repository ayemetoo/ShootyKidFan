`timescale 1ns / 1ps

module clock_div(
	input wire clk,			//master clock: 100MHz
	input wire rst,			//asynchronous reset
	output wire dclk,			//pixel clock: 25MHz
	output wire bullet_clk, //bullet clock: ~2.98Hz
	output wire fast_clk
	);

// 26-bit counter variable
reg [25:0] q;

// Clock divider --
// Each bit in q is a clock signal that is
// only a fraction of the master clock.
always @(posedge clk or posedge rst)
begin
	// reset condition
	if (rst == 1)
		q <= 0;
	// increment counter by one
	else
		q <= q + 1;
end

// 100MHz  2^2 = 25MHz
assign dclk = q[1];

// 100MHz 2^25 = 2.98Hz --> ~3 per second
assign bullet_clk = q[23];

// 100MHz 2^17 = 762.94Hz
assign fast_clk = q[16];

endmodule
