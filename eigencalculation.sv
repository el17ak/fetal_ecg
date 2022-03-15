import fp_double::*;

module eigencalculation #(
	parameter SIZE_N = 8
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double timed_matrix[SIZE_N][SIZE_N],
	input double vector[SIZE_N][1],
	output double eigenvalue,
	output logic f
);

	double transposed_vector[1][SIZE_N];
	double intermediary_term[1][SIZE_N];
	double eigenvalue_hold[1][1];
	
	
	logic[1:0] finished;
	
	assign eigenvalue = eigenvalue_hold[0][0];

	//Combinational transposition
	double_transpose_mat #(.SIZE_A(SIZE_N), .SIZE_B(1)) tp0(
		.mat(vector), 
		.mat_out(transposed_vector)
	);
		
	
	double_multiply_mat #(.SIZE_A(1), .SIZE_B(SIZE_N), .SIZE_C(SIZE_N)) mp1(
		.clk(clk),
		.rst(rst),
		.start(start),
		.mat_a(transposed_vector),
		.mat_b(timed_matrix), 
		.mat_out(intermediary_term),
		.f(finished[0])
	);
	
	
	double_multiply_mat #(.SIZE_A(1), .SIZE_B(SIZE_N), .SIZE_C(1)) mp2(
		.clk(clk),
		.rst(rst),
		.start(finished[0]),
		.mat_a(intermediary_term),
		.mat_b(vector), 
		.mat_out(eigenvalue_hold),
		.f(finished[1])
	);
	
	/**always_ff @(posedge clk) begin
		valid <= 1'b0;
		if(start == 0) begin
			eigenvalue <= 0;
			valid <= 1'b0;
		end
		else if(start == 1) begin
			//Copy the 16
			eigenvalue <= eigenvalue_hold[0][0];
			valid <= 1'b1;
		end
	end**/
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			f = '0;
		end
		else begin
			if(start) begin
				f = '0;
				if(finished[1]) begin
					f = '1;
				end
			end
		end
	end
	

endmodule
