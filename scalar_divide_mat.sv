import fp_double::*;

module scalar_divide_mat #(
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input logic clk,
	input logic start,
	input double scale,
	input double mat[SIZE_A][SIZE_B],
	output double mat_out[SIZE_A][SIZE_B],
	output logic valid
);
	
	double temp[SIZE_A][SIZE_B];
	logic unsigned[SIZE_A+SIZE_B-2:0] validity;
	
	genvar i, j;
	generate
		for(i = 0; i < SIZE_A; i++) begin: gen1
			for(j = 0; j < SIZE_B; j++) begin: gen2
				double_divide_num d0(.clk(clk), .start(start), .dividend(mat[i][j]), .divisor(scale), .final_quotient(temp[i][j]), .valid(validity[i+j]));
			end
		end
	endgenerate

	always_comb begin
		valid <= 1'b0;
		if(validity == {SIZE_A+SIZE_B-1{1'b1}}) begin
			for(int i = 0; i < SIZE_A; i++) begin
				for(int j = 0; j < SIZE_B; j++) begin
					//mat_out[i][j][85] <= temp[i][j][179];
					//mat_out[i][j][84:0] <= temp[i][j][84:0];
					mat_out[i][j] <= temp[i][j];
				end
			end
			valid <= 1'b1;
		end
		else begin
			mat_out <= '{default:0};
		end
	end

endmodule
