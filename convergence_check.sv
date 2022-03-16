//=======================================================
// Convergence Verification
//=======================================================

import fp_double::*;
import fsm_conv::*;

module convergence_check #(
	parameter SIZE_N = 8
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double vector[SIZE_N][1],
	input double next_vector[SIZE_N][1],
	output logic f,
	output logic converged
);

	state_conv state, next;

	logic[1:0] finished;
	
//=======================================================
// Substract current vector from previous one
//=======================================================

	double convergence_vector[SIZE_N][1];

	double_substract_mat #(.SIZE_A(SIZE_N), .SIZE_B(1)) sb0(
		.clk(clk),
		.rst(rst),
		.start(start),
		.mat_a(next_vector), 
		.mat_b(vector),
		.mat_out(convergence_vector),
		.f(finished[0])
	);
		
//=======================================================
// Obtain the Frobenius norm of the difference
//=======================================================

	logic valid_frobenius;
	
	double convergence_norm[1][1];

	double_frobenius_norm #(.SIZE_A(SIZE_N), .SIZE_B(1)) fn0(
		.clk(clk),
		.rst(rst),
		.start(finished[0]),
		.mat(convergence_vector),
		.norm(convergence_norm[0][0]), 
		.f(finished[1])
	);
	
	logic gt;
	assign converged = ~gt;
	
	fp_gt grth(
		.aclr(rst),
		.clk_en(finished[1]),
		.clock(clk),
		.dataa(convergence_norm[0][0]),
		.datab({1'b0,11'd1019,52'd1}),
		.agb(gt)
	);
			
			
	/**always_ff @(posedge clk) begin
		if(rst == 1) begin
			converged <= 0;
			valid <= 0;
			busy <= 0;
		end
		else if(start == 1) begin
			busy <= 1;
			if(((convergence_norm[0][0]) > 1) && valid_frobenius) begin
				converged <= 0;
				valid <= 1;
				busy <= 0;
			end
			else if(valid_frobenius && (convergence_norm[0][0] != 128'dx)) begin
				converged <= 1;
				valid <= 1;
				busy <= 0;
			end
			else begin
				converged <= 0;
				valid <= 0;
			end
		end
	end **/
	
	
	always_comb begin
		next = XXX_CV;
		f = '0;
		
		case(state)
			WAIT_CV: begin
				if(start) begin
					next = SUBSTRACTING_CV;
				end
				else begin
					next = WAIT_CV;
				end
			end
			
			SUBSTRACTING_CV: begin
				if(finished[0]) begin
					next = FROBENIUS_CV;
				end
				else begin
					next = SUBSTRACTING_CV;
				end
			end
			
			FROBENIUS_CV: begin
				if(finished[1]) begin
					next = FINISHED_CV;
				end
				else begin
					next = FROBENIUS_CV;
				end
			end
			
			FINISHED_CV: begin
				next = FINISHED_CV;
				f = '1;
			end
			
		endcase
	end
	
	
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= WAIT_CV;
		end
		else begin
			state <= next;
		end
	end
	
	

endmodule
