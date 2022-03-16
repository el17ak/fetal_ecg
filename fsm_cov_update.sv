package fsm_cov_update;

	typedef enum logic[3:0]{
		WAIT_CU = 4'b0000,
		MULTIPLYING1_CU = 4'b0001,
		MULTIPLYING2_CU = 4'b0010,
		SUBSTRACTING_CU = 4'b0100,
		FINISHED_CU = 4'b1000,
		XXX_CU = 'x
	} state_cov_update;

endpackage
