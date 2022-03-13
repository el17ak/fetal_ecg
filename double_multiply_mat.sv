import fp_double::*;

module double_multiply_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter SIZE_C = 8
)
(
	input clk,
	input double mat_a[SIZE_A][SIZE_B],
	input double mat_b[SIZE_B][SIZE_C],
	output double mat_out[SIZE_A][SIZE_C]
);

	double sum[SIZE_A][SIZE_C][SIZE_B+1];
	double product[SIZE_A][SIZE_C][SIZE_B];
	
	assign sum[0][0][0] = '0;
	
	genvar i,j,k;
	generate
		for(i = 0; i < SIZE_A; i++) begin: iloop
			for(j = 0; j < SIZE_C; j++) begin: jloop
				for(k = 0; k < SIZE_B; k++) begin: kloop
					fp_mult mfp(.clock(clk), .dataa(mat_a[i][k]), .datab(mat_b[k][j]), .result(product[i][j][k]));
					fp_add afp(.clock(clk), .dataa(sum[i][j][k]), .datab(product[i][j][k]), .result(sum[i][j][k+1]));
				end
				assign mat_out[i][j] = sum[i][j][SIZE_B];
			end
		end
	endgenerate
	

endmodule
