module mean_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter N_BITS = 32,
	parameter WIDTH = 7
)
(
	input logic signed[N_BITS-1:0] mat[SIZE_A][SIZE_B],
	output logic signed[24-1:0] mat_out[SIZE_A][1]
);

// does not need to be square

	logic signed[N_BITS+7-1:0] sum[SIZE_A];
	logic signed[WIDTH-1:0] dividend;
	
	always_comb begin
		dividend = SIZE_B;
		for(int i = 0; i < SIZE_A; i++) begin
			sum = '{default: 0};
			for(int j = 0; j < SIZE_B; j++) begin
				sum[i] = sum[i] + mat[i][j];
			end
			mat_out[i][0] = sum[i] / dividend;
		end
	end
	
endmodule 