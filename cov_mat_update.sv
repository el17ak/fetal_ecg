import fp_double::*;

module cov_mat_update #(
	parameter SIZE_N = 8
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double vector[SIZE_N][1],
	input double eigenvalue[1][1],
	input integer count_n,
	input double cov_matrix_in[SIZE_N][SIZE_N],
	output double cov_matrix_out[SIZE_N][SIZE_N],
	output logic f
);

	logic[2:0] finished;
	
	double transposed_vector[1][SIZE_N];
	double vector_product[1][1];
	double eigvec_product[1][1];
	

	//Combinational transposition
	double_transpose_mat #(.SIZE_A(SIZE_N), .SIZE_B(1)) tr_ma(
		.mat(vector),
		.mat_out(transposed_vector)
	);
	
	
	double_multiply_mat #(.SIZE_A(1), .SIZE_B(SIZE_N), .SIZE_C(1)) mp3(
		.clk(clk),
		.rst(rst),
		.start(start),
		.mat_a(transposed_vector),
		.mat_b(vector),
		.mat_out(vector_product),
		.f(finished[0])
	);
	

	assign eigvec_product[0][0] = eigenvalue[0][0] * vector_product[0][0];
	/**double_multiply_mat #(.SIZE_A(1), .SIZE_B(1), .SIZE_C(1)) mp4(
		.clk(clk),
		.rst(rst),
		.start(finished[0]),
		.mat_a(eigenvalue),
		.mat_b(vector_product),
		.mat_out(eigvec_product),
		.f(finished[1])
	);**/

	
	scalar_substract_mat #(.SIZE_A(SIZE_N), .SIZE_B(SIZE_N)) ss0(
		.clk(clk),
		.rst(rst),
		.start(finished[1]),
		.scale(eigvec_product[0][0]),
		.mat(cov_matrix_in), 
		.mat_out(cov_matrix_out),
		.f(finished[2])
	);
	
	
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			f <= '0;
		end
		else begin
			if(start) begin
			f <= '0;
				if(finished[2]) begin
					f <= '1;
				end
			end
		end
	end
	

endmodule
