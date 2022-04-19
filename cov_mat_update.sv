import fp_double::*;
import fsm_cov_update::*;

module cov_mat_update #(
	parameter SIZE_N = 8,
	parameter CYCLES_M = 5
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double vector[SIZE_N][1],
	input double eigenvalue[1][1],
	input integer count_n,
	input double cov_matrix_in[SIZE_N][SIZE_N],
	output double cov_matrix_out[SIZE_N][SIZE_N],
	output logic f
);

	state_cov_update state, next;

	logic[2:0] finished;
	
	double transposed_vector[1][SIZE_N];
	double vector_product[1][1];
	double eigvec_product[1][1];
	

	//Combinational transposition
	double_transpose_mat #(.SIZE_A(SIZE_N), .SIZE_B(1)) tr_ma(
		.mat(vector),
		.mat_out(transposed_vector)
	);
	
	
	double_multiply_mat #(.SIZE_A(1), .SIZE_B(SIZE_N), .SIZE_C(1)) mp3(
		.clk(clk),
		.rst(rst),
		.start(start),
		.mat_a(transposed_vector),
		.mat_b(vector),
		.mat_out(vector_product),
		.f(finished[0])
	);
	
	logic of, uf, nan, zero;
	
	fp_mult fpm(
		.aclr(rst),
		.clock(clk),
		.clk_en(finished[0]),
		.dataa(eigenvalue[0][0]),
		.datab(vector_product[0][0]),
		.result(eigvec_product[0][0]),
		.overflow(of),
		.underflow(uf),
		.nan(nan),
		.zero(zero)
	);
	
	logic del_start, next_del_start;
	
	scalar_substract_mat #(.SIZE_A(SIZE_N), .SIZE_B(SIZE_N)) ss0(
		.clk(clk),
		.rst(rst),
		.start(del_start),
		.scale(eigvec_product[0][0]),
		.mat(cov_matrix_in), 
		.mat_out(cov_matrix_out),
		.f(finished[1])
	);
	
	integer count, next_count;
	
	always_comb begin
		next = XXX_CU;
		f = '0;
		next_del_start = del_start;
		next_count = count;
		case(state)
			WAIT_CU: begin
				if(start) begin
					next = MULTIPLYING1_CU;
				end
				else begin
					next = WAIT_CU;
				end
			end
			
			MULTIPLYING1_CU: begin
				if(finished[0]) begin
					next_count = 0;
					next = MULTIPLYING2_CU;
				end
				else begin
					next = MULTIPLYING1_CU;
				end
			end
			
			MULTIPLYING2_CU: begin
				if(count >= CYCLES_M) begin
					next_del_start = '1;
					next = SUBSTRACTING_CU;
				end
				else begin
					next_count = count + 1;
					next = MULTIPLYING2_CU;
				end
			end
			
			SUBSTRACTING_CU: begin
				if(finished[1]) begin
					next = FINISHED_CU;
				end
				else begin
					next = SUBSTRACTING_CU;
				end
			end
			
			FINISHED_CU: begin
				f = '1;
				next = FINISHED_CU;
			end
		endcase
	end
	
	
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= WAIT_CU;
			count <= 0;
			del_start <= 0;
		end
		else begin
			state <= next;
			count <= next_count;
			del_start <= next_del_start;
		end
	end
	

endmodule
