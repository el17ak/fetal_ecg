import fp_double::*;

module double_substract_mat#(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input clk,
	input rst,
	input double mat_a[SIZE_A][SIZE_B],
	input double mat_b[SIZE_A][SIZE_B],
	output double mat_out[SIZE_A][SIZE_B]
);

	// Updates when matrix A or B change.
	genvar i, j;
	generate
		for(i = 0; i < SIZE_A; i++) begin: outerloop
			for(j = 0; j < SIZE_B; j++) begin: innerloop
				fp_sub fps(.clk(clk), .areset(rst), .a(mat_a[i][j]), .b(mat_b[i][j]), .q(mat_out[i][j]));
			end
		end
	endgenerate

endmodule
