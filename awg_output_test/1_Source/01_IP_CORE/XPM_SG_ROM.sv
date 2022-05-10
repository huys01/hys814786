module XPM_SG_ROM # (
	parameter		P_ADDR_WIDTH		= 8	,
	parameter		P_DATA_WIDTH		= 8	,
	parameter		P_MEM_INIT_FILE		= ""
)(
	input						clka		,
	input	[P_ADDR_WIDTH-1:0]	addra		,
	output	[P_DATA_WIDTH-1:0]	douta		
);

xpm_memory_sprom #(
	.ADDR_WIDTH_A		( P_ADDR_WIDTH		),
	.AUTO_SLEEP_TIME	( 0					),
	.ECC_MODE			( "no_ecc"			),
	.MEMORY_INIT_FILE	( P_MEM_INIT_FILE	),
	.MEMORY_INIT_PARAM	( ""				),
	.MEMORY_OPTIMIZATION( "true"			),
	.MEMORY_PRIMITIVE	( "distributed"		),
	.MEMORY_SIZE		( (2<<(P_ADDR_WIDTH-1))*P_DATA_WIDTH),
	.MESSAGE_CONTROL	( 0					),
	.READ_DATA_WIDTH_A	( P_DATA_WIDTH		),
	.READ_LATENCY_A		( 1					),
	.READ_RESET_VALUE_A	( "0"				),
	.USE_MEM_INIT		( 0					),
	.WAKEUP_TIME		( "disable_sleep"	)  // String
) xpm_memory_sprom_inst (
	.dbiterra			( 					), // 1-bit output: Leave open.
	.douta				( douta				), // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
	.sbiterra			( 					), // 1-bit output: Leave open.
	.addra				( addra				), // ADDR_WIDTH_A-bit input: Address for port A read operations.
	.clka				( clka				), // 1-bit input: Clock signal for port A.
	.ena				( 1'b1				), // 1-bit input: Memory enable signal for port A. Must be high on clock
	.injectdbiterra		( 1'b0				), // 1-bit input: Do not change from the provided value.
	.injectsbiterra		( 1'b0				), // 1-bit input: Do not change from the provided value.
	.regcea				( 1'b0				), // 1-bit input: Do not change from the provided value.
	.rsta				( 1'b0				), // 1-bit input: Reset signal for the final port A output register stage.
	.sleep				( 1'b0				)  // 1-bit input: sleep signal to enable the dynamic power saving feature.
);
   
endmodule