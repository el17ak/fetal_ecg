package fsm_whiten;

	typedef enum{
		INITIALISATION,
		WAIT,
		INITIALISING,
		RECURSIVE_LOOP,
		EIGENVALUE,
		COV_UPDATE,
		FINISHED,
		XXX
	} state_whiten;

endpackage
