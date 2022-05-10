module XPM_TD_BRAM # (
	parameter						P_ADDR_WIDTH_A	= 	8	,	
	parameter						P_ADDR_WIDTH_B	= 	8	,	
	parameter						P_DATA_WIDTH_A	= 	32	,	
	parameter						P_DATA_WIDTH_B	= 	32		
) (
	input							clka					,
	input	[  0:0]					wea						,
	input	[P_ADDR_WIDTH_A-1:0]	addra					,
	input	[P_DATA_WIDTH_A-1:0]	dina					,
	output	[P_DATA_WIDTH_A-1:0]	douta					,
	input							clkb					,
	input	[  0:0]					web						,
	input	[P_ADDR_WIDTH_B-1:0]	addrb					,
	input	[P_DATA_WIDTH_B-1:0]	dinb					,
	output	[P_DATA_WIDTH_B-1:0]	doutb					
);

xpm_memory_tdpram # (
	.ADDR_WIDTH_A					( P_ADDR_WIDTH_A		),
	.ADDR_WIDTH_B					( P_ADDR_WIDTH_B		),
	.AUTO_SLEEP_TIME				( 0						),
	.BYTE_WRITE_WIDTH_A				( P_DATA_WIDTH_A		),
	.BYTE_WRITE_WIDTH_B				( P_DATA_WIDTH_B		),
	.CLOCKING_MODE					( "independent_clock"	),//
	.ECC_MODE						( "no_ecc"				),
	.MEMORY_INIT_FILE				( "none"				),
	.MEMORY_INIT_PARAM				( "0"					),
	.MEMORY_OPTIMIZATION			( "true"				),
	.MEMORY_PRIMITIVE				( "auto"				),
	.MEMORY_SIZE					( (2<<(P_ADDR_WIDTH_A-1))*P_DATA_WIDTH_A),
	.MESSAGE_CONTROL				( 0						),
	.READ_DATA_WIDTH_A				( P_DATA_WIDTH_A		),
	.READ_DATA_WIDTH_B				( P_DATA_WIDTH_B		),
	.READ_LATENCY_A					( 1						),
	.READ_LATENCY_B					( 1						),
	.READ_RESET_VALUE_A				( "0"					),
	.READ_RESET_VALUE_B				( "0"					),
//	.RST_MODE_A						( "SYNC"				),
//	.RST_MODE_B						( "SYNC"				),
	.USE_EMBEDDED_CONSTRAINT		( 0						),
	.USE_MEM_INIT					( 0						),
	.WAKEUP_TIME					( "disable_sleep"		),
	.WRITE_DATA_WIDTH_A				( P_DATA_WIDTH_A		),
	.WRITE_DATA_WIDTH_B				( P_DATA_WIDTH_B		),
	.WRITE_MODE_A					( "no_change"			),
	.WRITE_MODE_B					( "no_change"			) 
) xpm_memory_tdpram_inst (
	.dbiterra						(						), //o 1-bit output: Status signal to indicate double bit error occurrence
	.dbiterrb						(						), //o 1-bit output: Status signal to indicate double bit error occurrence
	.douta							( douta					), //o READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
	.doutb							( doutb					), //o READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
	.sbiterra						( 						), //o 1-bit output: Status signal to indicate single bit error occurrence
	.sbiterrb						( 						), //o 1-bit output: Status signal to indicate single bit error occurrence
	.addra							( addra					), // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
	.addrb							( addrb					), // ADDR_WIDTH_B-bit input: Address for port B write and read operations.
	.clka							( clka					), // 1-bit input: Clock signal for port A. Also clocks port B when
	.clkb							( clkb					), // 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
	.dina							( dina					), // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
	.dinb							( dinb					), // WRITE_DATA_WIDTH_B-bit input: Data input for port B write operations.
	.ena							( 1'b1					), // 1-bit input: Memory enable signal for port A. Must be high on clock
	.enb							( 1'b1					), // 1-bit input: Memory enable signal for port B. Must be high on clock
	.injectdbiterra					( 1'b0					), // 1-bit input: Controls double bit error injection on input data when
	.injectdbiterrb					( 1'b0					), // 1-bit input: Controls double bit error injection on input data when
	.injectsbiterra					( 1'b0					), // 1-bit input: Controls single bit error injection on input data when
	.injectsbiterrb					( 1'b0					), // 1-bit input: Controls single bit error injection on input data when
	.regcea							( 1'b1					), // 1-bit input: Clock Enable for the last register stage on the output
	.regceb							( 1'b1					), // 1-bit input: Clock Enable for the last register stage on the output
	.rsta							( 1'b0					), // 1-bit input: Reset signal for the final port A output register stage.
	.rstb							( 1'b0					), // 1-bit input: Reset signal for the final port B output register stage.
	.sleep							( 1'b0					), // 1-bit input: sleep signal to enable the dynamic power saving feature.
	.wea							( wea					), // WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input
	.web							( web					)  // WRITE_DATA_WIDTH_B-bit input: Write enable vector for port B input
);

endmodule