//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module fetal_ecg(

	//////////// CLOCK //////////
	//input 		          		CLOCK_50,

	//////////// LED //////////
	//output		     [7:0]		LED,

	//////////// KEY //////////
	//input 		     [1:0]		KEY,

	//////////// SW //////////
	//input 		     [3:0]		SW,

	//////////// SDRAM //////////
	//output		    [12:0]		DRAM_ADDR,
	//output		     [1:0]		DRAM_BA,
	//output		          		DRAM_CAS_N,
	//output		          		DRAM_CKE,
	//output		          		DRAM_CLK,
	//output		          		DRAM_CS_N,
	//inout 		    [15:0]		DRAM_DQ,
	//output		     [1:0]		DRAM_DQM,
	//output		          		DRAM_RAS_N,
	//output		          		DRAM_WE_N,

	//////////// EPCS //////////
	//output		          		EPCS_ASDO,
	//input 		          		EPCS_DATA0,
	//output		          		EPCS_DCLK,
	//output		          		EPCS_NCSO,

	//////////// Accelerometer and EEPROM //////////
	//output		          		G_SENSOR_CS_N,
	//input 		          		G_SENSOR_INT,
	//output		          		I2C_SCLK,
	//inout 		          		I2C_SDAT,

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	//inout 		    [33:0]		GPIOA,
	//input 		     [1:0]		GPIOA_IN,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	//inout 		    [33:0]		GPIOB,
	//input 		     [1:0]		GPIOB_IN,
	input logic[7:0] scale
);



//=======================================================
//  REG/WIRE declarations
//=======================================================




//=======================================================
//  Structural coding
//=======================================================

	logic[21:0] matrix_in[8][8] = '{default:0};
	logic[21:0] matrix_out[8][8] = '{default:0};
	
	read_mat_file #(.TYPE(0), .SIZE_A(8), .SIZE_B(8), .N_BITS(22)) rf0(.out_matrix(matrix_in));

	transpose_mat #(.SIZE_A(8), .SIZE_B(8), .N_BITS(22)) tb0(.matrix(matrix_in), .out(matrix_out));



endmodule