module transpose_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input integer mat[SIZE_A][SIZE_B],
	output integer mat_out[SIZE_B][SIZE_A]
);

	// Updates when the input matrix changes.
	always_comb begin
		for(int i = 0; i < SIZE_B; i = i + 1) begin
			for(int j = 0; j < SIZE_A; j = j + 1) begin
				mat_out[i][j] <= mat[j][i];
			end
		end
	end

endmodule
