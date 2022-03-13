import fp_double::*;

module scalar_substract_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input logic clk,
	input logic rst,
	input double scale,
	input double mat[SIZE_A][SIZE_B],
	output double mat_out[SIZE_A][SIZE_B]
);


	genvar i, j;
	generate
		for(i = 0; i < SIZE_A; i++) begin: outerl
			for(j = 0; j < SIZE_B; j++) begin: innerl
				fp_sub fps(.clk(clk), .areset(rst), .a(mat[i][j]), .b(scale), .q(mat_out[i][j]));
			end
		end
	endgenerate

endmodule
