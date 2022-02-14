module eigenloop #(
	parameter SIZE_N = 8,
	parameter MAX_ITER = 8
)
(
	input logic clk,
	input logic rst,
	input integer timed_matrix[SIZE_N][SIZE_N],
	input integer vectors_in[MAX_ITER][SIZE_N][1],
	output integer vectors_out[MAX_ITER][SIZE_N][1],
	output integer out_k
);

	integer copy_vector_k[SIZE_N][1];
	integer copy_vector_kplus[SIZE_N][1];
	integer count_k = 0;
	integer copy_vector_out[SIZE_N][1];

	logic calculated;
	
	convergence_check #(.SIZE_N(SIZE_N), .MAX_ITER(MAX_ITER)) co_no(.clk(clk), .rst(rst), .vector(copy_vector_k), .next_vector(copy_vector_kplus), .count_k(count_k), .converged(converged), .calculated(finish_convergence));
	
	recursive_vector #(.SIZE_N(SIZE_N), .MAX_ITER(MAX_ITER)) re_ve(.clk(clk), .rst(rst), .timed_matrix(timed_matrix), .count_k(count_k), .vector_in(copy_vector_kplus), .vector_out(copy_vector_out));
	
	always_ff @(posedge clk) begin
		if(rst == 0) begin
			out_k <= 0;
			copy_vector_k <= vectors_in[0];
			copy_vector_kplus <= vectors_in[1];
		end
		else begin
			if(count_k == 0) begin
				copy_vector_k <= vectors_in[0];
				copy_vector_kplus <= vectors_in[1];
				count_k <= count_k + 1;
			end
			//If vectors k+1 and k have converged
			else if(converged || count_k == MAX_ITER) begin
				vectors_out[count_k] <= copy_vector_out;
				out_k <= count_k;
				count_k <= 0;
			end
			else begin
				copy_vector_k <= copy_vector_kplus;
				copy_vector_kplus <= copy_vector_out;
				count_k <= count_k + 1;
			end
		end
	end

endmodule
