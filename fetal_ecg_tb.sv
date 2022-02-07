`timescale 1 ns/100 ps

module fetal_ecg_tb();

	logic[7:0] scale_tb;
	
	initial begin
		scale_tb = 8'd1; #2;
		scale_tb = 8'd2; #2;
		scale_tb = 8'd3; #2;
		
	end

	fetal_ecg e(.scale(scale_tb));

endmodule
