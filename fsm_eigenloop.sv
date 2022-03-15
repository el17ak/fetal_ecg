package fsm_eigenloop;

	typedef enum logic[3:0]{
		INITIALISING_EL = 4'b0000,
		WAIT_EL = 4'b0001,
		RECURSION_EL = 4'b0010,
		CONVERGENCE_EL = 4'b0100,
		FINISHED_EL = 4'b1000,
		XXX_EL = 'x
	} state_eigenloop;

endpackage
