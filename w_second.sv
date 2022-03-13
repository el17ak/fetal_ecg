module w_second #(
	parameter COUNT = 0, //Count of which IC's weight vector
	parameter SIZE_N = 8,
	parameter N_BITS_VEC = 32
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input logic signed[N_BITS_VEC-1:0] w_prime[SIZE_N][1],
	input logic signed[N_BITS_VEC-1:0] previous_vectors[SIZE_N][2],
	output logic signed[N_BITS_VEC-1:0] w_second[SIZE_N][1],
	output logic busy,
	output logic valid
);

	transpose_mat #(.SIZE_A(), .SIZE_B(), .N_BITS()) tp0(.mat(), .mat_out());
	
	generate
		if(COUNT == 1) begin: gena
			
		end
		else if(COUNT == 2) begin: genb
			
		end
	endgenerate
	
	substract_mat #(.SIZE_A(), .SIZE_B(), .N_BITS()) sb0(.mat_a(), .mat_b(), .mat_out());
	
	always_ff @(posedge clk) begin
		
	end

endmodule
