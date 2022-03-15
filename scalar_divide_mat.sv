import fp_double::*;

module scalar_divide_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter CYCLES = 10
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
	
	logic[SIZE_A-1:0][SIZE_B-1:0] of, uf, nan, zero, division_by_zero;
	
	genvar i, j;
	generate
		for(i = 0; i < SIZE_A; i++) begin: gen1
			for(j = 0; j < SIZE_B; j++) begin: gen2
				fp_div d_sd(
					.aclr(rst),
					.clock(clk),
					.clk_en(start),
					.dataa(mat[i][j]),
					.datab(scale),
					.division_by_zero(division_by_zero[i][j]),
					.nan(nan[i][j]),
					.overflow(of[i][j]),
					.result(mat_out[i][j]),
					.underflow(uf[i][j]),
					.zero(zero[i][j])
				);
			end
		end
	endgenerate

	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			f <= '0;
			count <= 0;
		end
		else begin
			if(start) begin
				f <= '0;
				if(count >= CYCLES) begin
					f <= '1;
				end
				else begin
					count <= count + 1;
				end
			end
		end
	end

endmodule
