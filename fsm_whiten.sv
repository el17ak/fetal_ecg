package fsm_whiten;

	typedef enum{
		INITIALISATION_WH,
		WAIT_WH,
		INITIALISING_WH,
		RECURSIVE_LOOP_WH,
		EIGENVALUE_WH,
		COV_UPDATE_WH,
		FINISHED_WH,
		XXX_WH
	} state_whiten;

endpackage
