module squareroot #(
	parameter N_BITS = 32
)
(
	input logic signed[N_BITS-1:0] number,
	output logic signed[(N_BITS/2)-1:0] out_number
);

	logic signed[N_BITS+N_BITS:0] follow;
	logic signed[N_BITS+N_BITS+120:0] start, ans, mid, sqr;

	always_comb begin
		if (number == 0 || number == 1) begin
        		out_number = number;
		end

		follow = number / 2;
		start = 0;
		for(start = 0; start < follow; ++start) begin
			mid = (start - 1 + follow) / 2;
			$display("Mid: %d", mid);
			$display("Start: %d", start);
			$display("End: %d", follow);

			sqr = mid * mid;
			$display("Sqr: %d", sqr);
			if (sqr == number) begin
            			out_number = mid;
			end
        		else if (sqr <= number) begin
            			start = mid + 1;
            			ans = mid;
        		end
        		else begin // If mid*mid is greater than x
            			follow = mid - 1;
			end
		end
    		out_number = ans;
	end
		
	
endmodule
