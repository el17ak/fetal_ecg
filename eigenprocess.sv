import fp_double::*;
import fsm_eigenprocess::*;

module eigenprocess #(
	parameter SIZE_N = 8,
	parameter MAX_ITER = 100 //Number of bits for input covariance matrix (signed)
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double cov_matrix[SIZE_N][SIZE_N],
	output double eigenvalue[1][1],
	output double eigenvector[SIZE_N][1],
	output double cov_matrix_out[SIZE_N][SIZE_N],
	output logic f
);

	state_eigenprocess state, next;
	
	logic[3:0] finished;

	double vector_init[SIZE_N][1];
	double first_vector[SIZE_N][1];
	double second_vector[SIZE_N][1];
	
	integer count_n;
	integer count_k;
	
	double vectors_input[2][SIZE_N][1];

	
	assign vectors_input[0] = first_vector;
	assign vectors_input[1] = second_vector;
	
	
	
	//Determine first two vectors to launch the loop with
	init_decomposition #(.SIZE_N(SIZE_N)) in_de(
		.clk(clk),
		.rst(rst),
		.start(start),
		.timed_matrix(cov_matrix),
		.vector_init(first_vector), 
		.second_vector(second_vector),
		.f(finished[0])
	);
	
	//Launch loop with initial vectors, keep in state until convergence
	eigenloop #(.SIZE_N(SIZE_N), .MAX_ITER(MAX_ITER)) ei_lo(
		.clk(clk),
		.rst(rst),
		.start(finished[0]),
		.timed_matrix(cov_matrix),
		.vectors_in(vectors_input), 
		.vector_out(eigenvector),
		.out_k(count_k),
		.f(finished[1])
	);

	//Calculate corresponding eigenvalue of obtained (converged) eigenvector
	eigencalculation #(.SIZE_N(SIZE_N)) ei_ca(
		.clk(clk),
		.rst(rst),
		.start(finished[1]),
		.timed_matrix(cov_matrix),
		.vector(eigenvector), 
		.eigenvalue(eigenvalue[0][0]),
		.f(finished[2])
	);
	
	//Finally, remove influence of found eigenpair from data matrix
	cov_mat_update #(.SIZE_N(SIZE_N)) co_up(
		.clk(clk),
		.rst(rst), 
		.start(finished[2]),
		.vector(eigenvector),
		.eigenvalue(eigenvalue),
		.count_n(count_n), 
		.cov_matrix_in(cov_matrix),
		.cov_matrix_out(cov_matrix_out),
		.f(finished[3])
	);
	
	/**always_ff @(posedge clk) begin
		valid <= 0;
		start_loop <= 0;
		start_val <= 0;
		start_mat <= 0;
		if(start == 0) begin
			copy_vector <= '{default:0};
			start_loop <= 0;
			start_val <= 0;
			start_mat <= 0;
		end
		else if(start == 1) begin
			case(state)
				
				4'b0000: begin
					start_loop <= 0;
					start_val <= 0;
					start_mat <= 0;
				end
				
				4'b0001: begin //Initialisation complete
					start_loop <= 1;
					start_val <= 0;
					start_mat <= 0;
				end
				
				4'b0011: begin //Loop completed, converged
					copy_vector <= vector_output;
					eigenvector <= vector_output;
					start_val <= 1;
					start_mat <= 0;
				end
				
				4'b0111: begin
					eigenvalue[0][0] <= eigenvalue_hold;
					start_mat <= 1;
				end
				
				4'b1111: begin
					valid <= 1;
					start_loop <= 0;
					start_val <= 0;
					start_mat <= 0;
				end
				
			endcase
		end
	end**/
	
	
	
	always_comb begin
		f = '0;
		next = XXX_EP;
		case(state)
			WAIT_EP: begin
				if(start) begin
					next = INITIALISING_EP;
				end
				else begin
					next = WAIT_EP;
				end
			end
			
			INITIALISING_EP: begin
				if(finished[0]) begin
					next = RECURSION_EP;
				end
				else begin
					next = INITIALISING_EP;
				end
			end
			
			RECURSION_EP: begin
				if(finished[1]) begin
					next = EIGENCALCULATION_EP;
				end
				else begin
					next = RECURSION_EP;
				end
			end
			
			EIGENCALCULATION_EP: begin
				if(finished[2]) begin
					next = COV_UPDATE_EP;
				end
				else begin
					next = RECURSION_EP;
				end
			end
			
			COV_UPDATE_EP: begin
				if(finished[3]) begin
					next = FINISHED_EP;
				end
				else begin
					next = COV_UPDATE_EP;
				end
			end
			
			FINISHED_EP: begin
				f = '1;
				next = FINISHED_EP;
			end
			
			default: begin
				next = XXX_EP;
			end
		endcase
	end
	
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= WAIT_EP;
		end
		else begin
			state <= next;
		end
	end
	
	
endmodule
