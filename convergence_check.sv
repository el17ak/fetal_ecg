//=======================================================
// Convergence Verification
//=======================================================

import fp_double::*;

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
	
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			f <= '0;
		end
		else begin
			if(start) begin
				f <= '0;
				if(finished[1]) begin
					f <= '1;
				end
			end
		end
	end
	
	

endmodule
