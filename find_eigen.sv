module find_eigen #(
	parameter SIZE_N = 8,
	parameter MAX_ITER = 100
)
(
	input logic clk,
	input logic rst,
	input integer cov_matrix[SIZE_N][SIZE_N],
	output integer eigenvalue[1][1],
	output integer eigenvector[SIZE_N][1],
	output integer cov_matrix_out[SIZE_N][SIZE_N]
);

	integer vector_init[SIZE_N][1];
	integer first_vector[SIZE_N][1];
	
	integer vectors[MAX_ITER][SIZE_N][1];
	
	integer copy_cov_matrix[SIZE_N][SIZE_N];
	integer copy_vectors[MAX_ITER][SIZE_N][1];
	
	integer count_n;
	integer count_k;
	
	integer vectors_input[MAX_ITER][SIZE_N][1];
	integer vectors_output[MAX_ITER][SIZE_N][1];

	integer eigenvalue_hold;
	
	
	initial begin
		for(int i = 0; i < SIZE_N; i++) begin
			vector_init[i][0] <= $random();
		end
	end
	
	assign vectors_input[0] = vector_init;
	assign vectors_input[1] = first_vector;
	
	init_decomposition #(.SIZE_N(SIZE_N)) in_de(.clk(clk), .rst(rst), .timed_matrix(cov_matrix), .vector_init(vector_init), .first_vector(first_vector));
	
	eigenloop #(.SIZE_N(SIZE_N), .MAX_ITER(MAX_ITER)) ei_lo(.clk(clk), .rst(rst), .timed_matrix(cov_matrix), .vectors_in(vectors_input), .vectors_out(vectors_output), .out_k(count_k));

	eigencalculation #(.SIZE_N(SIZE_N)) ei_ca(.clk(clk), .rst(rst), .timed_matrix(cov_matrix), .vector(copy_vectors[count_k]), .eigenvalue(eigenvalue_hold));
	
	cov_mat_update #(.SIZE_N(SIZE_N)) co_up(.clk(clk), .rst(rst), .vector(copy_vectors[count_n]), .eigenvalue(eigenvalue), .count_n(count_n), .cov_matrix_in(cov_matrix), .cov_matrix_out(cov_matrix_out));
	
	always_ff @(posedge clk) begin
		if(rst == 0) begin
			copy_vectors <= '{default:0};
		end
		else begin
			copy_vectors <= vectors_output;
			eigenvalue[0][0] <= eigenvalue_hold;
		end
	end
	
endmodule
