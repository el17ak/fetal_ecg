module recursive_vector #(
	parameter SIZE_N = 8,
	parameter MAX_ITER = 100
)
(
	input logic clk,
	input logic rst,
	input integer timed_matrix[SIZE_N][SIZE_N],
	input integer count_k,
	input integer vector_in[SIZE_N][1],
	output integer vector_out[SIZE_N][1]
);
	
	integer next_vector[SIZE_N][1];
	integer term_a[SIZE_N][1];
	real norm_term_a;

	multiply_mat #(.SIZE_A(SIZE_N), .SIZE_B(SIZE_N), .SIZE_C(1)) mp0(.mat_a(timed_matrix), .mat_b(vector_in), .mat_out(term_a));
	frobenius_norm #(.SIZE_A(SIZE_N), .SIZE_B(1)) fn1(.clk(clk), .mat(term_a), .val(norm_term_a));
	scalar_divide_mat #(.SIZE_A(SIZE_N), .SIZE_B(1)) sd0(.scale(norm_term_a), .mat(term_a), .mat_out(next_vector));

	always_ff @(posedge clk) begin
		if(rst == 0) begin
			vector_out <= '{default:0};
		end
		else begin
			vector_out <= next_vector;
		end
	end

endmodule
