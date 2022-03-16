package fsm_eigencalculation;

	typedef enum logic[2:0]{
		WAIT_EC = 3'b000,
		MULTIPLYING1_EC = 3'b001,
		MULTIPLYING2_EC = 3'b010,
		FINISHED_EC = 3'b100,
		XXX_EC = 'x
	} state_eigencalculation;

endpackage
