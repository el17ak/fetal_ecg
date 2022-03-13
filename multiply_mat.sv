module multiply_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8, // Common size.
	parameter SIZE_C = 8,
	parameter N_BITS_A = 32, //Number of bits per element of matrix A.
	parameter N_BITS_B = 32, //Number of bits per element of matrix B.
	parameter WIDTH_B = 3
)
(
	input logic signed[N_BITS_A-1:0] mat_a[SIZE_A][SIZE_B],
	input logic signed[N_BITS_B-1:0] mat_b[SIZE_B][SIZE_C],
	output logic signed[(N_BITS_A+N_BITS_B+WIDTH_B-1):0] mat_out[SIZE_A][SIZE_C]
);
	
	// Correct size for multiplication is assumed to have been checked
	logic signed[(N_BITS_A+N_BITS_B+WIDTH_B-1):0] sum;

	always_comb begin
		//Multiplication process for fixed-point values
		for(int i = 0; i < SIZE_A; i++) begin
			for(int j = 0; j < SIZE_C; j++) begin
				sum = 0;
				for(int k = 0; k < SIZE_B; k++) begin
					sum = sum + (mat_a[i][k] * mat_b[k][j]);
				end
				mat_out[i][j] = sum;
			end
		end
	end

endmodule
