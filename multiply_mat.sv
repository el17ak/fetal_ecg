typedef logic[21:0] reading;

module multiply_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8, // Common size.
	parameter SIZE_C = 8,
	parameter N_BITS = 22
) (
	input logic[N_BITS-1:0] mat_a[SIZE_A][SIZE_B],
	input logic[N_BITS-1:0] mat_b[SIZE_B][SIZE_C],
	output logic[N_BITS-1:0] mat_out[SIZE_A][SIZE_C]
);
	
	// Correct size for multiplication is assumed to have been checked
	logic[63:0] sum = 0;

	//TODO: Initialise sum to 0.

	//Updates every time matrix A or B change.
	always_comb begin
	// Multiplication process
		for(int i = 0; i < SIZE_A; i++) begin
			for(int j = 0; j < SIZE_C; j++) begin
				for(int k = 0; k < SIZE_B; k++) begin
					sum = sum + (mat_a[i][k] * mat_b[k][j]);
				end
				mat_out[i][j] = sum;
			end
		end
	end

endmodule
