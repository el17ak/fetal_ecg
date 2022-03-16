package fsm_conv;
	
	typedef enum logic[2:0]{
		WAIT_CV = 3'b000,
		SUBSTRACTING_CV = 3'b001,
		FROBENIUS_CV = 3'b010,
		FINISHED_CV = 3'b100,
		XXX_CV = 'x
	} state_conv;

endpackage
