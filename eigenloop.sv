import fp_double::*;
import fsm_eigenloop::*;

module eigenloop #(
	parameter SIZE_N = 8,
	parameter MAX_ITER = 8 //Fetal ECG -> 100
)
(
	input logic clk,
	input logic rst,
	input integer scale,
	input logic start,
	input double timed_matrix[SIZE_N][SIZE_N],
	input double vectors_in[2][SIZE_N][1],
	output double vector_out[SIZE_N][1],
	output integer out_k,
	output logic valid
);

	state_eigenloop state, next;
	
	integer count_k = 0;
	
	double vectors[3][SIZE_N][1];
	
	logic finished[3];
	
	
//=======================================================
// Calculate the following vector recursively
//=======================================================

	logic start_recursion, rst_recursion;

	double copy_vector_out[SIZE_N][1];
	
	recursive_vector #(.SIZE_N(SIZE_N)) re_ve(
		.clk(clk), 
		.rst(rst_recursion),
		.timed_matrix(timed_matrix),
		.vector_in(vectors[1]), 
		.vector_out(vectors[2]),
		.f(finished[0]),
		.start(start_recursion)
	);
	
	
	
//=======================================================
// Verify whether two subsequent vectors have converged
//=======================================================

	logic start_convergence, converged, rst_convergence;
	
	convergence_check #(.SIZE_N(SIZE_N)) co_no(
		.clk(clk), 
		.rst(rst_convergence),
		.vector(vectors[0]),
		.next_vector(vectors[1]),
		.converged(converged), 
		.f(finished[1]),
		.start(start_convergence)
	);
		
	
	
	/**always_comb begin
		if(count_k == 0) begin
			if(scale > 1) begin
				$display("Marker A");
			end
		end
		if(state == 4'b1000 && converged == 0) begin
			copy_vector_k <= copy_vector_kplus;
			copy_vector_kplus <= copy_vector_out;
		end
	end

	always_ff @(posedge clk) begin
		valid <= 0;
		rst_convergence <= 0;
		rst_recursion <= 0;
		readwrite[0] <= 0;
		readwrite[1] <= 0;
		if(start == 0) begin
			valid <= 0;
			out_k <= 0;
			state[4] <= 0;
		end
		else if(start == 1) begin
			if(count_k == 0) begin
				start_convergence <= 1;
				start_recursion <= 0;
				converted_write[0] <= vectors_in[0][0:SIZE_N-1];
				converted_write[1] <= vectors_in[1][0:SIZE_N-1];
				readwrite[0] <= 1;
				readwrite[1] <= 1;
				count_k <= 1;
			end
			else begin
		
				case(state)
				5'b00000: begin //No steps completed
					$display("Re-initialised");
					valid <= 0;
					ref_ram();
				end

				5'b00001: begin //Convergence being verified
					$display("Convergence begin verified..");
				end

				5'b00010: begin //Convergence checked
					$display("Convergence verified!");
					converted_write[0] <= converted_read[1];
					valid <= 0;
					start_convergence <= 0;
					start_recursion <= 1;
					ref_ram();
				end

				5'b00110: begin //Recursion being calculated
					$display("Recursion being calculated..");
				end

				5'b01010: begin //Recursion performed
					if((converged) || count_k == MAX_ITER) begin
					end
					else begin
						start_convergence <= 0;
						rst_convergence <= 1;
						start_recursion <= 0;
						state[4] <= 1;
					end
				end
				
				5'b11010: begin
					converted_write[1] <= copy_vector_out;
					count_k <= count_k + 1;
					start_convergence <= 1;
					start_recursion <= 0;
					rst_recursion <= 1;
					state[4] <= 0;
				end
				endcase
			end
		end
	end**/
	
	
	
	always_comb begin
		next = XXX_EIGEN;
		f = '0;
		
		case(state)
			INITIALISATION_EIGEN: begin
				vectors[0] = vectors_in[0];
				vectors[1] = vectors_in[1];
				vectors[2] = '0;
				count_k = '0;
				next = WAIT_EIGEN;
			end
			
			WAIT_EIGEN: begin
				if(start) begin
					next = RECURSION_EIGEN;
					$display("Calculating recursive eigenvector");
				end
				else begin
					next = WAIT_EIGEN;
				end
			end
			
			RECURSION_EIGEN: begin
				if(finished[0]) begin
					next = CONVERGENCE_EIGEN;
					$display("\nCalculating convergence");
				end
				else begin
					next = RECURSION_EIGEN;
					$display(".");
				end
			end
			
			CONVERGENCE_EIGEN: begin
				if(finished[1]) begin
					if(converged || (count_k > MAX_ITER)) begin
						next = FINISHED_EIGEN;
					end
					else begin
						vectors[0] = vectors[1];
						vectors[1] = vectors[2];
						count_k = count_k + 1;
						next = WAIT_EIGEN;
					end
				end
				else begin
					next = CONVERGENCE_EIGEN;
					$display(".");
				end
			end
			
			FINISHED_EIGEN: begin
				vector_out = vectors[2];
				f = '1;
				next = FINISHED_EIGEN;
			end
		endcase
	end
	
	
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= INITIALISATION_EIGEN;
		end
		else begin
			state <= next;
		end
	end
	
	
	
	
endmodule
