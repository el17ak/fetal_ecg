import fp_double::*;
import fsm_eigenrecursion::*;

module eigenrecursion #(
	parameter SIZE_N = 8
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double timed_matrix[SIZE_N][SIZE_N],
	input double vector_in[SIZE_N][1],
	output double vector_out[SIZE_N][1],
	output logic f
);
	
	state_eigenrecursion state, next;
	
	logic[2:0] finished;

	double term_a[SIZE_N][1];
	double norm_term_a;

	double_multiply_mat #(.SIZE_A(SIZE_N), .SIZE_B(SIZE_N), .SIZE_C(1)) mp_er(
		.clk(clk),
		.rst(rst),
		.start(start),
		.mat_a(timed_matrix),
		.mat_b(vector_in),
		.mat_out(term_a),
		.f(finished[0])
	);
	
	double_frobenius_norm #(.SIZE_A(SIZE_N), .SIZE_B(1)) fb_er(
		.clk(clk),
		.rst(rst),
		.start(finished[0]),
		.mat(term_a),
		.norm(norm_term_a),
		.f(finished[1])
	);
	
	scalar_divide_mat #(.SIZE_A(SIZE_N), .SIZE_B(1)) sd_er(
		.clk(clk),
		.rst(rst),
		.start(finished[1]),
		.scale(norm_term_a),
		.mat(term_a),
		.mat_out(vector_out),
		.f(finished[2])
	);

	/**always_ff @(posedge clk) begin
		valid <= 0;
		if(rst == 1) begin
			vector_out <= '{default:0};
			copy_term_a <= '{default: 0};
			valid <= 0;
		end
		else if(start == 1) begin
			busy <= 1;
			if(valid_frobenius) begin
				for(int i = 0; i < SIZE_N; i++) begin
					copy_term_a[i][0] <= term_a[i][0];
				end
				if(valid_division) begin
					vector_out <= next_vector;
					valid <= 1;
				end
			end
			else begin
				valid <= 0;
			end
		end
		else if(start == 0) begin
		end
	end**/
	
	
	always_comb begin
		next = XXX_ER;
		f = '0;
		case(state)
			WAIT_ER: begin
				if(start) begin
					next = MULTIPLYING_ER;
				end
				else begin
					next = WAIT_ER;
				end
			end
			
			MULTIPLYING_ER: begin
				if(finished[0]) begin
					next = FROBENIUS_ER;
				end
				else begin
					next = MULTIPLYING_ER;
				end
			end
			
			FROBENIUS_ER: begin
				if(finished[1]) begin
					next = DIVIDING_ER;
				end
				else begin
					next = FROBENIUS_ER;
				end
			end
			
			DIVIDING_ER: begin
				if(finished[2]) begin
					next = FINISHED_ER;
				end
				else begin
					next = DIVIDING_ER;
				end
			end
			
			FINISHED_ER: begin
				f = '1;
				next = FINISHED_ER;
			end
			
			default: begin
				next = XXX_ER;
			end
		endcase
	end
	
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= WAIT_ER;
		end
		else begin
			state <= next;
		end
	end
	

endmodule
