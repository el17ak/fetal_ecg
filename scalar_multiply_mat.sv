module scalar_multiply_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter N_BITS = 22
)
(
	input logic[N_BITS-1:0] scale,
	input logic[N_BITS-1:0] mat[SIZE_A][SIZE_B],
	output logic[N_BITS-1:0] mat_out[SIZE_A][SIZE_B]
);

	always_comb begin
		for(int i = 0; i < SIZE_A; i++) begin
			for(int j = 0; j < SIZE_B; j++) begin
				mat_out[i][j] = mat[i][j] * scale;
			end
		end
	end

endmodule
