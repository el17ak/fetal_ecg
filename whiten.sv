module whiten #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input logic clk,
	input integer mat[SIZE_A][SIZE_B],
	output integer mat_out[SIZE_A][SIZE_B],
	input logic rst
);

	integer centered_mat[SIZE_A][SIZE_B];
	integer transposed_centered_mat[SIZE_B][SIZE_A];
	integer cov_mat[SIZE_A][SIZE_A];
	integer eigvec_mat[SIZE_A][SIZE_A][1];
	integer transformed_eigvec_mat[SIZE_A][SIZE_A];
	integer eigvalues[SIZE_A][1][1];
	integer transformed_eigvalues[SIZE_A];

	//Calculate Sigma = D * D^T to find the covariance matrix of the input data
	center #(.SIZE_A(SIZE_A), .SIZE_B(SIZE_B)) c0(.mat(mat), .mat_out(centered_mat));
	transpose_mat #(.SIZE_A(SIZE_A), .SIZE_B(SIZE_B)) tp0(.mat(centered_mat), .mat_out(transposed_centered_mat));
	multiply_mat #(.SIZE_A(SIZE_A), .SIZE_B(SIZE_B), .SIZE_C(SIZE_A)) mp0(.mat_a(centered_mat), .mat_b(transposed_centered_mat), .mat_out(cov_mat));
	
	//Determine the eigenvectors and corresponding eigenvalues of the covariance matrix
	eigenvalue_decomposition #(.SIZE_N(SIZE_A)) eg0(.clk(clk), .mat(cov_mat), .eigenvector_mat(eigvec_mat), .eigenvalues(eigvalues), .rst(rst));

	//Calculate U = V * D the projection onto the PCA space of the centered data
	multiply_mat #(.SIZE_A(SIZE_A), .SIZE_B(SIZE_A), .SIZE_C(SIZE_B)) mp1(.mat_a(transformed_eigvec_mat), .mat_b(centered_mat), .mat_out(mat_out));

	always_ff @(posedge clk) begin
		if(rst == 0) begin
			transformed_eigvec_mat <= '{default:0};
		end
		else begin
			for(int i = 0; i < SIZE_A; i++) begin
				for(int j = 0; j < SIZE_A; j++) begin
					transformed_eigvec_mat[i][j] <= eigvec_mat[j][i][0];
				end
			end
		end
	end
	
endmodule
