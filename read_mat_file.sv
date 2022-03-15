module read_mat_file #(
	parameter NAME = "testfile.txt",
	parameter TYPE = 0,
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter BITS = 64
)
(
	input logic clk,
	output logic signed[BITS-1:0] out_matrix[SIZE_A][SIZE_B]
);
	
	initial begin
		int fd;
		$display("Before opening");
		fd = $fopen(NAME, "r");
		$display("Opened");

		if(TYPE == 0) begin
			$readmemh(NAME, out_matrix);
		end	
		else begin
			$readmemb(NAME, out_matrix);
		end
		
		$display("Closing");
		$fclose(fd);
	end

endmodule
