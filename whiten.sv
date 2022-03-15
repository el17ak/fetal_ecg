//============================================
// Data Whitening Algorithm
//============================================
// Author: Anna Irma Elizabeth KENNEDY
// MEng University of Leeds, 2022
//============================================

import fp_double::*;
import fsm_whiten::*;

module whiten #(
	parameter SIZE_A = 8, //Number of rows
	parameter SIZE_B = 8, //Number of columns
	parameter N_BITS = 32 //Fetal ECG => 22-bit initial data
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input integer scale,
	input logic signed[N_BITS-1:0] mat[SIZE_A][SIZE_B],
	output double mat_out[SIZE_A][SIZE_B],
	output logic f
);

	state_whiten state, next;
	
	logic finished[4];

	logic signed[N_BITS+3-1:0] centered_mat[SIZE_A][SIZE_B]; //25-bit
	logic signed[N_BITS+3-1:0] transposed_centered_mat[SIZE_B][SIZE_A]; //25-bit

	logic signed[57-1:0] cov_mat[SIZE_A][SIZE_A]; //57-bit covariance matrix
	double double_cov_mat[SIZE_A][SIZE_A];
	double double_centered_mat[SIZE_A][SIZE_B];
	double eigvec_mat[SIZE_A][SIZE_A][1];
	double transformed_eigvec_mat[SIZE_A][SIZE_A];
	double eigvalues[SIZE_A][1][1];
	double transformed_eigvalues[SIZE_A];

	//Calculate Sigma = D * D^T to find the covariance matrix of the input data
	center #(.SIZE_A(SIZE_A), .SIZE_B(SIZE_B), .N_BITS(N_BITS)) c0(.mat(mat), 
		.mat_out(centered_mat));
	
	transpose_mat #(.SIZE_A(SIZE_A), .SIZE_B(SIZE_B), .N_BITS(N_BITS+3)) 
		tp0(.mat(centered_mat), .mat_out(transposed_centered_mat));
	
	multiply_mat #(.SIZE_A(SIZE_A), .SIZE_B(SIZE_B), .SIZE_C(SIZE_A), .N_BITS_A(N_BITS+3), 
		.N_BITS_B(N_BITS+3), .WIDTH_B(7)) mp0(.mat_a(centered_mat), 
		.mat_b(transposed_centered_mat), .mat_out(cov_mat));
		
//==============================================
// Covariance matrix and centered matrix transformation to double precision floating point format
//==============================================
		
	genvar i, j, k;
	generate
		for(i = 0; i < SIZE_A; i++) begin: dconv
			for(j = 0; j < SIZE_A; j++) begin: dconv_bis
				to_double #(.N_BITS_INT(57), .N_BITS_FRAC(0)) td0(
					.clk(clk),
					.rst(rst),
					.num(cov_mat[i][j]),
					.out_num(double_cov_mat[i][j])
				);
			end
			for(k = 0; k < SIZE_B; k++) begin: dconv_bis2
				to_double #(.N_BITS_INT(25), .N_BITS_FRAC(0)) td1(
					.clk(clk),
					.rst(rst),
					.num(centered_mat[i][k]),
					.out_num(double_centered_mat[i][k])
				);
			end
		end
	endgenerate
	
	//Determine the eigenvectors and corresponding eigenvalues of the covariance matrix
	eigenvalue_decomposition #(.SIZE_N(SIZE_A)) eg0(.clk(clk), .mat(double_cov_mat), 
		.eigenvector_mat(eigvec_mat), .eigenvalues(eigvalues), .rst(rst), 
		.scale(scale));

	//Calculate U = V * D the projection onto the PCA space of the centered data
	double_multiply_mat #(.SIZE_A(SIZE_A), .SIZE_B(SIZE_A), .SIZE_C(SIZE_B)) 
		mp1(.mat_a(transformed_eigvec_mat), .mat_b(double_centered_mat), 
		.mat_out(mat_out));

	/**always_ff @(posedge clk) begin
		if(rst == 0) begin
			transformed_eigvec_mat <= '{default:0};
		end
		else begin
			for(int i = 0; i < SIZE_A; i++) begin
				for(int j = 0; j < SIZE_A; j++) begin
					transformed_eigvec_mat[i][j] <= eigvec_mat[j][i][0];
				end
			end
		end
	end**/
	
	
//=================================================
// FSM Registers and States Update Loop	
//=================================================

	always_comb begin
		f = '0;
		case(state)
			WAIT_WH: begin
				if(start) begin
					next = INITIALISING_WH;
				end
				else begin
					next = WAIT_WH;
				end
			end
			
			INITIALISING_WH: begin
				if(finished[0]) begin
					next = RECURSIVE_LOOP_WH;
				end
				else begin
					next = INITIALISING_WH;
				end
			end
			
			RECURSIVE_LOOP_WH: begin
				if(finished[1]) begin
					next = EIGENVALUE_WH;
				end
				else begin
					next = RECURSIVE_LOOP_WH;
				end
			end
			
			EIGENVALUE_WH: begin
				if(finished[2]) begin
					next = COV_UPDATE_WH;
				end
				else begin
					next = EIGENVALUE_WH;
				end
			end
			
			COV_UPDATE_WH: begin
				if(finished[3]) begin
					next = FINISHED_WH;
				end
				else begin
					next = COV_UPDATE_WH;
				end
			end
			
			FINISHED_WH: begin
				next = FINISHED_WH;
				f = '1;
			end
		endcase
	end
	
	
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= WAIT_WH;
		end
		else begin
			state <= next;
		end
	end
	
	
	
endmodule
