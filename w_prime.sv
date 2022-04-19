import fp_double::*;

module w_prime #(
	parameter SIZE_N = 8, //Fetal ECG -> 8
	parameter SIZE_M = 8, //Fetal ECG -> 512
	parameter N_BITS_VEC = 32,
	parameter N_BITS_MAT = 32
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double vector_w[SIZE_N][1],
	input double data_mat[SIZE_N][SIZE_M],
	output double vector_w_prime[SIZE_N][1],
	output logic busy,
	output logic valid
);

	logic[5:0] state;

	double vector_w_hold[SIZE_N][1];
	double data_mat_hold[SIZE_N][SIZE_M];
	
//===================================================================
// Find common term (w^T)X
//===================================================================

	double transposed_vec[1][SIZE_N];
	double common_term[1][SIZE_M];

	//Transpose initial (N x 1) vector into a (1 x N) vector
	transpose_mat #(.SIZE_A(SIZE_N), .SIZE_B(1), .N_BITS(N_BITS_VEC)) 
		tp0(.mat(vector_w), .mat_out(transposed_vec));
	
	//Multiply data matrix by the transposed initial vector -> (1 x M)
	multiply_mat #(.SIZE_A(1), .SIZE_B(SIZE_N), .SIZE_C(SIZE_M), 
		.N_BITS_A(N_BITS_VEC), .N_BITS_B(N_BITS_MAT), .WIDTH_B(5)) 
		m0(.mat_a(transposed_vec), .mat_b(data_mat), .mat_out(common_term));
		
	
	logic[1:0] and_valid;
	logic valid_g, valid_g_prime;
	
//===================================================================
// Branch A (uses function g)
//===================================================================
	
	double transposed_common_term[SIZE_M][1];
	double g_out[SIZE_M][1];
	double vector_mult[SIZE_N][1];
	
	//Transpose (1 x M) vector to a (M x 1) vector
	double_transpose_mat #(.SIZE_A(1), .SIZE_B(SIZE_M)) tp1(
		.mat(common_term), 
		.mat_out(transposed_common_term)
	);
	
	//Retrieve g(u) where u is the comsmon term between both branches
	fun_g #(.SIZE_A(1), .SIZE_B(SIZE_M)) g0(.mat(transposed_common_term), .mat_out(g_out)); //put hold on output
	
	//Multiply the data matrix by the result of the g function -> (N x 1)
	double_multiply_mat #(.SIZE_A(SIZE_N), .SIZE_B(SIZE_M), .SIZE_C(1)) m1(.mat_a(data_mat), .mat_b(g_out), .mat_out(vector_mult));
	
	//Divide each element in vector by M to estimate the mean -> (N x 1)
	scalar_divide_mat #(.SIZE_A(SIZE_N), .SIZE_B(1)) sd0(.clk(clk), .start(start), .scale(SIZE_M), .mat(), .mat_out(), .valid(and_valid[0])); //use and_valid[0]
	
	
//===================================================================
// Branch B (uses function g')
//===================================================================

	double g_prime_out[1][SIZE_M];
	double temp_mult[SIZE_N][SIZE_M];
	double vector_mult_bis[SIZE_N][1];
	double m_vector[SIZE_M][1];// = {default: 1};
	
	//Retrieve g'(u) where u is, again, the common term between both branches
	fun_g_prime #(.SIZE_A(1), .SIZE_B(SIZE_M)) g1(.mat(common_term), .mat_out(g_prime_out)); //put hold on output
	
	//Multiply the initial vector by the result of the g' function -> (N x M)
	double_multiply_mat #(.SIZE_A(SIZE_N), .SIZE_B(1), .SIZE_C(SIZE_M)) m2(.mat_a(vector_w), .mat_b(g_prime_out), .mat_out(temp_mult));
	
	//Multiply the previous result by a length M column vector of 1's -> (N x 1)
	double_multiply_mat #(.SIZE_A(), .SIZE_B(), .SIZE_C()) m3(.mat_a(temp_mult), .mat_b(m_vector), .mat_out(vector_mult_bis));
	
	//Divide each element in resulting vector by M to estimate the mean -> (N x 1)
	scalar_divide_mat #(.SIZE_A()) sd1(.clk(clk), .start(), .scale(SIZE_M), .mat(), .mat_out(), .valid()); //and_valid[1]
	
	
//===================================================================
//
//===================================================================
	
	double vector_w_prime_hold[SIZE_N][1];
	
	//Substract the resulting matrix of the g'(u) branch from the g(u) branch
	double_substract_mat #(.SIZE_A(SIZE_N), .SIZE_B(1)) sb0(.mat_a(), .mat_b(), .mat_out(vector_w_prime_hold)); //if and_valid == 3
	
	
	always_ff @(posedge clk) begin
		if(rst == 1) begin
			
		end
		else if(start == 1) begin
			case(state)
				'b0000: begin //Calculations not started
					$display("Calculations not started.");
				end
				
				'b0001: begin
					$display("Calculating branch A...");
				end
				
				'b0010: begin
				
				end
			
			endcase
		end
	end
	
	
endmodule
