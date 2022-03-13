import fp_double::*;

module find_eigen #(
	parameter SIZE_N = 8,
	parameter MAX_ITER = 100 //Number of bits for input covariance matrix (signed)
)
(
	input logic clk,
	input logic rst,
	input integer scale,
	input logic start,
	input double cov_matrix[SIZE_N][SIZE_N],
	output double eigenvalue[1][1],
	output double eigenvector[SIZE_N][1],
	output double cov_matrix_out[SIZE_N][SIZE_N],
	output logic valid
);

	double vector_init[SIZE_N][1]; //Initial random 8-bit signed vector
	double first_vector[SIZE_N][1];
	double second_vector[SIZE_N][1]; //86-bit
	
	double copy_vector[SIZE_N][1];
	
	integer count_n;
	integer count_k;
	
	double vectors_input[2][SIZE_N][1];
	double vector_output[SIZE_N][1];

	double eigenvalue_hold;
	logic start_init;
	logic start_loop;
	logic start_val;
	logic start_mat;
	logic[3:0] state;
	
	assign vectors_input[0] = first_vector;
	assign vectors_input[1] = second_vector;

	assign start_init = start;
	
	
	
	//Determine first two vectors to launch the loop with
	init_decomposition #(.SIZE_N(SIZE_N)) in_de(.clk(clk), .rst(rst), 
		.timed_matrix(cov_matrix), .first_vector(first_vector), 
		.second_vector(second_vector), .start(start_init), .valid(state[0]));
	
	//Launch loop with initial vectors, keep in state until convergence
	eigenloop #(.SIZE_N(SIZE_N), .MAX_ITER(MAX_ITER)) ei_lo(.clk(clk), .rst(rst), 
		.timed_matrix(cov_matrix), .vectors_in(vectors_input), 
		.vector_out(vector_output), .out_k(count_k), .scale(scale), 
		.start(start_loop), .valid(state[1]));

	//Calculate corresponding eigenvalue of obtained (converged) eigenvector
	eigencalculation #(.SIZE_N(SIZE_N)) ei_ca(.clk(clk), .rst(rst), 
		.timed_matrix(cov_matrix), .vector(copy_vector), 
		.eigenvalue(eigenvalue_hold), .start(start_val), .valid(state[2]));
	
	//Finally, remove influence of found eigenpair from data matrix
	cov_mat_update #(.SIZE_N(SIZE_N)) co_up(.clk(clk), .rst(rst), 
		.vector(copy_vector), .eigenvalue(eigenvalue), .count_n(count_n), 
		.cov_matrix_in(cov_matrix), .cov_matrix_out(cov_matrix_out), 
		.start(start_mat), .valid(state[3]));
	
	always_ff @(posedge clk) begin
		valid <= 0;
		start_loop <= 0;
		start_val <= 0;
		start_mat <= 0;
		if(start == 0) begin
			copy_vector <= '{default:0};
			start_loop <= 0;
			start_val <= 0;
			start_mat <= 0;
		end
		else if(start == 1) begin
			case(state)
				
				4'b0000: begin
					start_loop <= 0;
					start_val <= 0;
					start_mat <= 0;
				end
				
				4'b0001: begin //Initialisation complete
					start_loop <= 1;
					start_val <= 0;
					start_mat <= 0;
				end
				
				4'b0011: begin //Loop completed, converged
					copy_vector <= vector_output;
					eigenvector <= vector_output;
					start_val <= 1;
					start_mat <= 0;
				end
				
				4'b0111: begin
					eigenvalue[0][0] <= eigenvalue_hold;
					start_mat <= 1;
				end
				
				4'b1111: begin
					valid <= 1;
					start_loop <= 0;
					start_val <= 0;
					start_mat <= 0;
				end
				
			endcase
		end
	end
	
	
endmodule
