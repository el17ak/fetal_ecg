module unpacked_to_packed #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input integer mat[SIZE_A][SIZE_B],
	output logic[SIZE_A-1:0][SIZE_B-1:0][31:0] mat_out
);
	
	always_comb begin
		for(int i = 0; i < SIZE_A; i++) begin
			for(int j = 0; j < SIZE_B; j++) begin
				for(int k = 0; k < 32; k++) begin
					mat_out[i][j] = 32'(mat[i][j]);
				end
			end
		end
	end

endmodule
