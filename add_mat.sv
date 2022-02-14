module add_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input mat_a[SIZE_A][SIZE_B],
	input mat_b[SIZE_A][SIZE_B],
	output mat_out[SIZE_A][SIZE_B]
);

	always_comb begin
		for(int i = 0; i < SIZE_A; i++) begin
			for(int j = 0; j < SIZE_B; j++) begin
				mat_out[i][j] = mat_a[i][j] + mat_b[i][j];
			end
		end
	end

endmodule
