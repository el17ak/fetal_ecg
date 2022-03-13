import fp_double::*;

module double_frobenius_norm #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input logic clk,
	input logic start,
	input double mat[SIZE_A][SIZE_B],
	output double val,
	output logic valid
);

	double sum[SIZE_A+1][SIZE_B+1];
	double product[SIZE_A][SIZE_B];
	double temp;
	
	genvar i, j;
	generate
		for(i = 0; i < SIZE_A; i++) begin: outerblock
			for(j = 0; j < SIZE_B; j++) begin: innerblock
				fp_mult mfp(.clock(clk), .dataa(mat[i][j]), .datab(mat[i][j]), .result(product[i][j]));
				fp_add afp(.clock(clk), .dataa(sum[i][j]), .datab(product[i][j]), .result(sum[i][j+1]));
			end
			assign sum[i+1][0] = sum[i][SIZE_B];
		end
		assign sum[0][0] = 0;
		assign temp = sum[SIZE_A][0];
	endgenerate
	
	logic nan, of, zero;
	
	//Retrieve square root of sum of all squared matrix elements
	squareroot_ip sq0(
		.clock(clk),
		.data(temp),
		.nan(nan),
		.overflow(of),
		.result(val),
		.zero(zero)
	);

endmodule
