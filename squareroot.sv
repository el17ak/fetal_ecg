import fp_double::*;

module squareroot #(
	parameter N_BITS = 32
)
(
	input logic clk,
	input logic startVar,
	input logic signed[N_BITS-1:0] number,
	output logic signed[N_BITS/2:0] out_number,
	output logic valid
);
	
	logic signed[N_BITS+N_BITS:0] follow;
	logic signed[N_BITS+N_BITS+120:0] ans, mid, sqr;
	logic signed[N_BITS+N_BITS+120:0] start;
	int count;
	logic start_local;
	
	int unsigned real_width[100];
	
	assign out_number[(N_BITS/2)-1:0] = ans[(N_BITS/2)-1:0];
	assign out_number[N_BITS/2] = ans[N_BITS+N_BITS+120];
	
	
	//Algorithm combinatorial loop: calculates next value
	always_comb begin
		if(count == 0) begin
			real_width[count] = get_real_width(150'(number), N_BITS);
		end
		else begin
			real_width[count+1] = real_width[count];
		end
		mid = (start - 1 + follow) / 2;
		$display("Mid: %d", mid);
		$display("Start: %d", start);
		$display("Follow: %d", follow);
		//Retrieve the squared value of this iteration
		sqr = mid * mid;
		$display("Sqr: %d", sqr);
	end
	
	
	always_ff @(posedge clk) begin
		valid <= 0;
		if(startVar == 0) begin
			count <= 0;
		end
		if (number == 0 || number == 1) begin
        	ans <= number;
			valid <= 1;
			start_local <= 0;
		end
		else if(startVar == 1) begin
			if(count == 0) begin
				follow <= (2 ** (real_width[count]/2)) - 1;
				start <= (2 ** ((real_width[count]/2)-1)) - 1;
				count <= count + 1;
				start_local <= 1;
			end
			else if(start < follow && start_local == 1) begin
				//Compare the iteration's square with the initial number
				if (sqr == number) begin
            	ans <= mid;
					valid <= 1;
					start_local <= 0;
				end
				else begin
					if (sqr <= number) begin
            		start <= mid + 1;
					end
					else begin // If mid*mid is greater than x
						follow <= mid - 1;
					end
				end
				if(count >= real_width[count]) begin
					ans <= mid;
					valid <= 1;
					start_local <= 0;
				end
				else begin
					count <= count + 1;
				end
			end
			else if(start >= follow) begin
				ans <= mid;
				valid <= 1;
				start_local <= 0;
			end
		end
	end
	
		
endmodule
