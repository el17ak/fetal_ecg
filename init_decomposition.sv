import fp_double::*;

module init_decomposition #(
	parameter SIZE_N = 8
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double timed_matrix[SIZE_N][SIZE_N],
	output double first_vector[SIZE_N][1],
	output double second_vector[SIZE_N][1],
	output logic valid
	//The second vector obtained has 16 fractional bits, as for the cov matrix
);
	
	double vector_init[SIZE_N][1];
	
	genvar i;
	generate
		for(i = 0; i < SIZE_N; i++) begin: ran
			LFSR lfsr(.clk(clk), .reset(rst), .rnd(vector_init[i][0][51:0]));
			assign vector_init[i][0][62:52] = 11'd1024;
			assign vector_init[i][0][63] = 1'd0;
		end
	endgenerate
	
	
	//Multiply the covariance matrix by randomized vector
	double_multiply_mat #(.SIZE_A(SIZE_N), .SIZE_B(SIZE_N), .SIZE_C(1)) mu_ma(
		.clk(clk),
		.mat_a(timed_matrix),
		.mat_b(vector_init),
		.mat_out(second_vector));

	always_ff @(posedge clk) begin
		valid <= 0;
		if(~start) begin
			valid <= 0;
		end
		else begin
			for(int i = 0; i < SIZE_N; i++) begin
				first_vector[i][0] <= vector_init[i][0];
			end
			valid <= 1;
		end
	end
	
endmodule
