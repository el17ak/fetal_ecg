import fp_double::*;

module scalar_substract_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter CYCLES = 7 //Altera DP-FP number substraction output latency
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double scale,
	input double mat[SIZE_A][SIZE_B],
	output double mat_out[SIZE_A][SIZE_B],
	output logic f
);

	integer count;
	logic[SIZE_A-1:0][SIZE_B-1:0] of, uf, nan, zero;

	genvar i, j;
	generate
		for(i = 0; i < SIZE_A; i++) begin: outerl
			for(j = 0; j < SIZE_B; j++) begin: innerl
				//Altera DP-FP substraction megafunction
				fp_sub fps(
					.clock(clk),
					.aclr(rst),
					.clk_en(start),
					.dataa(mat[i][j]),
					.datab(scale),
					.result(mat_out[i][j]),
					.overflow(of[i][j]),
					.underflow(uf[i][j]),
					.nan(nan[i][j]),
					.zero(zero[i][j])
				);
			end
		end
	endgenerate
	
	
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			count <= 0;
		end
		else begin
			if(start) begin
				f <= 0;
				if(count <= CYCLES) begin
					f <= 1;
				end
				else begin
					count <= count + 1;
				end
			end
		end
	end
	
	
endmodule
