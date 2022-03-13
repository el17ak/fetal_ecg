`timescale 100 ps/1 ps

module fetal_ecg_tb();

	integer scale_tb;
	logic clk;
	logic rst_n;

	//fetal_ecg e(.scale(scale_tb), .clk(clk), .rst_n(rst_n));

	initial begin
		scale_tb <= 0;
		rst_n <= 1;
		clk <= 0;
		#1;
		clk <= 1;
	end
	
	
	logic signed[22-1:0] mat_b[8][368];
	logic signed[116-1:0] mat_out[8][32];

	logic signed[21:0] mat_c[8][32];

	genvar u;
	generate
		for(u = 0; u < 8; u++) begin: gen0
			assign mat_c[u] = mat_b[u][0:31];
		end
	endgenerate
	
	logic start = 1;
	logic busy, dbz;
	logic signed[15:0] q, r;
	
	logic clk_50, dram_cas_n, DRAM_CKE, DRAM_CS_N, DRAM_RAS_N, DRAM_WE_N;
	logic DRAM_CLK;
	logic[7:0] LED;
	logic[1:0] KEY, DRAM_BA, DRAM_DQM;
	logic[7:0] SW;
	logic[12:0] DRAM_ADDR;
	wire[15:0] DRAM_DQ;
	logic valid;
	logic[63:0] out;

	fetal_ecg fecg(.CLOCK_50(clk_50),
		.LED(LED),
		.KEY(KEY),
		.SW(SW),
		.DRAM_ADDR(DRAM_ADDR),
		.DRAM_BA(DRAM_BA),
		.DRAM_CAS_N(dram_cas_n),
		.DRAM_CKE(DRAM_CKE),
		.DRAM_CLK(DRAM_CLK),
		.DRAM_CS_N(DRAM_CS_N), 
		.DRAM_DQ(DRAM_DQ),
		.DRAM_DQM(DRAM_DQM),
		.DRAM_RAS_N(DRAM_RAS_N), 
		.DRAM_WE_N(DRAM_WE_N), 
		.scale(scale_tb), 
		.clk(clk),
		.rst_n(rst_n),
		.outer(out),
		.valid(valid));
	
	//center #(.SIZE_A(8), .SIZE_B(8), .N_BITS(32)) c(.mat(mat), .mat_out(mat_out));
	
	//squareroot #(.N_BITS(32)) sq(.clk(clk), .startVar(1'd1), .number(32'b01101001111010100110011100000010), .out_number(numout), .valid(valid));
	//divide_num #(.N_BITS_DIVIDEND(12), .N_BITS_DIVISOR(8), .N_BITS_QUOTIENT(12)) d0(.clk(clk), .start(1'b1), .dividend(12'b011111010100), .divisor(8'b00111110), .final_quotient(result), .busy(busy), .valid(valid));
	
	always begin
		$display("Clock");
		clk = ~clk;
		if(scale_tb%32 == 31) begin
			$display("Reset");
			//rst_n = ~rst_n;
		end
		#1;
		scale_tb++;
	end
	
endmodule
