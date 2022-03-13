import fp_double::*;

module w_final #(
	parameter SIZE_N = 8,
	parameter N_BITS_VEC = 32
)
(
	input logic clk,
	input logic rst,
	input logic start,
	input double w_second[SIZE_N][1],
	output double w_out[SIZE_N][1],
	output logic busy,
	output logic valid
);

	logic valid_frobenius;

	//double_frobenius_norm #() fr0();
	
	//scalar_substract_mat #() ss0();
	
	
	always_ff @(posedge clk) begin
		
		if(valid_frobenius == 1) begin
			//move output of frobenius to scalar substractor
		end
		
	end

endmodule
