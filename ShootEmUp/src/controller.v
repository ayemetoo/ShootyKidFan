`timescale 1ns / 1ps

module controller(
	input wire clk,
	input wire rst,
	
	input wire MISO,
   output wire SS,
   output wire MOSI,
   output wire SCLK,
   output reg [2:0] LED,
	output wire [3:0] AN,
	output wire [6:0] SEG,
	output wire left,
	output wire right
   );

	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================
			// Holds data to be sent to PmodJSTK
			wire [7:0] sndData;

			// Signal to send/receive data to/from PmodJSTK
			wire sndRec;

			// Data read from PmodJSTK
			wire [39:0] jstkData;

			// Signal carrying output data that user selected
			wire [9:0] posData;
			
			//Binary to BCD
			wire [15:0] bcdData;
			
			//BCD to decimal
			//wire [9:0] posValue;

	// ===========================================================================
	// 										Implementation
	// ===========================================================================


			//-----------------------------------------------
			//  	  			PmodJSTK Interface
			//-----------------------------------------------
			PmodJSTK PmodJSTK_Int(
					.CLK(clk),
					.RST(rst),
					.sndRec(sndRec),
					.DIN(sndData),
					.MISO(MISO),
					.SS(SS),
					.SCLK(SCLK),
					.MOSI(MOSI),
					.DOUT(jstkData)
			);
			


			//-----------------------------------------------
			//  		Seven Segment Display Controller
			//-----------------------------------------------
			ssdCtrl DispCtrl(
					.CLK(clk),
					.RST(rst),
					.DIN(posData),
					.AN(AN),
					.SEG(SEG),
					.bcdData(bcdData)
			);
			
			

			//-----------------------------------------------
			//  			 Send Receive Generator
			//-----------------------------------------------
			ClkDiv_5Hz genSndRec(
					.CLK(clk),
					.RST(rst),
					.CLKOUT(sndRec)
			);
			

			// If not this, it is the other one
			assign posData = {jstkData[9:8], jstkData[23:16]}; //jstkData[25:24], jstkData[39:32]};

			// Data to be sent to PmodJSTK, lower two bits will turn on leds on PmodJSTK
			assign sndData = {8'b100000, 2'b00/*{SW[1], SW[2]}*/};

			// Assign PmodJSTK button status to LED[2:0]
			always @(sndRec or rst or jstkData) begin
					if(rst == 1'b1) begin
							LED <= 3'b000;
					end
					else begin
							LED <= {jstkData[1], {jstkData[2], jstkData[0]}};
					end
			end

			//Convert the BCD value to decimal
			assign right = bcdData[11:8] < 3;
			assign left = bcdData[11:8] > 7;

endmodule

	