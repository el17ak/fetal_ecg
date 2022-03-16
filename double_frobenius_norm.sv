import fp_double::*;
import fsm_matop::*;

module double_frobenius_norm #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter CYCLES_M = 5,
	parameter CYCLES_A = 2,
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
	
	state_matop state, next;
	
	integer count = 0;
	integer next_count = 0;
	integer inner_count = 1;
	integer next_inner_count = 1;

	double product[SIZE_A][SIZE_B];
	double temp;
	
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
	assign temp = sum[0];
	
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
	
	always_comb begin
		next = XXX;
		acc_new = '0;
		next_count = count;
		next_inner_count = inner_count;
		f = '0;
		case(state)
			WAIT_MO: begin
				if(start) begin
					next = MULTIPLYING_MO;
				end
				else begin
					next = WAIT_MO;
				end
			end
			
			MULTIPLYING_MO: begin
				if(count == CYCLES_M) begin
					acc_new = '1;
					for(int i = 0; i < SIZE_A; i++) begin
						acc_line[i] = product[i][0];
					end
					next_count = count + 1;
					next = ACCUMULATING_MO;
				end
				else begin
					next_count = count + 1;
					next = MULTIPLYING_MO;
				end
			end
			
			ACCUMULATING_MO: begin
				next_count = 32'd0;
				if(inner_count >= SIZE_B + CYCLES_A + SIZE_A + CYCLES_A - 1) begin
					next = FINISHED_MO;
				end
				
				else if(inner_count >= SIZE_B + CYCLES_A + SIZE_A - 1) begin
					for(int i = 0; i < SIZE_A; i++) begin
						acc_line[i] = '0;
					end
					next_inner_count = inner_count + 1;
					next = ACCUMULATING_MO;
				end
				
				else if(inner_count >= SIZE_B + CYCLES_A) begin
					for(int i = 0; i < SIZE_A; i++) begin
						acc_line[0] = sum[inner_count-SIZE_B-CYCLES_A+1];
					end
					next_inner_count = inner_count + 1;
					next = ACCUMULATING_MO;
				end
				
				else if(inner_count >= SIZE_B) begin
					for(int i = 0; i < SIZE_A; i++) begin
						acc_line[i] = '0;
					end
					next_inner_count = inner_count + 1;
					next = ACCUMULATING_MO;
				end
				
				else begin
					for(int i = 0; i < SIZE_A; i++) begin
						acc_line[i] = product[i][inner_count];
					end
					next_inner_count = inner_count + 1;
					next = ACCUMULATING_MO;
				end
			end
	
			FINISHED_MO: begin
				next_inner_count = 32'd0;
				next = FINISHED_MO;
				if(count >= CYCLES_S) begin
					f = '1;
				end
				else begin
					next_count = count + 1;
				end
			end
		endcase
	end
	
	
	/**always_ff @(posedge clk or posedge rst) begin
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
							acc_line[0] <= '0;
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
	end**/
	
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= WAIT_MO;
			count <= 32'd0;
			inner_count <= 32'd1;
		end
		else begin
			state <= next;
			count <= next_count;
			inner_count <= next_inner_count;
		end
	end
	

endmodule
