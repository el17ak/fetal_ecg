module divide_num #(
	parameter N_BITS_DIVISOR = 32,
	parameter N_BITS_DIVIDEND = 32,
	parameter N_BITS_QUOTIENT = 32
)
(
	input logic clk,
	input logic start,
	input logic signed[N_BITS_DIVISOR-1:0] divisor,
	input logic signed[N_BITS_DIVIDEND-1:0] dividend,
	output logic signed[N_BITS_QUOTIENT-1:0] final_quotient,
	output logic valid
);
	
	logic signed [N_BITS_DIVIDEND:0] accumulator[N_BITS_DIVIDEND];
	logic signed [N_BITS_DIVIDEND-1:0] quotient[N_BITS_DIVIDEND];

	always_comb begin
		valid = 0;
		final_quotient = '{default: 0};
		quotient = '{default: 0};
		accumulator = '{default: 0};
		//Set sign of quotient based on two input signs
		if(dividend[N_BITS_DIVIDEND-1] == divisor[N_BITS_DIVISOR-1]) begin		
			final_quotient[N_BITS_QUOTIENT-1] = 1'd0;
		end
		else begin
			final_quotient[N_BITS_QUOTIENT-1] = 1'd1;
		end
		
		for(int i = 0; i < N_BITS_DIVIDEND-1; i++) begin
			//Add the next bit to the LSB of the accumulator
			accumulator[i][0] = dividend[N_BITS_DIVIDEND-2-i];
			//If the ith accumulation of i bits is larger than the divisor
			if(accumulator[i][N_BITS_DIVIDEND-2:0] >= divisor[N_BITS_DIVISOR-2:0]) begin
				//Substract the divisor from the accumulator, shift left once.
				accumulator[i+1] = (accumulator[i] - divisor[N_BITS_DIVISOR-2:0]) <<< 1;
				quotient[i][N_BITS_QUOTIENT-2-i] = 1'd1;
				quotient[i+1] = quotient[i];
			end
			else begin
				//Shift the bits to the left by 1, allowing for next bit to be written
				accumulator[i+1] = accumulator[i] <<< 1;
				quotient[i][N_BITS_QUOTIENT-2-i] = 1'd0;
				quotient[i+1] = quotient[i];
			end
			
		end
		
		final_quotient = quotient[N_BITS_DIVIDEND-2];
		valid = 1;
	end

endmodule
