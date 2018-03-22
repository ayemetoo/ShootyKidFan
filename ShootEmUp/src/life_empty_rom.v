module life_empty_rom
	(
		input wire clk,
		input wire [3:0] row,
		input wire [3:0] col,
		output reg [7:0] color_data
	);

	(* rom_style = "block" *)

	//signal declaration
	reg [3:0] row_reg;
	reg [3:0] col_reg;

	always @(posedge clk)
		begin
		row_reg <= row;
		col_reg <= col;
		end

	always @*
	case ({row_reg, col_reg})
		8'b00000000: color_data = 8'b10111011;
		8'b00000001: color_data = 8'b10111011;
		8'b00000010: color_data = 8'b10111011;
		8'b00000011: color_data = 8'b11111111;
		8'b00000100: color_data = 8'b11111111;
		8'b00000101: color_data = 8'b10111011;
		8'b00000110: color_data = 8'b10111011;
		8'b00000111: color_data = 8'b10111011;
		8'b00001000: color_data = 8'b10111011;
		8'b00001001: color_data = 8'b11111111;
		8'b00001010: color_data = 8'b11111111;
		8'b00001011: color_data = 8'b10111011;
		8'b00001100: color_data = 8'b10111011;
		8'b00001101: color_data = 8'b10111011;

		8'b00010000: color_data = 8'b10111011;
		8'b00010001: color_data = 8'b10111011;
		8'b00010010: color_data = 8'b11111111;
		8'b00010011: color_data = 8'b10111011;
		8'b00010100: color_data = 8'b10111011;
		8'b00010101: color_data = 8'b11111111;
		8'b00010110: color_data = 8'b10111011;
		8'b00010111: color_data = 8'b10111011;
		8'b00011000: color_data = 8'b11111111;
		8'b00011001: color_data = 8'b10111011;
		8'b00011010: color_data = 8'b10111011;
		8'b00011011: color_data = 8'b11111111;
		8'b00011100: color_data = 8'b10111011;
		8'b00011101: color_data = 8'b10111011;

		8'b00100000: color_data = 8'b10111011;
		8'b00100001: color_data = 8'b11111111;
		8'b00100010: color_data = 8'b10111011;
		8'b00100011: color_data = 8'b10111011;
		8'b00100100: color_data = 8'b10111011;
		8'b00100101: color_data = 8'b10111011;
		8'b00100110: color_data = 8'b11111111;
		8'b00100111: color_data = 8'b11111111;
		8'b00101000: color_data = 8'b10111011;
		8'b00101001: color_data = 8'b10111011;
		8'b00101010: color_data = 8'b10111011;
		8'b00101011: color_data = 8'b10111011;
		8'b00101100: color_data = 8'b11111111;
		8'b00101101: color_data = 8'b10111011;

		8'b00110000: color_data = 8'b10111011;
		8'b00110001: color_data = 8'b11111111;
		8'b00110010: color_data = 8'b10111011;
		8'b00110011: color_data = 8'b10111011;
		8'b00110100: color_data = 8'b10111011;
		8'b00110101: color_data = 8'b10111011;
		8'b00110110: color_data = 8'b10111011;
		8'b00110111: color_data = 8'b10111011;
		8'b00111000: color_data = 8'b10111011;
		8'b00111001: color_data = 8'b10111011;
		8'b00111010: color_data = 8'b10111011;
		8'b00111011: color_data = 8'b10111011;
		8'b00111100: color_data = 8'b11111111;
		8'b00111101: color_data = 8'b10111011;

		8'b01000000: color_data = 8'b10111011;
		8'b01000001: color_data = 8'b11111111;
		8'b01000010: color_data = 8'b10111011;
		8'b01000011: color_data = 8'b10111011;
		8'b01000100: color_data = 8'b10111011;
		8'b01000101: color_data = 8'b10111011;
		8'b01000110: color_data = 8'b10111011;
		8'b01000111: color_data = 8'b10111011;
		8'b01001000: color_data = 8'b10111011;
		8'b01001001: color_data = 8'b10111011;
		8'b01001010: color_data = 8'b10111011;
		8'b01001011: color_data = 8'b10111011;
		8'b01001100: color_data = 8'b11111111;
		8'b01001101: color_data = 8'b10111011;

		8'b01010000: color_data = 8'b10111011;
		8'b01010001: color_data = 8'b10111011;
		8'b01010010: color_data = 8'b11111111;
		8'b01010011: color_data = 8'b10111011;
		8'b01010100: color_data = 8'b10111011;
		8'b01010101: color_data = 8'b10111011;
		8'b01010110: color_data = 8'b10111011;
		8'b01010111: color_data = 8'b10111011;
		8'b01011000: color_data = 8'b10111011;
		8'b01011001: color_data = 8'b10111011;
		8'b01011010: color_data = 8'b10111011;
		8'b01011011: color_data = 8'b11111111;
		8'b01011100: color_data = 8'b10111011;
		8'b01011101: color_data = 8'b10111011;

		8'b01100000: color_data = 8'b10111011;
		8'b01100001: color_data = 8'b10111011;
		8'b01100010: color_data = 8'b10111011;
		8'b01100011: color_data = 8'b11111111;
		8'b01100100: color_data = 8'b10111011;
		8'b01100101: color_data = 8'b10111011;
		8'b01100110: color_data = 8'b10111011;
		8'b01100111: color_data = 8'b10111011;
		8'b01101000: color_data = 8'b10111011;
		8'b01101001: color_data = 8'b10111011;
		8'b01101010: color_data = 8'b11111111;
		8'b01101011: color_data = 8'b10111011;
		8'b01101100: color_data = 8'b10111011;
		8'b01101101: color_data = 8'b10111011;

		8'b01110000: color_data = 8'b10111011;
		8'b01110001: color_data = 8'b10111011;
		8'b01110010: color_data = 8'b10111011;
		8'b01110011: color_data = 8'b10111011;
		8'b01110100: color_data = 8'b11111111;
		8'b01110101: color_data = 8'b10111011;
		8'b01110110: color_data = 8'b10111011;
		8'b01110111: color_data = 8'b10111011;
		8'b01111000: color_data = 8'b10111011;
		8'b01111001: color_data = 8'b11111111;
		8'b01111010: color_data = 8'b10111011;
		8'b01111011: color_data = 8'b10111011;
		8'b01111100: color_data = 8'b10111011;
		8'b01111101: color_data = 8'b10111011;

		8'b10000000: color_data = 8'b10111011;
		8'b10000001: color_data = 8'b10111011;
		8'b10000010: color_data = 8'b10111011;
		8'b10000011: color_data = 8'b10111011;
		8'b10000100: color_data = 8'b10111011;
		8'b10000101: color_data = 8'b11111111;
		8'b10000110: color_data = 8'b10111011;
		8'b10000111: color_data = 8'b10111011;
		8'b10001000: color_data = 8'b11111111;
		8'b10001001: color_data = 8'b10111011;
		8'b10001010: color_data = 8'b10111011;
		8'b10001011: color_data = 8'b10111011;
		8'b10001100: color_data = 8'b10111011;
		8'b10001101: color_data = 8'b10111011;

		8'b10010000: color_data = 8'b10111011;
		8'b10010001: color_data = 8'b10111011;
		8'b10010010: color_data = 8'b10111011;
		8'b10010011: color_data = 8'b10111011;
		8'b10010100: color_data = 8'b10111011;
		8'b10010101: color_data = 8'b10111011;
		8'b10010110: color_data = 8'b11111111;
		8'b10010111: color_data = 8'b11111111;
		8'b10011000: color_data = 8'b10111011;
		8'b10011001: color_data = 8'b10111011;
		8'b10011010: color_data = 8'b10111011;
		8'b10011011: color_data = 8'b10111011;
		8'b10011100: color_data = 8'b10111011;
		8'b10011101: color_data = 8'b10111011;

		default: color_data = 12'b00000000;
	endcase
endmodule