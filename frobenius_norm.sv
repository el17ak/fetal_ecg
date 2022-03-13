/**
===============================================
 Frobenius Norm Module
===============================================
For a matrix of size (SIZE_A x SIZE_B) with each element being N_BITS in length.
Square power of N_BITS long elements will require 2 x N_BITS bitspace.
Sum of SIZE_B square powers will require at minimum (2 x N_BITS) + log2(SIZE_B).
Final square root of sum will require ((2 x N_BITS) + log2(SIZE_B))/2 + 1.
**/

module frobenius_norm #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter N_BITS = 32,
	parameter WIDTH_B = 5
)
(
	input logic clk,
	input logic start,
	input logic signed[N_BITS-1:0] mat[SIZE_A][SIZE_B],
	output logic signed[((N_BITS+N_BITS+WIDTH_B)/2):0] val,
	output logic valid
);

	logic signed[(N_BITS+N_BITS+WIDTH_B)-1:0] sum;

	
	always_comb begin
		sum = 0;
		for(int i = 0; i < SIZE_A; i++) begin
			for(int j = 0; j < SIZE_B; j++) begin
				sum = sum + square_power(mat[i][j]);
			end
		end
	end
	
	//Retrieve square root of sum of all squared matrix elements
	squareroot #(.N_BITS(N_BITS+N_BITS+WIDTH_B)) sq0(.clk(clk), .startVar(start), .number(sum), .out_number(val), .valid(valid));

	
	function logic signed[N_BITS+N_BITS-1:0] square_power(logic signed[N_BITS-1:0] x);
		return (x * x);
	endfunction
	
	

endmodule
