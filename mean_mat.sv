typedef logic[21:0] reading;

module mean_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input integer matrix[SIZE_A][SIZE_B],
	output integer out[SIZE_A]
);

// does not need to be square

	longint sum[SIZE_A];
	
	always_comb begin
		for(int i = 0; i < SIZE_A; i = i + 1) begin
			for(int j = 0; j < SIZE_B; j = j + 1) begin
				sum[i] <= sum[i] + matrix[i][j];
			end
			out[i] <= sum[i] / SIZE_B;
		end
	end
	
endmodule 