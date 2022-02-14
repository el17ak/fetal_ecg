module eigencalculation #(
	parameter SIZE_N = 8
)
(
	input logic clk,
	input logic rst,
	input integer timed_matrix[SIZE_N][SIZE_N],
	input integer vector[SIZE_N][1],
	output integer eigenvalue
);

	integer transposed_vector[1][SIZE_N];
	integer intermediary_term[1][SIZE_N];
	integer eigenvalue_hold[1][1];

	transpose_mat #(.SIZE_A(SIZE_N), .SIZE_B(1)) tp0(.mat(vector), .mat_out(transposed_vector));
	multiply_mat #(.SIZE_A(1), .SIZE_B(SIZE_N), .SIZE_C(SIZE_N)) mp1(.mat_a(transposed_vector), .mat_b(timed_matrix), .mat_out(intermediary_term));
	multiply_mat #(.SIZE_A(1), .SIZE_B(SIZE_N), .SIZE_C(1)) mp2(.mat_a(intermediary_term), .mat_b(vector), .mat_out(eigenvalue_hold));
	
	always_ff @(posedge clk) begin
		if(rst == 0) begin
			eigenvalue <= 0;
		end
		else begin
			eigenvalue <= eigenvalue_hold[0][0];
		end
	end

endmodule
