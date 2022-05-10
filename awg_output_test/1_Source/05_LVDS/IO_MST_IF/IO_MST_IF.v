
`timescale 1ns/ 1ps

module IO_MST_IF #(
	parameter   P_5MS 		 = 20'hf4240,
	parameter	C_DATA_WIDTH = 8
) (
	// Clock & Reset
	input							mCLK		,
	input							mx4CLK		,
	input							RST			,
	// Test_Pattern interface
	input	[(C_DATA_WIDTH*8)-1:0]	TX_DAT    	,
	// Fpga External Interface
	output							EXT_CLK_P	,
	output							EXT_CLK_N   ,
	output	[C_DATA_WIDTH-1:0]		EXT_DAT_P   ,
	output	[C_DATA_WIDTH-1:0]		EXT_DAT_N   ,
	// Serial Interface
	input							IO_RX		,
	output							IO_TX       ,
	// Result Information
	output							TRAIN_DONE		
);


	// ============================================
	// Internal Signal Define
	// ============================================

	reg		[(C_DATA_WIDTH*8)-1:0]	r_tx_dat		;
	wire	[(C_DATA_WIDTH)-1:0]	s_ts_data_o		;
	wire							s_outclk		;

	wire	[(C_DATA_WIDTH*8)-1:0]	s_tarin_data	;
	wire							s_tarin_done	;

	///////////////////////////////////////////////
	// Data Output
	///////////////////////////////////////////////
	always @ ( posedge mCLK ) begin
		if ( RST) begin
			r_tx_dat	<= {(C_DATA_WIDTH*8){1'b0}} ;
		end else begin
			if (!s_tarin_done) begin
				r_tx_dat <=  s_tarin_data;
			end else begin
				r_tx_dat	<= TX_DAT ;
			end
		end
	end

	generate
	genvar i ;
		for (i=0;i<C_DATA_WIDTH;i=i+1) begin : U_TX_DATA_GEN

			OSERDESE2 #(
				.DATA_RATE_OQ	("DDR"				), // DDR, SDR
				.DATA_RATE_TQ	("DDR"				), // DDR, BUF, SDR
				.DATA_WIDTH		(8					), // Parallel data width (2-8,10,14)
				.INIT_OQ		(1'b0				), // Initial value of OQ output (1'b0,1'b1)
				.INIT_TQ		(1'b0				), // Initial value of TQ output (1'b0,1'b1)
				.SERDES_MODE	("MASTER"			), // MASTER, SLAVE
				.SRVAL_OQ		(1'b0				), // OQ output value when SR is used (1'b0,1'b1)
				.SRVAL_TQ		(1'b0				), // TQ output value when SR is used (1'b0,1'b1)
				.TBYTE_CTL		("FALSE"			), // Enable tristate byte operation (FALSE, TRUE)
				.TBYTE_SRC		("FALSE"			), // Tristate byte source (FALSE, TRUE)
				.TRISTATE_WIDTH	(1					)  // 3-state converter width (1,4)
			)
			OSERDESE2_inst (
				.OFB			(					), // 1-bit output: Feedback path for data
				.OQ				(s_ts_data_o[i]		), // 1-bit output: Data path output
				// SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
				.SHIFTOUT1		(					),
				.SHIFTOUT2		(					),
				.TBYTEOUT		(					), // 1-bit output: Byte group tristate
				.TFB			(					), // 1-bit output: 3-state control
				.TQ				(					), // 1-bit output: 3-state control
				.CLK			(mx4CLK				), // 1-bit input: High speed clock
				.CLKDIV			(mCLK				), // 1-bit input: Divided clock
				// D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
				.D1				(r_tx_dat[8*i]		),
				.D2				(r_tx_dat[8*i+1]	),
				.D3				(r_tx_dat[8*i+2]	),
				.D4				(r_tx_dat[8*i+3]	),
				.D5				(r_tx_dat[8*i+4]	),
				.D6				(r_tx_dat[8*i+5]	),
				.D7				(r_tx_dat[8*i+6]	),
				.D8				(r_tx_dat[8*i+7]	),
				.OCE			(1'b1				), // 1-bit input: Output data clock enable
				.RST			(RST				), // 1-bit input: Reset
				// SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
				.SHIFTIN1		(1'b0				),
				.SHIFTIN2		(1'b0				),
				// T1 - T4: 1-bit (each) input: Parallel 3-state inputs
				.T1				(1'b0				),
				.T2				(1'b0				),
				.T3				(1'b0				),
				.T4				(1'b0				),
				.TBYTEIN		(1'b0				),	// 1-bit input: Byte group tristate
				.TCE			(1'b0				)   // 1-bit input: 3-state clock enable
			);

			OBUFDS #(
			.IOSTANDARD	("DEFAULT"	) 	// Specify the output I/O standard
			)
			DATA_OBUFDS_inst (
				.O			(EXT_DAT_P[i]	),  // Diff_p output (connect directly to top-level port)
				.OB			(EXT_DAT_N[i]	),  // Diff_n output (connect directly to top-level port)
				.I			(s_ts_data_o[i]	)   // Buffer input
			);
		end
	endgenerate

	ODDR #(
		.DDR_CLK_EDGE	( "OPPOSITE_EDGE"	),// "OPPOSITE_EDGE" or "SAME_EDGE"
		.INIT			( 1'b0				),// Initial value of Q: 1'b0 or 1'b1
		.SRTYPE			( "SYNC"			) // Set/Reset type: "SYNC" or "ASYNC"
	) ODDR_inst (
		.Q				( s_outclk			),// 1-bit DDR output
		.C				( mx4CLK			),// 1-bit clock input
		.CE				( 1'b1				),// 1-bit clock enable input
		.D1				( 1'b1  			),// 1-bit data input (positive edge)
		.D2				( 1'b0				),// 1-bit data input (negative edge)
		.R				( 1'b0				),// 1-bit reset
		.S				( 1'b0				) // 1-bit set
	);

	OBUFTDS #(
		.IOSTANDARD		( "DEFAULT"			) // Specify the output I/O standard
	) CLK_OBUFTDS_inst (
		.O				( EXT_CLK_P			),// Diff_p output (connect directly to top-level port)
		.OB				( EXT_CLK_N			),// Diff_n output (connect directly to top-level port)
		.T				( 1'b0				),
		.I				( s_outclk			) // Buffer input
	);

	///////////////////////////////////////////////
	// Serial Interface
	///////////////////////////////////////////////
	IO_TX_SIF # (
		.P_5MS			( P_5MS				),
		.C_DATA_WIDTH	( C_DATA_WIDTH		)
	) u_io_tx_sif(
	// Clock & Reset
		.CLK			( mCLK		     	),
		.RST            ( RST            	),
	// Serial Interface
		.IO_RX          ( IO_RX          	),
		.IO_TX          ( IO_TX          	),
	// Train Signal
		.TRAIN_DAT      ( s_tarin_data		),
		.TRAIN_DONE     ( s_tarin_done		)
	);

	assign TRAIN_DONE = s_tarin_done;

endmodule