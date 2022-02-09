module whiten #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input logic clk,
	input integer mat[SIZE_A][SIZE_B],
	output integer mat_out[SIZE_A][SIZE_B]
);

	integer centered_mat[SIZE_A][SIZE_B];
	integer transposed_centered_mat[SIZE_B][SIZE_A];
	integer cov_mat[SIZE_A][SIZE_A];

	//D * D^T
	center #(.SIZE_A(SIZE_A), .SIZE_B(SIZE_B)) c0(.mat(mat), .mat_out(centered_mat));
	transpose_mat #(.SIZE_A(SIZE_A), .SIZE_B(SIZE_B)) tp0(.mat(centered_mat), .mat_out(transposed_centered_mat));
	multiply_mat #(.SIZE_A(SIZE_A), .SIZE_B(SIZE_B), .SIZE_C(SIZE_A)) mp0(.mat_a(), .mat_b(), .mat_out(cov_mat));
	
	


endmodule
