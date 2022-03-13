module unmixing_loop #(
	parameter SIZE_N = 8,
	parameter SIZE_M = 8,
	parameter N_BITS = 32,
	parameter COUNT = 0 //Outer Independent Component's loop count
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input logic signed[N_BITS-1:0] data_mat[SIZE_N][SIZE_M],
	output logic signed[N_BITS-1:0] converged_vector[SIZE_N][1],
	output logic[5:0] state,
	output logic valid

);

	integer count_k; //Inner loop count

	logic signed[N_BITS-1:0] vector_w_prime[SIZE_N][1];
	
	w_prime #(.SIZE_N(SIZE_N), .SIZE_M(SIZE_M), .N_BITS_MAT(), .N_BITS_VEC()) wp(.clk(), .rst(), .start(), .vector_w(), .data_mat(data_mat), .vector_w_prime(), .busy(state[0]), .valid(state[1]));
	
	w_second #(.COUNT(COUNT), .SIZE_N(), .N_BITS_VEC()) ws(.clk(), .rst(), .start(), .w_prime(), .previous_vector(), .w_second(), .busy(state[2]), .valid(state[3]));
	
	w_final #(.SIZE_N(), .N_BITS_VEC()) wf(.clk(), .rst(), .start(), .w_second(), .w_out(), .busy(state[4]), .valid(state[5]));
	
	
	//convergence_check #() cc();
	
	
	always_ff @(posedge clk) begin
		//General reset for every 512 samples
		if(rst == 1) begin
			count_k <= 0;
		end
		
		//If the module has been asked to start
		else if(start == 1) begin
		
			//If this is the first iteration of this weight vector
			if(count_k == 0 && state == 6'b000000) begin
				//set state
				//feed in initial randomised vector to w_prime
			end
			
			//If this is any other iteration
			else begin
			
				case(state)
				
					6'b000000: begin
					//if state is at 0, feed in input vector to w_prime
					
					end
					//if state is in 1, feed in output of w_prime to w_second
					//if state is in 3, feed in output of w_second to scalar divider
					//if state is in 5, the result is ready, check whether different?
						//if different, feed in result back to input vector
						//if similar, return result vector
				endcase
				
			end
		end
	end

endmodule
