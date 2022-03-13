import fp_double::*;

module double_divide_num
(
	input logic clk,
	input logic start,
	input double divisor,
	input double dividend,
	output double final_quotient,
	output logic valid
);
	
	double accumulator[53];
	double quotient[53];

	always_comb begin
		valid = 1'b0;
		final_quotient = '{default: 0};
		quotient = '{default: 0};
		accumulator = '{default: 0};
		
		//Set sign of quotient based on two input signs
		if(dividend.sign == divisor.sign) begin
			$display("Mark!");				
			final_quotient.sign = 1'd0;
		end
		else begin
			final_quotient.sign = 1'd1;
		end
		
		//Loop over the 52 mantissa bits of the floating point number
		for(int i = 0; i < 52; i++) begin
			//Add the next bit to the LSB of the accumulator
			accumulator[i][0] = dividend[51-i];
			
			//If the ith accumulation of i bits is larger than the divisor
			if(accumulator[i][51:0] >= divisor[51:0]) begin
				//Substract the divisor from the accumulator, shift left once.
				accumulator[i+1] = (accumulator[i] - divisor[51:0]) <<< 1;
				quotient[i][51-i] = 1'd1;
				quotient[i+1] = quotient[i];
				$display("Marka!");
			end
			
			else begin
				//Shift the bits to the left by 1, allowing for next bit to be written
				accumulator[i+1] = accumulator[i] <<< 1;
				quotient[i][51-i] = 1'd0;
				quotient[i+1] = quotient[i];
				$display("Markb!");
			end
			
		end
		
		final_quotient.mantissa = quotient[52].mantissa;
		final_quotient.exponent = (dividend.exponent - divisor.exponent + 1023);
		valid = 1'b1;
	end

endmodule
