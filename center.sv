module center#(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter N_BITS = 32
)
(
	input logic signed[N_BITS-1:0] mat[SIZE_A][SIZE_B],
	output logic signed[N_BITS+3-1:0] mat_out[SIZE_A][SIZE_B]
	//NOTE: If there are more components than bits per number, this won't work
	//We would want a matrix of [SIZE_A:0] instead, this is because of arithmetic overflow
);

	logic signed[24-1:0] mean_vector[SIZE_A][1];

	mean_mat #(.SIZE_A(SIZE_A), .SIZE_B(SIZE_B), .N_BITS(N_BITS)) mn0(.mat(mat), .mat_out(mean_vector));

	always @(mean_vector[0][0] or mean_vector[1][0] or mean_vector[2][0] or mean_vector[3][0] or mean_vector[4][0] or mean_vector[5][0] or mean_vector[6][0] or mean_vector[7][0]) begin
		// Substract the mean vector of the matrix from itself
		for(int i = 0; i < SIZE_A; i++) begin
			for(int j = 0; j < SIZE_B; j++) begin
				mat_out[i][j] <= mat[i][j] - mean_vector[i][0];
			end
		end
	end

endmodule
