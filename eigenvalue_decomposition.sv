`timescale 1 ns/100 ps

module eigenvalue_decomposition #(
	parameter SIZE_N = 8
)
(
	input logic clk,
	input logic rst,
	input integer mat[SIZE_N][SIZE_N],
	output integer eigenvector_mat[SIZE_N][SIZE_N][1],
	output integer eigenvalues[SIZE_N][1][1]
);

	integer copy_mat[SIZE_N+1][SIZE_N][SIZE_N];
	integer out_mat[SIZE_N][SIZE_N][SIZE_N];
	
	assign copy_mat[0] = mat;
	
	genvar n;
	generate
		for(n = 0; n < SIZE_N; n++) begin: n_times
			assign copy_mat[n+1] = out_mat[n];
			find_eigen #(.SIZE_N(SIZE_N), .MAX_ITER(100)) fi_ei(.clk(clk),
				.rst(rst), .cov_matrix(copy_mat[n]), .eigenvalue(eigenvalues[n]),
				.eigenvector(eigenvector_mat[n]), .cov_matrix_out(out_mat[n]));
		end
	endgenerate
	
endmodule
