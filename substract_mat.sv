module substract_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter N_BITS = 32
)
(
	input logic signed[N_BITS-1:0] mat_a[SIZE_A][SIZE_B],
	input logic signed[N_BITS-1:0] mat_b[SIZE_A][SIZE_B],
	output logic signed[N_BITS+1-1:0] mat_out[SIZE_A][SIZE_B]
);

	// Updates when matrix A or B change.
	always_comb begin
		for(int i = 0; i < SIZE_A; i++) begin
			for(int j = 0; j < SIZE_B; j++) begin
				mat_out[i][j] = mat_a[i][j] - mat_b[i][j];
			end
		end
	end

endmodule
