	interface REG_BUS # (
		parameter				P_ADDR_WIDTH = 16		
	) (
		input						CLK		,
		input						RST		
	);
		logic						WREN	;
		logic	[P_ADDR_WIDTH-1:0]	WADR	;
		logic	[31:0]				WDAT	;
		logic						RDEN	;
		logic	[P_ADDR_WIDTH-1:0]	RADR	;
		logic	[31:0]				RDAT	;
		logic						RVLD	;
		modport master	(
			input					CLK		,
			input					RST		,
			output					WREN	,
			output					WADR	,
			output					WDAT	,
			output					RDEN	,
			output					RADR	,
			input					RDAT	,
			input					RVLD	
		);
		modport slave	(
			input					CLK		,
			input					RST		,
			input					WREN	,
			input					WADR	,
			input					WDAT	,
			input					RDEN	,
			input					RADR	,
			output					RDAT	,
			output					RVLD	
		);
	endinterface
	
	interface DDR4_BUS ();
		logic				ddr4_act_n		;//o
		logic	[16: 0]		ddr4_adr		;//o
		logic	[ 1: 0]		ddr4_ba			;//o
		logic	[ 0: 0]		ddr4_bg			;//o
		logic	[ 0: 0]		ddr4_cke		;//o
		logic	[ 0: 0]		ddr4_odt		;//o
		logic	[ 0: 0]		ddr4_cs_n		;//o
		logic	[ 0: 0]		ddr4_ck_t		;//o
		logic	[ 0: 0]		ddr4_ck_c		;//o
		logic				ddr4_reset_n	;//o
		wire	[ 7: 0]		ddr4_dm_dbi_n	;//io
		wire	[63: 0]		ddr4_dq			;//io
		wire	[ 7: 0]		ddr4_dqs_t		;//io
		wire	[ 7: 0]		ddr4_dqs_c		;//io
		modport master(
			output			ddr4_act_n		,//o
			output			ddr4_adr		,//o
			output			ddr4_ba			,//o
			output			ddr4_bg			,//o
			output			ddr4_cke		,//o
			output			ddr4_odt		,//o
			output			ddr4_cs_n		,//o
			output			ddr4_ck_t		,//o
			output			ddr4_ck_c		,//o
			output			ddr4_reset_n	,//o
			inout			ddr4_dm_dbi_n	,//io
			inout			ddr4_dq			,//io
			inout			ddr4_dqs_t		,//io
			inout			ddr4_dqs_c		 //io
		);
		modport slave(
			input			ddr4_act_n		,//i
			input			ddr4_adr		,//i
			input			ddr4_ba			,//i
			input			ddr4_bg			,//i
			input			ddr4_cke		,//i
			input			ddr4_odt		,//i
			input			ddr4_cs_n		,//i
			input			ddr4_ck_t		,//i
			input			ddr4_ck_c		,//i
			input			ddr4_reset_n	,//i
			inout			ddr4_dm_dbi_n	,//io
			inout			ddr4_dq			,//io
			inout			ddr4_dqs_t		,//io
			inout			ddr4_dqs_c		 //io
		);
	
	endinterface
	
	interface LB_BUS # (
		parameter					P_ADDR_WIDTH = 32		
	) ();
		logic						LB_WREQ				;
		logic	[P_ADDR_WIDTH-1:0]	LB_WADR				;
		logic	[31:0]				LB_WDAT				;
		logic						LB_WACK				;
		logic						LB_RREQ				;
		logic	[P_ADDR_WIDTH-1:0]	LB_RADR				;
		logic	[31:0]				LB_RDAT				;
		logic						LB_RACK				;
		modport master	(
			output					LB_WREQ				,
			output					LB_WADR				,
			output					LB_WDAT				,
			input					LB_WACK				,
			output					LB_RREQ				,
			output					LB_RADR				,
			input					LB_RDAT				,
			input					LB_RACK				
		);
		modport slave	(
			input					LB_WREQ				,
			input					LB_WADR				,
			input					LB_WDAT				,
			output					LB_WACK				,
			input					LB_RREQ				,
			input					LB_RADR				,
			output					LB_RDAT				,
			output					LB_RACK				
		);
	endinterface
	
	interface SPI_LB_BUS # (
		parameter					P_ADDR_WIDTH = 32	,	
		parameter					P_DATA_WIDTH = 32		
	) ();
		logic						REQ				;
		logic						RNW				;
		logic	[P_ADDR_WIDTH-1:0]	ADR				;
		logic	[P_DATA_WIDTH-1:0]	WDAT			;
		logic	[P_DATA_WIDTH-1:0]	RDAT			;
		logic						ACK				;
		modport master	(
			output					REQ				,
			output					RNW				,
			output					ADR				,
			output					WDAT			,
			input					RDAT			,
			input					ACK				
		);
		modport slave	(
			input					REQ				,
			input					RNW				,
			input					ADR				,
			input					WDAT			,
			output					RDAT			,
			output					ACK				
		);
	endinterface
	
	interface DDR_TEST_BUS ();
		logic				DDR_TEST		;
		logic	[31:0]		DDR_TEST_ADDR	;
		logic	[31:0]		DDR_TEST_SIZE	;
		logic	[ 1:0]		DDR_TEST_BUSY	;
		logic				DDR_TEST_LED	;
		logic				DDR_TEST_ERR	;
		logic	[ 1:0]		DDR_TEST_CASE	;
		logic	[31:0]		DDR_TEST_WTIME	;
		logic	[31:0]		DDR_TEST_RTIME	;
		modport master (
			output			DDR_TEST		,
			output			DDR_TEST_ADDR	,
			output			DDR_TEST_SIZE	,
			input			DDR_TEST_BUSY	,
			input			DDR_TEST_LED	,
			input			DDR_TEST_ERR	,
			input			DDR_TEST_CASE	,
			input			DDR_TEST_WTIME	,
			input			DDR_TEST_RTIME	
		);
		
		modport slave (
			input			DDR_TEST		,
			input			DDR_TEST_ADDR	,
			input			DDR_TEST_SIZE	,
			output			DDR_TEST_BUSY	,
			output			DDR_TEST_LED	,
			output			DDR_TEST_ERR	,
			output			DDR_TEST_CASE	,
			output			DDR_TEST_WTIME	,
			output			DDR_TEST_RTIME	
		);
	endinterface

	interface MEMW_BUS	(
		input				CLK		,
		input				RST		
	);
		logic				MEMW_REQ	;
		logic	[ 31:0]		MEMW_ADR	;
		logic	[  7:0]		MEMW_LEN	;
		logic				MEMW_ACK	;
		logic				MEMW_RDEN	;
		logic				MEMW_REND	;
		logic	[511:0]		MEMW_RDAT	;
		modport master	(
			input			CLK		,
			input			RST		,
			output			MEMW_REQ	,
			output			MEMW_ADR	,
			output			MEMW_LEN	,
			input			MEMW_ACK	,
			input			MEMW_RDEN	,
			input			MEMW_REND	,
			output			MEMW_RDAT	 
		);
		modport slave (
			input			CLK		,
			input			RST		,
			input			MEMW_REQ	,
			input			MEMW_ADR	,
			input			MEMW_LEN	,
			output			MEMW_ACK	,
			output			MEMW_RDEN	,
			output			MEMW_REND	,
			input			MEMW_RDAT	 
		);
	endinterface
		
	interface MEMR_BUS	(
		input				CLK		,
		input				RST		
	);
		logic				MEMR_REQ	;
		logic	[ 31:0]		MEMR_ADR	;
		logic	[  7:0]		MEMR_LEN	;
		logic				MEMR_ACK	;
		logic				MEMR_WREN	;
		logic				MEMR_WEND	;
		logic	[511:0]		MEMR_WDAT	;
		modport master	(
			input			CLK		,
			input			RST		,
			output			MEMR_REQ	,
			output			MEMR_ADR	,
			output			MEMR_LEN	,
			input			MEMR_ACK	,
			input			MEMR_WREN	,
			input			MEMR_WEND	,
			input			MEMR_WDAT	 
		);
		modport slave (
			input			CLK		,
			input			RST		,
			input			MEMR_REQ	,
			input			MEMR_ADR	,
			input			MEMR_LEN	,
			output			MEMR_ACK	,
			output			MEMR_WREN	,
			output			MEMR_WEND	,
			output			MEMR_WDAT	 
		);
	endinterface
	
	interface MEM_WR_BUS ();
		logic				REQ	;
		logic	[ 31:0]		ADR	;
		logic	[ 19:0]		SIZ	;
		logic				ACK	;
		logic				REN	;
		logic				RDY	;
		logic	[255:0]		DAT	;
		modport master	(
			output			REQ	,
			output			ADR	,
			output			SIZ	,
			input			ACK	,
			output			RDY	,
			input			REN	,
			output			DAT	 
		);
		modport slave (
			input			REQ	,
			input			ADR	,
			input			SIZ	,
			output			ACK	,
			input			RDY	,
			output			REN	,
			input			DAT	 
		);
	endinterface
	
	interface MEM_RD_BUS ();
		logic				REQ	;
		logic	[ 31:0]		ADR	;
		logic	[ 19:0]		SIZ	;
		logic				ACK	;
		logic				RDY	;
		logic				WEN	;
		logic	[255:0]		DAT	;
		modport master	(
			output			REQ	,
			output			ADR	,
			output			SIZ	,
			input			ACK	,
			output			RDY	,
			input			WEN	,
			input			DAT	 
		);
		modport slave (
			input			REQ	,
			input			ADR	,
			input			SIZ	,
			output			ACK	,
			input			RDY	,
			output			WEN	,
			output			DAT	 
		);
	endinterface
	

	interface AXI_BUS();
		logic			RRDY	;
		logic			RDEN	;
		logic	[255:0]	RDAT	;
	
		modport master (
			input			RRDY	,
			output			RDEN	,
			input			RDAT	
		);
		
		modport slave (
			output			RRDY	,
			input			RDEN	,
			output			RDAT	
		);
	endinterface
	
	interface GTH_BUS # (
		parameter		WIDTH = 4		
	) ( );
		logic	[WIDTH-1:0]	GTH_RXP			;
		logic	[WIDTH-1:0]	GTH_RXN			;
		logic	[WIDTH-1:0]	GTH_TXP			;
		logic	[WIDTH-1:0]	GTH_TXN			;
	modport master(
		input			GTH_RXP				,
		input			GTH_RXN				,
		output			GTH_TXP				,
		output			GTH_TXN				
	);
	endinterface
	
	interface ADC_CFG_BUS ();
		logic						NCOA0			;
		logic						NCOA1			;
		logic						NCOB0			;
		logic						NCOB1			;
		logic						PD				;
		logic						SYNCSEn			;
		logic						CSn				;
		logic						SCLK			;
		logic						SDO				;
		logic						SDI				;
		modport master (
			output					NCOA0			,
			output					NCOA1			,
			output					NCOB0			,
			output					NCOB1			,
			output					PD				,
			output					SYNCSEn			,
			output					CSn				,
			output					SCLK			,
			output					SDO				,
			input					SDI				
		);
	endinterface
	
	interface ADC_204_BUS #(
		parameter					P_ADC_WIDTH	 = 8
	) ();
		logic	[P_ADC_WIDTH-1:0]	RX_P			;
		logic	[P_ADC_WIDTH-1:0]	RX_N			;
		logic						SYNC_P			;
		logic						SYNC_N			;
		logic						SYSREF_P		;
		logic						SYSREF_N		;
		modport master (
			output					RX_P			,
			output					RX_N			,
			input					SYNC_P			,
			input					SYNC_N			,
			output					SYSREF_P		,
			output					SYSREF_N			
		);		
		modport slave (
			input					RX_P			,
			input					RX_N			,
			output					SYNC_P			,
			output					SYNC_N			,
			input					SYSREF_P		,
			input					SYSREF_N			
		);		
	endinterface
	
	interface DAC_CFG_BUS ();
		logic						CSn				;
		logic						RESETn			;
		logic						SCLK			;
		logic						SDI				;
		wire						SDO				;
		logic						TXENABLE		;
		modport master (
			output					CSn				,
			output					RESETn			,
			output					SCLK			,
			input					SDI				,
			inout					SDO				,
			output					TXENABLE		
		);
		
		modport slave (
			input					CSn				,
			input					RESETn			,
			input					SCLK			,
			output					SDI				,
			inout					SDO				,
			input					TXENABLE		
		);
	endinterface
	
	interface DAC_204_BUS #(
		parameter		P_DAC_WIDTH	 = 4
	) ();
		logic	[P_DAC_WIDTH-1:0]	TX_P			;
		logic	[P_DAC_WIDTH-1:0]	TX_N			;
		logic						SYNC_P			;
		logic						SYNC_N			;
		logic						SYSREF_P		;
		logic						SYSREF_N		;
		modport master (
			output					TX_P			,
			output					TX_N			,
			input					SYNC_P			,
			input					SYNC_N			,
			input					SYSREF_P		,
			input					SYSREF_N		
		);
	endinterface
	
		interface AXI4_LITE_BUS ();
		logic	[31:0]		araddr				;// output [31:0]
		logic	[ 2:0]		arprot				;// output [ 2:0]	
		logic	[ 0:0]		arready				;// input  [ 0:0]	
		logic	[ 0:0]		arvalid				;// output [ 0:0]	
		logic	[31:0]		awaddr				;// output [31:0]
		logic	[ 2:0]		awprot				;// output [ 2:0]	
		logic	[ 0:0]		awready				;// input  [ 0:0]	
		logic	[ 0:0]		awvalid				;// output [ 0:0]	
		logic	[ 0:0]		bready				;// output [ 0:0]	
		logic	[ 1:0]		bresp				;// input  [ 1:0]	
		logic	[ 0:0]		bvalid				;// input  [ 0:0]	
		logic	[31:0]		rdata				;// input  [31:0]  
		logic	[ 0:0]		rready				;// output [ 0:0]	
		logic	[ 1:0]		rresp				;// input  [ 1:0]	
		logic	[ 0:0]		rvalid				;// input  [ 0:0]	
		logic	[31:0]		wdata				;// output [31:0] 
		logic	[ 0:0]		wready				;// input  [ 0:0]	
		logic	[ 3:0]		wstrb				;// output [ 3:0]	
		logic	[ 0:0]		wvalid				;// output [ 0:0]	
		modport master ( 
			output 			araddr				,//
			output 			arprot				,//
			input  			arready				,//
			output 			arvalid				,//
			output 			awaddr				,//
			output 			awprot				,//
			input  			awready				,//
			output 			awvalid				,//
			output 			bready				,//
			input  			bresp				,//
			input  			bvalid				,//
			input  			rdata				,//
			output 			rready				,//
			input  			rresp				,//
			input  			rvalid				,//
			output 			wdata				,//
			input  			wready				,//
			output 			wstrb				,//
			output 			wvalid				 //
		);
		
		modport slave(
			input 			araddr				,// 
			input 			arprot				,// 
			output  		arready				,// 
			input 			arvalid				,// 
			input 			awaddr				,// 
			input 			awprot				,// 
			output  		awready				,// 
			input 			awvalid				,// 
			input 			bready				,// 
			output  		bresp				,// 
			output  		bvalid				,// 
			output  		rdata				,// 
			input 			rready				,// 
			output  		rresp				,// 
			output  		rvalid				,// 
			input 			wdata				,// 
			output  		wready				,// 
			input 			wstrb				,// 
			input 			wvalid				 // 
		);
			
	endinterface