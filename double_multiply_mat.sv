import fp_double::*;

module double_multiply_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter SIZE_C = 8,
	parameter CYCLES_M = 5,
	parameter CYCLES_A = 2
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double mat_a[SIZE_A][SIZE_B],
	input double mat_b[SIZE_B][SIZE_C],
	output double mat_out[SIZE_A][SIZE_C],
	output logic f
);

	integer count = 0;
	integer inner_count = 0;

	double sum[SIZE_A][SIZE_C];
	double product[SIZE_A][SIZE_C][SIZE_B];
	
	logic[SIZE_A-1:0][SIZE_C-1:0][SIZE_B-1:0] of, uf, nan, zero;
	logic[SIZE_A-1:0][SIZE_C-1:0] of_a, uf_a, nan_a, zero_a;
	double acc_line[SIZE_A][SIZE_C];
	logic acc_new;
	
	genvar i,j,k;
	generate
		for(i = 0; i < SIZE_A; i++) begin: iloop
			for(j = 0; j < SIZE_C; j++) begin: jloop
				for(k = 0; k < SIZE_B; k++) begin: kloop
					fp_mult mfp(
						.aclr(rst),
						.clock(clk),
						.clk_en(start),
						.dataa(mat_a[i][k]),
						.datab(mat_b[k][j]),
						.result(product[i][j][k]),
						.overflow(of[i][j][k]),
						.underflow(uf[i][j][k]),
						.nan(nan[i][j][k]),
						.zero(zero[i][j][k])
					);
				end
				
				fp_acc fpa(
					.clk(clk),
					.areset(rst),
					.x(acc_line[i][j]),
					.n(acc_new),
					.r(sum[i][j]),
					.xo(of_a[i][j]),
					.xu(uf_a[i][j]),
					.ao(nan_a[i][j]),
					.en(start)
				);	
				assign mat_out[i][j] = sum[i][j];
			end
		end
	endgenerate
	
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			f <= '0;
			count <= 0;
			inner_count <= 1;
		end
		else begin
			if(start) begin
				if(count == CYCLES_M) begin
					acc_new <= 1;
					for(int i = 0; i < SIZE_A; i++) begin
						for(int j = 0; j < SIZE_C; j++) begin
							acc_line[i][j] <= product[i][j][0];
						end
					end
					count <= count + 1;
				end
				else if(count > CYCLES_M) begin
					acc_new <= 0;
					for(int i = 0; i < SIZE_A; i++) begin
						for(int j = 0; j < SIZE_C; j++) begin
							if(inner_count < SIZE_B) begin
								acc_line[i][j] <= product[i][j][inner_count];
							end
							else if(inner_count == SIZE_B) begin
								acc_line[i][j] <= '0;
							end
							else if(inner_count == SIZE_B + CYCLES_A) begin
								f <= '1;
							end
						end
					end
					inner_count <= inner_count + 1;
					count <= count + 1;
				end
				else begin
					count <= count + 1;
				end
			end
		end
	end
	

endmodule
