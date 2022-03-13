import fp_double::*;

module fun_g #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input logic clk,
	input double mat[SIZE_A][SIZE_B],
	output double mat_out[SIZE_A][SIZE_B],
	output logic valid
);
	
	double e[SIZE_A][SIZE_B];
	logic nan_flag[SIZE_A][SIZE_B];
	logic underflow_flag[SIZE_A][SIZE_B];
	logic overflow_flag[SIZE_A][SIZE_B];
	logic zero_flag[SIZE_A][SIZE_B];
	
	genvar i, j;
	generate
		for(i = 0; i < SIZE_A; i++) begin: row_wise0
			for(j = 0; j < SIZE_B; j++) begin: column_wise0
				double_exp de0(.clock(clk), .data((0 - (mul_double(mat[i][j], 
				mat[i][j])))/2), .nan(nan_flag[i][j]), .overflow(overflow_flag[i][j]), 
				.result(e[i][j]), .underflow(underflow_flag[i][j]), .zero(zero_flag[i][j]));
			end
		end
	endgenerate
	
	always_comb begin
		for(int i = 0; i < SIZE_A; i++) begin
			for(int j = 0; j < SIZE_B; j++) begin
				mat_out[i][j] = mul_double(mat[i][j], e[i][j]);
			end
		end
	end

endmodule
