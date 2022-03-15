package fsm_matop;

	typedef enum logic[2:0]{
		WAIT_MO = 3'b000,
		MULTIPLYING_MO = 3'b001,
		ACCUMULATING_MO = 3'b010,
		FINISHED_MO = 3'b100,
		XXX = 'x
	} state_matop;


endpackage
