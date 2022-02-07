module data_packet(
	input bit[21:0] data
);

	bit[21:0] ecg_data;
	
	
	function transfer(bit[31:0] word);
		begin
			ecg_data = word;
		end
	endfunction
	
endmodule
