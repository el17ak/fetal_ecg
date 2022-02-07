//=======================================
//	FastICA Algorithm implementation
//  Anna Kennedy, University of Leeds
//=======================================

module fast_ica #(
	parameter SIZE_N = 8,
	parameter SIZE_M = 512,
	parameter SIZE_C = 3,
	parameter N_BITS = 22
)
(
	input logic[N_BITS-1:0] matrix[SIZE_N][SIZE_M], // N x M
	output logic[N_BITS-1:0] unmix_matrix[SIZE_N][SIZE_C], // N x C
	output logic[N_BITS-1:0] ic_matrix[SIZE_C][SIZE_M] // C x M
);

	logic[7:0] p;
	
//=======================================
//	Declaration of intermediary matrices
//=======================================
	logic[N_BITS-1:0] w_prime[SIZE_N][1];
	logic[N_BITS-1:0] w_sec_prime[SIZE_N][1];
	logic[N_BITS-1:0] w_updated[SIZE_N][1];
	
	logic[N_BITS-1:0] initial_weight_vector[SIZE_N][1];
	logic[N_BITS-1:0] sec_weight_vector[SIZE_N][1];
	logic[N_BITS-1:0] column_m[SIZE_M][1];
	logic[N_BITS-1:0] sum_squares;
	
	logic[N_BITS-1:0] transposed_weight_vector[1][SIZE_N];
	logic[N_BITS-1:0] term_c[1][SIZE_M];

//=======================================
// Initialisation
//=======================================
	initial begin
		p = 4'd0;
		for(int i = 0; i < SIZE_N; i++) begin
			// Randomize the initial weight column vector as a placeholder.
			randomize(initial_weight_vector[i][0]);
			sec_weight_vector[i][0] = initial_weight_vector[i][0];
		end
		column_m = '{default:1};
	end
	
	// TODO: Alternative with fed in initial_weight_vector[i][0] = unmix_matrix[i][p];
	
//=======================================
// First derivative of w[p+1]
//=======================================
	
	// Transpose weight vector w at p to obtain (1 x N) row vector. Updates for all change to initial_weight_vector.
	transpose_mat #(.SIZE_A(SIZE_N), .SIZE_B(1), .N_BITS(N_BITS)) tp0(.mat(initial_weight_vector), .mat_out(transposed_weight_vector));
	// Multiply weight vector w at p by initial signals matrix X to obtain (1 x M) row vector. Updates for changes in either matrix.
	multiply_mat #(.SIZE_A(1), .SIZE_B(SIZE_N), .SIZE_C(SIZE_M), .N_BITS(N_BITS)) mp0(.mat_a(transposed_weight_vector), .mat_b(matrix), .mat_out(term_c));
	
	// Upates when the common term w[p]^T * X changes.
	always @(term_c) begin
		logic[N_BITS-1:0] derived_term_c[SIZE_M][1];
		logic[N_BITS-1:0] sec_derived_term_c[1][SIZE_M];
		for(int k = 0; k < SIZE_M; k++) begin
			// Obtain (1 x M) column vector with results of g linear transformation.
			derived_term_c[0][k] = first_der(term_c[0][k]);
			// Obtain (1 x M) column vector with results of g' linear transformation.
			sec_derived_term_c[0][k] = sec_der(term_c[0][k]);
		end
	end
	
	// Transpose the derived term c as defined in breakdown to obtain (M x 1) column vector. Updates for all change to the result of the previous multiplication.
	transpose_mat #(.SIZE_A(1), .SIZE_B(SIZE_M), .N_BITS(N_BITS)) tp1(.mat(derived_term_c), .mat_out(transposed_term_c));
	
	// Multiply initial signals matrix by derived transposed term c to obtain (N x 1) column vector.
	multiply_mat #(.SIZE_A(SIZE_N), .SIZE_B(SIZE_M), .SIZE_C(1), .N_BITS(N_BITS)) mp1(.mat_a(matrix), .mat_b(derived_trans_term_c), .mat_out(term_a_minus));
	// Multiply previous result matrix by 1/M to obtain a scaled (N x 1) column vector.
	scalar_multiply_mat #(.SIZE_A(SIZE_N), .SIZE_B(1), .N_BITS(N_BITS)) sm0(.scale(1/SIZE_M), .mat(term_a_minus), .mat_out(term_a));
	
	// Multiply the second derivative of term c by 1/M to obtain a scaled (1 x M) row vector.
	scalar_multiply_mat #(.SIZE_A(1), .SIZE_B(SIZE_M), .N_BITS(N_BITS)) sm1(.scale(1/SIZE_M), .mat(sec_derived_term_c), .mat_out(scaled_term_c));
	

	// Multiply previously obtained matrix by column matrix populated with 1s to obtain a (1x1) matrix.
	multiply_mat #(.SIZE_A(1), .SIZE_B(SIZE_M), .SIZE_C(1), .N_BITS(N_BITS)) mp2(.mat_a(scaled_term_c), .mat_b(column_m), .mat_out(multiplied_term_c));
	
	// (N x 1)
	multiply_mat #(.SIZE_A(SIZE_N), .SIZE_B(1), .SIZE_C(1), .N_BITS(N_BITS)) mp3(.mat_a(initial_weight_vector), .mat_b(multiplied_term_c), .mat_out(term_b));
	
	// (N x 1)
	substract_mat #(.SIZE_A(SIZE_N), .SIZE_B(1), .N_BITS(N_BITS)) sb0(.mat_a(term_a), .mat_b(term_b), .out_matrix(w_prime));
	
	
//======================================
// Second derivative of w[p+1]
//======================================
	
	multiply_mat #(.SIZE_A(1), .SIZE_B(SIZE_N), .SIZE_C(1), .N_BITS(N_BITS)) mp4(.mat_a(transposed_weight_vector), .mat_b(sec_weight_vector), .mat_out(term_d));
	
	multiply_mat #(.SIZE_A(SIZE_N), .SIZE_B(1), .SIZE_C(1), .N_BITS(N_BITS)) mp5(.mat_a(sec_weight_vector), .mat_b(term_d), .mat_out(term_e));
	
	logic[N_BITS-1:0] sum[SIZE_N][1];
	substract_mat #(.SIZE_A(SIZE_N), .SIZE_B(1), .N_BITS(N_BITS)) sb1(.mat_a(initial_weight_vector), .mat_b(sum), .out_matrix(w_sec_prime));
	
//=======================================
// Final calculation of w[p+1]
//=======================================
	
	always @(w_sec_prime) begin
		//EUCLIDEAN NORM, requires additional sqrt() use in next module.
		for(int i = 0; i < SIZE_N; i++) begin
			sum_squares = sum_squares + pow(w_sec_prime[i][0], 2);
		end
	end
	
	scalar_divide_mat #(.SIZE_A(SIZE_N), .SIZE_B(1), .N_BITS(N_BITS)) sd0(.scale(sqrt(sum_squares)), .matrix(w_sec_prime), .out_matrix(w_updated));
	
	
	// When the weight vector is fully calculated.
	always @(w_updated) begin
		for(int i = 0; i < SIZE_N; i++) begin
			// Copy the updated weight vector, w[p], to the unmixing matrix in the appropriate IC column.
			unmix_matrix[i][p] = w_updated[i][0];
			// Copy it to the initial weight vector as well to trigger next cycle of algorithm. 
			initial_weight_vector[i][0] = w_updated[i][0];
		end
		// Increase p to switch to the next component calculation.
		p = p + 1;
	end
	
//=======================================
// Final extraction: S = (W^T) * X
//=======================================

	transpose_mat #(.SIZE_A(SIZE_N), .SIZE_B(SIZE_C), .N_BITS(N_BITS)) tp15(.mat(unmix_matrix), .mat_out(transposed_unmix_matrix));

	multiply_mat #(.SIZE_A(SIZE_C), .SIZE_B(SIZE_N), .SIZE_C(SIZE_M), .N_BITS(N_BITS)) m15(.mat_a(transposed_unmix_matrix), .mat_b(matrix), .mat_out(ic_matrix));
	
//=======================================
// Linear transformation functions
//=======================================
	
	function shortreal f(shortreal u);
		return (0 - exp((0 - sqrt(u))/2));
	endfunction
	
	function shortreal first_der(shortreal u);
		return (u * exp((0 - sqrt(u))/2));
	endfunction
	
	function shortreal sec_der(shortreal u);
		return (1 - sqrt(u))*(exp((0 - sqrt(u))/2));
	endfunction
	
	function shortreal absolute(shortreal x);
		if (x >= 0.0) return(x);
		else return(-x);
	endfunction

endmodule
