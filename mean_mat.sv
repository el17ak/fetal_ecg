typedef logic[21:0] reading;

module mean_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter N_BITS = 22
)
(
	input logic[N_BITS-1:0] matrix[SIZE_A][SIZE_B],
	output logic[N_BITS-1:0] out[SIZE_A]
);

// does not need to be square

	logic[N_BITS-1:0] sum[SIZE_A];
	
	always_comb begin
		for(int i = 0; i < SIZE_A; i = i + 1) begin
			for(int j = 0; j < SIZE_B; j = j + 1) begin
				sum[i] <= sum[i] + matrix[i][j];
			end
			out[i] <= sum[i] / SIZE_A;
		end
	end
	
endmodule 