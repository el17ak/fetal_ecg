package fp_double;

	typedef struct packed{
		logic unsigned[0:0] sign; //1 bit which represents sign
		logic unsigned[10:0] exponent; //11 bits representing exponent
		logic unsigned[51:0] mantissa; //52 bits representing significant digits
	} double;

	
	//Adds two double-precision FP numbers a and b
	/**function double add_double(double a, double b);
		reg[51:0] temp = 0;
		double result;
		
		//If the exponents are NOT the same, we need to adjust the smaller one
		if(!(a.exponent == b.exponent)) begin
			if(a.exponent > b.exponent) begin //Adjust b if it is smaller
				temp = b.mantissa;
				
				for(int i = 0; i < 12; i++) begin
					if(i < (a.exponent - b.exponent)) begin
						temp = 52'(temp >> 1);
					end
				end

				result.mantissa = 52'(temp + a.mantissa);
				result.exponent = a.exponent;
			end
			
			else if(b.exponent > a.exponent) begin //Adjust a if it is smaller
				temp = a.mantissa;
				
				for(int i = 0; i < 12; i++) begin
					if(i < (b.exponent - a.exponent)) begin
						temp = 52'(temp >> 1);
					end
				end
				
				result.mantissa = 52'(temp + b.mantissa);
				result.exponent = b.exponent;
			end
		end
		
		else begin //If the two exponents were the same, simple addition
			result.mantissa = 52'(a.mantissa + b.mantissa);
			result.exponent = a.exponent;
		end
		
		return normalise(result);
	endfunction
	
	
	//Substracts double-precision FP number b from number a -> (a - b)
	function double sub_double(double a, double b);
		reg[51:0] temp = 0;
		double result;
		
		//If the exponents are NOT the same, we need to adjust the smaller one
		if(!(a.exponent == b.exponent)) begin
			if(a.exponent > b.exponent) begin //Adjust b if it is smaller
				temp = b.mantissa;
				
				for(int i = 0; i < 12; i++) begin
					if(i < (a.exponent - b.exponent)) begin
						temp = 52'(temp >> 1);
					end
				end

				result.mantissa = 52'(a.mantissa - temp);
				result.exponent = a.exponent;
			end
			
			else if(b.exponent > a.exponent) begin //Adjust a if it is smaller
				temp = a.mantissa;
				
				for(int i = 0; i < 12; i++) begin
					if(i < (b.exponent - a.exponent)) begin
						temp = 52'(temp >> 1);
					end
				end
				
				result.mantissa = 52'(temp - b.mantissa);
				result.exponent = b.exponent;
			end
		end
		
		else begin //If the two exponents were the same, substract
			result.mantissa = a.mantissa - b.mantissa;
			result.exponent = a.exponent;
		end
		
		return normalise(result);
	endfunction**/
	
	
	//Multiplies two double-precision FP numbers a and b
	function double mul_double(double a, double b);
		double result;
		result.sign = (a.sign & b.sign);
		
		result.mantissa = 52'(a.mantissa * b.mantissa);
		result.exponent = 11'(a.exponent + b.exponent);
		return normalise(result);
	endfunction
	
	
	//Converts a packed array of logic to a double value
	/**function double to_double(int N_BITS_INT, int N_BITS_FRAC, logic signed[999:0] num);
		reg[51:0] temp = 0;
		double result;
		reg[64-1:0] width = get_real_width(num, N_BITS_INT+N_BITS_FRAC);
		result.sign = num[150];
		for(int i = 0; i < width; i++) begin
			temp[0] = num[width-1-i];
			if(temp[51] == 1) begin
				result.mantissa = temp[51:0];
				result.exponent = 11'(i + 1023);
				temp = temp + 1;
				return result;
			end
			else begin
				temp = temp << 1;
			end
		end
		//If the end of the loop is reached with no 1 attained
		result.exponent = 11'd1023;
		result.mantissa = 52'd0;
		return result;
	endfunction**/
	
	
	//Normalises the FP number, i.e., the MSB of the mantissa must be 1
	function double normalise(double num);
		automatic reg[51:0] temp = 0;
		double result;
		result.exponent = num.exponent;
		temp = num.mantissa;
		for(int i = 0; i < 52; i++) begin
			if(temp[51] == 1) begin
				result.mantissa = temp;
				return result;
			end
			else begin
				temp = 52'(temp << 1);
				result.exponent = 11'(result.exponent - 1);
			end
		end
	endfunction
	
	
	//Returns the real width of a packed array of bits (from the MSB = 1)
	function int get_real_width(logic signed[150:0] num, int num_bits);
		for(int i = 1; i < num_bits; i++) begin
			if((num[num_bits-1-i]) == 1) begin
				return (num_bits - i + 1);
			end
		end
		return 0;
	endfunction

endpackage
