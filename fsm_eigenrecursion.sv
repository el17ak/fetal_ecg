package fsm_eigenrecursion;

	typedef enum logic[3:0]{
		WAIT_ER = 4'b0000,
		MULTIPLYING_ER = 4'b0001,
		FROBENIUS_ER = 4'b0010,
		DIVIDING_ER = 4'b0100,
		FINISHED_ER = 4'b1000,
		XXX_ER = 'x
	} state_eigenrecursion;

endpackage
