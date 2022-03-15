package fsm_eigenprocess;

	typedef enum logic[4:0]{
		WAIT_EP = 5'b00000,
		INITIALISING_EP = 5'b00001,
		RECURSION_EP = 5'b00010,
		EIGENCALCULATION_EP = 5'b00100,
		COV_UPDATE_EP = 5'b01000,
		FINISHED_EP = 5'b10000,
		XXX_EP = 'x
	} state_eigenprocess;

endpackage
