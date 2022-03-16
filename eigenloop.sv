import fp_double::*;
import fsm_eigenloop::*;

module eigenloop #(
	parameter SIZE_N = 8,
	parameter MAX_ITER = 8 //Fetal ECG -> 100
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double timed_matrix[SIZE_N][SIZE_N],
	input double vectors_in[2][SIZE_N][1],
	output double vector_out[SIZE_N][1],
	output integer out_k,
	output logic f
);

	state_eigenloop state, next;
	
	integer count_k, next_k;
	
	double vectors[3][SIZE_N][1];
	double first_vector[SIZE_N][1], second_vector[SIZE_N][1];
	
	logic finished[2];
	logic[1:0] rst_n;
	
	assign out_k = count_k;
	
	
//=======================================================
// Calculate the following vector recursively
//=======================================================

	logic start_recursion, rst_recursion;

	double copy_vector_out[SIZE_N][1];
	
	eigenrecursion #(.SIZE_N(SIZE_N)) re_ve(
		.clk(clk), 
		.rst(rst | rst_n[0]),
		.timed_matrix(timed_matrix),
		.vector_in(vectors[1]), 
		.vector_out(vectors[2]),
		.f(finished[0]),
		.start(start)
	);
	
	
	
//=======================================================
// Verify whether two subsequent vectors have converged
//=======================================================

	logic start_convergence, converged, rst_convergence;
	
	convergence_check #(.SIZE_N(SIZE_N)) co_no(
		.clk(clk), 
		.rst(rst | rst_n[1]),
		.vector(vectors[1]),
		.next_vector(vectors[2]),
		.converged(converged), 
		.f(finished[1]),
		.start(finished[0])
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
	
	logic init, next_init;

	
	always_comb begin
		next = XXX_EL;
		f = '0;
		next_k = count_k;
		next_init = init;
		vector_out = '{default: 0};
		rst_n = 2'b00;
		
		case(state)
			INITIALISING_EL: begin
				next_k = 0;
				if(start) begin
					next_init = '0;
					first_vector = vectors_in[0];
					second_vector = vectors_in[1];
					next = WAIT_EL;
				end
				else begin
					next = INITIALISING_EL;
				end
			end
			
			WAIT_EL: begin
				if(start) begin
					if(init == '0) begin
						rst_n[0] = '1;
						next_init = '1;
						next = WAIT_EL;
					end
					else begin
						rst_n[0] = 0;
						vectors[0] = first_vector;
						vectors[1] = second_vector;
						next = RECURSION_EL;
						$display("Calculating recursive eigenvector");
					end
				end
				else begin
					next = WAIT_EL;
				end
			end
			
			RECURSION_EL: begin
				if(finished[0]) begin
					rst_n[1] = 1;
					next = CONVERGENCE_EL;
					$display("\nCalculating convergence");
				end
				else begin
					next = RECURSION_EL;
					$display(".");
				end
			end
			
			CONVERGENCE_EL: begin
				if(finished[1]) begin
					if(converged || (count_k > MAX_ITER)) begin
						next = FINISHED_EL;
					end
					else begin
						next_init = '0;
						first_vector = vectors[1];
						second_vector = vectors[2];
						next_k = count_k + 1;
						next = WAIT_EL;
					end
				end
				else begin
					next = CONVERGENCE_EL;
					$display(".");
				end
			end
			
			FINISHED_EL: begin
				vector_out = vectors[2];
				f = '1;
				next = FINISHED_EL;
			end
			
			default: begin
				next = XXX_EL;
			end
		endcase
	end
	
	
	
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= INITIALISING_EL;
			count_k <= 0;
			init <= '0;
		end
		else begin
			state <= next;
			count_k <= next_k;
			init <= next_init;
		end
	end
	
	
	
	
endmodule
