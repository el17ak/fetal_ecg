module init_decomposition #(
	parameter SIZE_N = 8
)
(
	input logic clk,
	input logic rst,
	input integer timed_matrix[SIZE_N][SIZE_N],
	input integer vector_init[SIZE_N][1],
	output integer first_vector[SIZE_N][1]
);

	integer first_vector_hold[SIZE_N][1];

	multiply_mat #(.SIZE_A(SIZE_N), .SIZE_B(SIZE_N), .SIZE_C(1)) mu_ma(.mat_a(timed_matrix), .mat_b(vector_init), .mat_out(first_vector_hold));

	always_ff @(posedge clk) begin
		if(rst == 0) begin
			first_vector <= '{default:0};
		end
		else begin
			for(int i = 0; i < SIZE_N; i++) begin
				first_vector <= first_vector_hold;
				$display("should work");
			end
		end
	end

endmodule
