import fp_double::*;

module recursive_vector #(
	parameter SIZE_N = 8
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double timed_matrix[SIZE_N][SIZE_N],
	input double vector_in[SIZE_N][1],
	output double vector_out[SIZE_N][1],
	output logic f
);

	double next_vector[SIZE_N][1];
	double term_a[SIZE_N][1];
	double norm_term_a;

	double copy_term_a[SIZE_N][1];

	logic valid_frobenius;
	logic valid_division;

	double_multiply_mat #(.SIZE_A(SIZE_N), .SIZE_B(SIZE_N), .SIZE_C(1)) mp0(
		.clk(clk),
		.mat_a(timed_matrix),
		.mat_b(vector_in),
		.mat_out(term_a)
	);
	
	double_frobenius_norm #(.SIZE_A(SIZE_N), .SIZE_B(1)) fn1(.clk(clk), 
		.start(start), .mat(term_a), .val(norm_term_a), .valid(valid_frobenius));
	
	scalar_divide_mat #(.SIZE_A(SIZE_N), .SIZE_B(1)) sd0(.clk(clk), 
		.start(valid_frobenius), .scale(norm_term_a), .mat(copy_term_a), 
		.mat_out(next_vector), .valid(valid_division));

	always_ff @(posedge clk) begin
		valid <= 0;
		if(rst == 1) begin
			vector_out <= '{default:0};
			copy_term_a <= '{default: 0};
			valid <= 0;
		end
		else if(start == 1) begin
			busy <= 1;
			if(valid_frobenius) begin
				for(int i = 0; i < SIZE_N; i++) begin
					copy_term_a[i][0] <= term_a[i][0];
				end
				if(valid_division) begin
					vector_out <= next_vector;
					valid <= 1;
				end
			end
			else begin
				valid <= 0;
			end
		end
		else if(start == 0) begin
		end
	end
	
	
	
	

endmodule
