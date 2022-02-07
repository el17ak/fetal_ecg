module transpose_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter N_BITS = 22
)
(
	input logic[N_BITS-1:0] matrix[SIZE_A][SIZE_B],
	output logic[N_BITS-1:0] out[SIZE_B][SIZE_A]
);

	// Updates when the input matrix changes.
	always_comb begin
		for(int i = 0; i < SIZE_B; i = i + 1) begin
			for(int j = 0; j < SIZE_A; j = j + 1) begin
				out[i][j] = matrix[j][i];
			end
		end
	end

endmodule
