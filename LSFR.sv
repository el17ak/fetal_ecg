module LFSR (
	input clk,
	input reset,
	output [51:0] rnd 
);

	logic feedback = random[51] ^ random[3] ^ random[2] ^ random[0]; 

	logic[51:0] random, random_next, random_done;
	logic[3:0] count, count_next; //to keep track of the shifts

	always_ff @(posedge clk) begin
		if (reset) begin
			random <= 52'hF; //An LFSR cannot have an all 0 state, thus reset to FF
			count <= 0;
		end
		else begin
			random <= random_next;
			count <= count_next;
		end
	end

	always_comb begin
		random_next = random; //default state stays the same
		count_next = count;

		random_next = {random[50:0], feedback}; //shift left the xor'd every posedge clock
		count_next = count + 1;

		if (count == 52) begin
			count = 0;
			random_done = random; //assign the random number to output after 52 shifts
		end
 
	end


assign rnd = random_done;

endmodule
