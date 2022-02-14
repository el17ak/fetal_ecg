module frobenius_norm #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input logic clk,
	input integer mat[SIZE_A][SIZE_B],
	output real val
);

	real sum;
	integer abs[SIZE_A][SIZE_B];
	//integer val;
	
	always_comb begin
		sum <= 0;
		for(int i = 0; i < SIZE_A; i++) begin
			for(int j = 0; j < SIZE_B; j++) begin
				$display("abs: %d", absolute(mat[i][j]));
				sum <= sum + ($pow(mat[i][j], 2));
			end
		end
	end

	always_ff @(posedge clk) begin
		val <= $sqrt(sum);
	end
		
	function integer absolute(integer x);
		if (x >= 0.0) return(x);
		else return(-x);
	endfunction

endmodule
