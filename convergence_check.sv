module convergence_check #(
	parameter SIZE_N = 8,
	parameter MAX_ITER = 100
)
(
	input logic clk,
	input logic rst,
	input integer vector[SIZE_N][1],
	input integer next_vector[SIZE_N][1],
	input integer count_k,
	output logic calculated,
	output logic converged
);

	integer convergence_vector[SIZE_N][1];
	real convergence_norm[1][1];

	integer local_k;

	substract_mat #(.SIZE_A(SIZE_N), .SIZE_B(1)) sb0(.mat_a(next_vector), .mat_b(vector), .mat_out(convergence_vector));
	frobenius_norm #(.SIZE_A(SIZE_N), .SIZE_B(1)) fn0(.clk(clk), .mat(convergence_vector), .val(convergence_norm[0][0]));
			
	always_ff @(posedge clk) begin
		if(rst == 0) begin
			converged <= 0;
			calculated <= 0;
		end
		else begin
			if((convergence_norm[0][0] * 1000) > 1) begin
				converged <= 0;	
				//If count_k is more than local, the next norm calculation starts
				if(count_k > local_k || count_k == 0) begin	
					local_k <= count_k;
				end
			end
			else begin	
				converged <= 1;
			end
		end
	end

endmodule
