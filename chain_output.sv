module chain_output #(
	parameter TYPE = 0,
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	input integer vec_in[SIZE_A][SIZE_B],
	output integer vec_out[SIZE_A][SIZE_B]
);
	//typedef integer vec[SIZE_][1];
	
	always_comb begin
		if(TYPE == 0) begin
			vec_out <= vec_in;
		end
		//else begin
			
		//end
	end
	
endmodule

module increment(
	input integer in,
	output integer out
);

	always_comb begin
		out = in;
	end

endmodule
