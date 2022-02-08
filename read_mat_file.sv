module read_mat_file #(
	parameter TYPE = 0,
	parameter SIZE_A = 8,
	parameter SIZE_B = 8,
	parameter N_BITS = 22
)
(
	output logic[N_BITS-1:0] out_matrix[SIZE_A][SIZE_B]
);
	
	/**initial begin
		int fd;
		fd = $fopen("testfile.txt", "r");
		
		
		$readmemh("testfile.txt", out_matrix);
	
		$fclose(fd);
	end**/

endmodule
