module eigenvalue_decomposition #(
	parameter SIZE_N = 8
)
(
	input logic clk,
	input logic rst,
	input integer scale,
	input double mat[SIZE_N][SIZE_N], //57-bit covariance matrix
	output double eigenvector_mat[SIZE_N][SIZE_N][1],
	output double eigenvalues[SIZE_N][1][1]
);

	//Addition of 16 fractional bits for fixed-point arithmetic
	double copy_mat[SIZE_N+1][SIZE_N][SIZE_N];
	double out_mat[SIZE_N][SIZE_N][SIZE_N];

	logic[SIZE_N:0] start;
	
	genvar n;
	generate
		for(n = 0; n < SIZE_N; n++) begin: n_times
			assign copy_mat[n+1] = out_mat[n]; //Feed output back into input.
			find_eigen #(.SIZE_N(SIZE_N), .MAX_ITER(100)) fi_ei(
				.clk(clk),
				.rst(rst),
				.cov_matrix(copy_mat[n]),
				.eigenvalue(eigenvalues[n]),
				.eigenvector(eigenvector_mat[n]),
				.cov_matrix_out(out_mat[n]),
				.scale(scale),
				.start(start[n]),
				.valid(start[n+1])
			);
		end
	endgenerate

	always_ff @(posedge clk) begin
		for(int i = 0; i < SIZE_N; i++) begin
			for(int j = 0; j < SIZE_N; j++) begin
				copy_mat[0] <= mat;
			end
		end
		start[0] <= 1;
	end
	
endmodule
