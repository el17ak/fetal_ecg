module mean_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input integer mat[SIZE_A][SIZE_B],
	output integer mat_out[SIZE_A][1]
);

// does not need to be square

	longint sum[SIZE_A];
	
	always_comb begin
		for(int i = 0; i < SIZE_A; i++) begin
			for(int j = 0; j < SIZE_B; j++) begin
				sum[i] = sum[i] + mat[i][j];
			end
			mat_out[i][0] <= sum[i] / SIZE_B;
		end
	end
	
endmodule 