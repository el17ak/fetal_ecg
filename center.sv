module center#(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter N_BITS = 22
)
(
	input logic[N_BITS-1:0] matrix[SIZE_A][SIZE_B],
	output logic[N_BITS-1:0] out[SIZE_A][SIZE_B]
);

// does not need to be square

	logic mean_vector[SIZE_A];

	mean_mat(matrix, mean_vector);

	always_comb begin
		// Substract the mean vector of the matrix from itself
		for(int i = 0; i < SIZE_A; i++) begin
			for(int j = 0; j < SIZE_B; j = j++) begin
				out[i][j] <= matrix[i][j] - mean_vector[i];
			end
		end
	end

endmodule
