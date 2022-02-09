module center#(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input integer mat[SIZE_A][SIZE_B],
	output integer mat_out[SIZE_A][SIZE_B]
);

	integer mean_vector[SIZE_A];

	mean_mat(matrix, mean_vector);

	always_comb begin
		// Substract the mean vector of the matrix from itself
		for(int i = 0; i < SIZE_A; i++) begin
			for(int j = 0; j < SIZE_B; j = j++) begin
				mat_out[i][j] <= mat[i][j] - mean_vector[i];
			end
		end
	end

endmodule
