module read_mat_file #(
	parameter TYPE = 0,
	parameter SIZE_A = 8,
	parameter SIZE_B = 8
)
(
	output integer out_matrix[SIZE_A][SIZE_B]
);
	
	initial begin
		int fd;
		fd = $fopen("testfile.txt", "r");
		
		
		$readmemh("testfile.txt", out_matrix);
	
		$fclose(fd);
	end

endmodule
