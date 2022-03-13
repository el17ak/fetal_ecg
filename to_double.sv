import fp_double::*;

module to_double #(
	parameter N_BITS_INT = 32,
	parameter N_BITS_FRAC = 16
)
(
	input logic clk,
	input logic rst,
	input logic signed[N_BITS_INT+N_BITS_FRAC-1:0] num,
	output double out_num
);

	reg[51:0] read_buffer;
	reg[51:0] write_buffer;
	logic[19:0] addr;
	logic readwrite;
	
	ram_block #(.SIZE_N(1), .N_BITS(52)) rb0(
		.clk(clk),
		.rw(readwrite),
		.data_to_write(write_hold),
		.address(addr),
		.data_out(temp_hold)
	);
	
	reg[32-1:0] width;
	logic valid;
	double result;
	int i;

	always_comb begin
		width = get_real_width(num, N_BITS_INT+N_BITS_FRAC);
		out_num.sign = num[N_BITS_INT+N_BITS_FRAC-1];
		addr = 0;
	end
	
	
	always_ff @(posedge clk) begin
		if(i < width) begin
			readwrite <= 1'b1;
			write_buffer[0] <= num[width-1-i];
			if(write_buffer[51] == 1) begin
				readwrite <= 1'b0;
				out_num.mantissa <= write_buffer;
				out_num.exponent <= 11'(i + 1023);
				valid <= 1'b1;
			end
			else begin
				readwrite <= 1'b1;
				write_buffer <= read_buffer << 1;
				valid <= 1'b0;
			end
			i++;
		end
		if(valid == 0) begin
			out_num.mantissa <= 52'd0;
			out_num.exponent <= 11'd1023;
		end
		else if(rst == 1) begin
			i <= 32'sd0;
		end
	end
	
	


endmodule
