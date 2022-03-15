import fp_double::*;

module double_frobenius_norm #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter CYCLES_M = 5,
	parameter CYCLES_A = 7,
	parameter CYCLES_S = 30
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double mat[SIZE_A][SIZE_B],
	output double norm,
	output logic f
);

	double product[SIZE_A][SIZE_B];
	
	logic[SIZE_A-1:0][SIZE_B-1:0] of, uf, nan, zero;
	logic[SIZE_A-1:0] of_a, uf_a, nan_a;

	double acc_line[SIZE_A];
	logic acc_new;
	double sum[SIZE_A];
	
	genvar i, j;
	generate
		for(i = 0; i < SIZE_A; i++) begin: outerblock
			for(j = 0; j < SIZE_B; j++) begin: innerblock
				fp_mult mfp(
					.aclr(rst),
					.clock(clk),
					.clk_en(start),
					.dataa(mat[i][j]),
					.datab(mat[i][j]),
					.result(product[i][j]),
					.overflow(of[i][j]),
					.underflow(uf[i][j]),
					.nan(nan[i][j]),
					.zero(zero[i][j])
				);
			end
			fp_acc afc(
				.areset(rst),
				.clk(clk),
				.en(start),
				.x(acc_line[i]),
				.n(acc_new),
				.r(sum[i]),
				.xo(of_a[i]),
				.xu(uf_a[i]),
				.ao(nan_a[i])
			);
		end
	endgenerate
	
	logic nansq, ofsq, zerosq;
	
	//Retrieve square root of sum of all squared matrix elements
	squareroot_ip sq0(
		.aclr(rst),
		.clock(clk),
		.clk_en(start),
		.data(temp),
		.nan(nansq),
		.overflow(ofsq),
		.result(norm),
		.zero(zerosq)
	);
	
	
	integer count = 0;
	integer inner_count = 1;
	integer count_bis = 1;
	
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			count <= 0;
			inner_count <= 1;
			count_bis <= 1;
		end
		else begin
			if(start) begin
				if(count == CYCLES_M) begin
					acc_new <= '1;
					for(int i = 0; i < SIZE_A; i++) begin
						acc_line[i] <= product[i][0];
					end
				count <= count + 1;
				end
				else if(count > CYCLES_M) begin
					acc_new <= '0;
					for(int i = 0; i < SIZE_A; i++) begin
						if(inner_count < SIZE_B) begin
							acc_line[i] <= product[i][inner_count];
						end
						else if(inner_count == SIZE_B || inner_count < SIZE_B + CYCLES_A) begin
							acc_line[i] <= '0;
							count_bis <= 1;
						end
						else if(inner_count < SIZE_B + CYCLES_A + SIZE_A - 1) begin
							acc_line[0] <= sum[count_bis];
							count_bis <= count_bis + 1;
						end
						else if(inner_count == SIZE_B + CYCLES_A + SIZE_A + CYCLES_A - 1) begin
							f <= '1;
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
