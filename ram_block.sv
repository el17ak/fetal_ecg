module ram_block #(
	parameter SIZE_N = 8,
	parameter N_BITS = 64
)
(
	input logic clk,
	input logic rw,
	input logic[N_BITS-1:0] data_to_write,
	input logic unsigned[19:0] address,
	output reg[N_BITS-1:0] data_out
);

	reg[N_BITS-1:0] data[SIZE_N];
	
	always_ff @(posedge clk) begin
		//Write operation
		if(rw == 1) begin
			data[address] <= data_to_write;
		end
		data_out <= data[address];
	end

endmodule
