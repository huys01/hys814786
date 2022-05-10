module XPM_ASYNC_FIFO # (
	parameter					P_ADDR_WIDTH		= 9		,	
	parameter					P_DATA_WIDTH		= 512	,	
	parameter					P_PROG_EMPT_THRESH	= 10	,
	parameter					P_PROG_FULL_THRESH	= 20	
)(
	input						rst					,
	input						wr_clk				,
	input						rd_clk				,
	input	[P_DATA_WIDTH-1:0]	din					,
	input						wr_en				,
	input						rd_en				,
	output	[P_DATA_WIDTH-1:0]	dout				,
	output						full				,
	output						empty				,
	output						prog_full			
);

xpm_fifo_async #(
	.CDC_SYNC_STAGES		( 2					),
	.DOUT_RESET_VALUE		( "0"				),
	.ECC_MODE				( "no_ecc"			),
	.FIFO_MEMORY_TYPE		( "auto"			),
	.FIFO_READ_LATENCY		( 1					),
	.FIFO_WRITE_DEPTH		( 2<<(P_ADDR_WIDTH-1)	),
	.FULL_RESET_VALUE		( 0					),
	.PROG_EMPTY_THRESH		( P_PROG_EMPT_THRESH),
	.PROG_FULL_THRESH		( P_PROG_FULL_THRESH),
	.RD_DATA_COUNT_WIDTH	( P_ADDR_WIDTH+1	),
	.READ_DATA_WIDTH		( P_DATA_WIDTH		),
	.READ_MODE				( "std"				),
	.RELATED_CLOCKS			( 0					),
	.USE_ADV_FEATURES		( "0707"			),
	.WAKEUP_TIME			( 0					),
	.WRITE_DATA_WIDTH		( P_DATA_WIDTH		),
	.WR_DATA_COUNT_WIDTH	( P_ADDR_WIDTH+1	)  
) xpm_fifo_async_inst (                                                                                       
	.almost_empty			( 					),   // 1-bit output: Almost Empty : When asserted, this signal indicates that 
	.almost_full			( 					),     // 1-bit output: Almost Full: When asserted, this signal indicates that   
	.data_valid				( 					),       // 1-bit output: Read Data Valid: When asserted, this signal indicates    
	.dbiterr				( 					),             // 1-bit output: Double Bit Error: Indicates that the ECC decoder detected
	.dout					( dout				),                   // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven   
	.empty					( empty				),                 // 1-bit output: Empty Flag: When asserted, this signal indicates that the
	.full					( full				),                   // 1-bit output: Full Flag: When asserted, this signal indicates that the 
	.overflow				( 					),           // 1-bit output: Overflow: This signal indicates that a write request     
	.prog_empty				( 					),       // 1-bit output: Programmable Empty: This signal is asserted when the     
	.prog_full				( prog_full			),         // 1-bit output: Programmable Full: This signal is asserted when the      
	.rd_data_count			( 					), // RD_DATA_COUNT_WIDTH-bit output: Read Data Count: This bus indicates the
	.rd_rst_busy			( 					),     // 1-bit output: Read Reset Busy: Active-High indicator that the FIFO read
	.sbiterr				( 					),             // 1-bit output: Single Bit Error: Indicates that the ECC decoder detected
	.underflow				( 					),         // 1-bit output: Underflow: Indicates that the read request (rd_en) during
	.wr_ack					( 					),               // 1-bit output: Write Acknowledge: This signal indicates that a write    
	.wr_data_count			( 					), // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus indicates   
	.wr_rst_busy			( 					),     // 1-bit output: Write Reset Busy: Active-High indicator that the FIFO    
	.din					( din				),                     // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when   
	.injectdbiterr			( 1'b0				), // 1-bit input: Double Bit Error Injection: Injects a double bit error if 
	.injectsbiterr			( 1'b0				), // 1-bit input: Single Bit Error Injection: Injects a single bit error if 
	.rd_clk					( rd_clk			),               // 1-bit input: Read clock: Used for read operation. rd_clk must be a free
	.rd_en					( rd_en				),                 // 1-bit input: Read Enable: If the FIFO is not empty, asserting this     
	.rst					( rst				),                     // 1-bit input: Reset: Must be synchronous to wr_clk. The clock(s) can be 
	.sleep					( 1'b0				),                 // 1-bit input: Dynamic power saving: If sleep is High, the memory/fifo   
	.wr_clk					( wr_clk			),               // 1-bit input: Write clock: Used for write operation. wr_clk must be a   
	.wr_en					( wr_en				)                  // 1-bit input: Write Enable: If the FIFO is not full, asserting this     
);
endmodule