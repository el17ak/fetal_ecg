`timescale 100 ps/1 ps

module fetal_ecg_tb();

	integer scale_tb;
	logic clk;
	logic rst_n;

	fetal_ecg e(.scale(scale_tb), .clk(clk), .rst_n(rst_n));

	initial begin
		scale_tb <= 0;
		rst_n <= 1;
		clk <= 0;
		#1;
		clk <= 1;
	end

	always begin
		$display("Clock");
		clk = ~clk;
		if(scale_tb%32 == 31) begin
			$display("Reset");
			rst_n = ~rst_n;
		end
		#1;
		scale_tb++;
	end
	
endmodule
