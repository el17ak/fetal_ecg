module cov_mat_update #(
	parameter SIZE_N = 8
)
(
	input logic clk,
	input logic rst,
	input integer vector[SIZE_N][1],
	input integer eigenvalue[1][1],
	input integer count_n,
	input integer cov_matrix_in[SIZE_N][SIZE_N],
	output integer cov_matrix_out[SIZE_N][SIZE_N]
);

	integer transposed_vector[1][SIZE_N];
	integer vector_product[1][1];
	integer eigvec_product[1][1];
	integer cov_matrix_hold[SIZE_N][SIZE_N];

	transpose_mat #(.SIZE_A(SIZE_N), .SIZE_B(1)) tr_ma(.mat(vector), .mat_out(transposed_vector));
	multiply_mat #(.SIZE_A(1), .SIZE_B(SIZE_N), .SIZE_C(1)) mp3(.mat_a(transposed_vector), .mat_b(vector), .mat_out(vector_product));
	multiply_mat #(.SIZE_A(1), .SIZE_B(1), .SIZE_C(1)) mp4(.mat_a(eigenvalue), .mat_b(vector_product), .mat_out(eigvec_product));
	scalar_substract_mat #(.SIZE_A(SIZE_N), .SIZE_B(SIZE_N)) ss0(.scale(eigvec_product[0][0]), .mat(cov_matrix_in), .mat_out(cov_matrix_hold));
			

	always_ff @(posedge clk) begin
		if(rst == 0) begin
			cov_matrix_out[count_n+1] <= cov_matrix_in[count_n+1];
		end
		else begin
			cov_matrix_out[count_n+1] <= cov_matrix_hold[count_n+1];
		end
	end

endmodule
