module accumulate_adc_data(
	input logic[31:0] mat_a[4],
	input logic[31:0] mat_b[4],
	output logic[21:0] mat[8][512],
	output logic ready
);

	int j;

	initial begin
		j = 0;
		ready = 1'd0;
	end
	
	always_comb begin
		if(j < 512) begin
			for(int i = 0; i < 4; i++) begin
				mat[i][j] = mat_a[i];
				mat[i+4][j] = mat_b[i];
			end
			j++;
		else begin
			ready = 1'd1;
			#3;
			ready = 0'd0;
		end
	end
	
	always @(negedge ready) begin
		
	end

endmodule
