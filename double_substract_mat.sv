import fp_double::*;

module double_substract_mat#(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter CYCLES = 7
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double mat_a[SIZE_A][SIZE_B],
	input double mat_b[SIZE_A][SIZE_B],
	output double mat_out[SIZE_A][SIZE_B],
	output logic f
);

	logic[SIZE_A-1:0][SIZE_B-1:0] of, uf, nan, zero;


	//Every element of B substracted from every element of A
	genvar i, j;
	generate
		for(i = 0; i < SIZE_A; i++) begin: outerloop
			for(j = 0; j < SIZE_B; j++) begin: innerloop
				fp_sub fps(
					.clock(clk),
					.aclr(rst),
					.clk_en(start),
					.dataa(mat_a[i][j]),
					.datab(mat_b[i][j]),
					.result(mat_out[i][j]),
					.nan(nan[i][j]),
					.overflow(of[i][j]),
					.underflow(uf[i][j]),
					.zero(zero[i][j])
				);
			end
		end
	endgenerate
	
	
	
	integer count = 0;
	
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
