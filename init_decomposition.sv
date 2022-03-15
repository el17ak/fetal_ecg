import fp_double::*;

module init_decomposition #(
	parameter SIZE_N = 8,
	parameter CYCLES_M = 5
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double timed_matrix[SIZE_N][SIZE_N],
	output double vector_init[SIZE_N][1],
	output double second_vector[SIZE_N][1],
	output logic f
);
	
	assign vector_init[0][0][51:0] = {52'b1011001111001000001000110011111010010101001011100110};
	assign vector_init[1][0][51:0] = {52'b0010111011101110110101110001100010011100001110001001};
	assign vector_init[2][0][51:0] = {52'b1111100001001001110000000011000110101011001001101010};
	assign vector_init[3][0][51:0] = {52'b0011001010001000110001101110100001111011000000010110};
	assign vector_init[4][0][51:0] = {52'b1011010110000001011001111111010011100111010111010011};
	assign vector_init[5][0][51:0] = {52'b1110010111011111111000100110000110111000101011110001};
	assign vector_init[6][0][51:0] = {52'b1010000110111000010011001111000100010001111101001100};
	assign vector_init[7][0][51:0] = {52'b0110011011001000101111011010001111110110101011100011};
	
	genvar i;
	generate
		for(i = 0; i < SIZE_N; i++) begin: ran
			assign vector_init[i][0][62:52] = 11'd1024;
			assign vector_init[i][0][63] = 1'd0;
		end
	endgenerate
	
	
	
	//Multiply the covariance matrix by randomized vector
	double_multiply_mat #(.SIZE_A(SIZE_N), .SIZE_B(SIZE_N), .SIZE_C(1)) mu_ma(
		.clk(clk),
		.rst(rst),
		.start(start),
		.mat_a(timed_matrix),
		.mat_b(vector_init),
		.mat_out(second_vector),
		.f(f)
	);
	
endmodule
