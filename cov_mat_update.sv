import fp_double::*;

module cov_mat_update #(
	parameter SIZE_N = 8
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double vector[SIZE_N][1],
	input double eigenvalue[1][1],
	input integer count_n,
	input double cov_matrix_in[SIZE_N][SIZE_N],
	output double cov_matrix_out[SIZE_N][SIZE_N],
	output logic valid
);

	double transposed_vector[1][SIZE_N];
	double vector_product[1][1];
	double eigvec_product[1][1];
	double cov_matrix_hold[SIZE_N][SIZE_N];

	double_transpose_mat #(.SIZE_A(SIZE_N), .SIZE_B(1)) tr_ma(.mat(vector),
		 .mat_out(transposed_vector));
	
	double_multiply_mat #(.SIZE_A(1), .SIZE_B(SIZE_N), .SIZE_C(1)) mp3(
		.clk(clk),
		.mat_a(transposed_vector),
		.mat_b(vector),
		.mat_out(vector_product)
	);

	double_multiply_mat #(.SIZE_A(1), .SIZE_B(1), .SIZE_C(1)) mp4(
		.clk(clk),
		.mat_a(eigenvalue),
		.mat_b(vector_product),
		.mat_out(eigvec_product)
	);

	scalar_substract_mat #(.SIZE_A(SIZE_N), .SIZE_B(SIZE_N)) ss0(
		.clk(clk),
		.rst(rst),
		.scale(eigvec_product[0][0]),
		.mat(cov_matrix_in), 
		.mat_out(cov_matrix_hold)
	);
			

	always_ff @(posedge clk) begin
		valid <= 0;
		if(start == 0) begin
			cov_matrix_out <= cov_matrix_in;
		end
		else if(start == 1) begin
			cov_matrix_out <= cov_matrix_hold;
			valid <= 1;
		end
	end

endmodule
