module CLK_IN (
	input								FPGA_DDR3_200M_CLKP					,//From PLL0
	input								FPGA_DDR3_200M_CLKN					,//From PLL0
	input								FPGA_DDR3_83M3_CLK0P				,//From PLL0
	input								FPGA_DDR3_83M3_CLK0N				,//From PLL0
	input								FPGA_DDR3_83M3_CLK1P				,//From PLL0
	input								FPGA_DDR3_83M3_CLK1N				,//From PLL0
	input								ADC_GTH_CLKP						,
	input								ADC_GTH_CLKN						,
	input								DAC_IO_CLKP							,
	input								DAC_IO_CLKN							,
	output								DAC_IO_CLK							,
	output								ADC_REF_CLK							,
	output								DDR3_200M_CLK						,// 
	output								DDR3_83M3_CLK0						,// 
	output								DDR3_83M3_CLK1						 // 
);

	IBUFDS # ( 																	
		.DQS_BIAS						( "FALSE"							)	
	) IBUFDS_inst0 (															
		.O								( DDR3_200M_CLK						),	
		.I								( FPGA_DDR3_200M_CLKP				),	
		.IB								( FPGA_DDR3_200M_CLKN				) 	
	);
	
	IBUFDS # ( 																	
		.DQS_BIAS						( "FALSE"							) 	
	) IBUFDS_inst1 (																
		.O								( DDR3_83M3_CLK0					),	
		.I								( FPGA_DDR3_83M3_CLK0P				),	
		.IB								( FPGA_DDR3_83M3_CLK0N				) 	
	);
	
	IBUFDS # ( 																	
		.DQS_BIAS						( "FALSE"							) 	
	) IBUFDS_inst2 (																
		.O								( DDR3_83M3_CLK1					),	
		.I								( FPGA_DDR3_83M3_CLK1P				),	
		.IB								( FPGA_DDR3_83M3_CLK1N				) 	
	);
	
	IBUFDS # ( 																	
		.DQS_BIAS						( "FALSE"							) 	
	) IBUFDS_inst3 (																
		.O								( DAC_IO_CLK						),	
		.I								( DAC_IO_CLKP						),	
		.IB								( DAC_IO_CLKN						) 	
	);
	
	IBUFDS_GTE2 # (
		.CLKCM_CFG						( "TRUE"							),//Must Setting
		.CLKRCV_TRST					( "TRUE"							),//Must Setting
		.CLKSWING_CFG					( 2'b11								) //Must Setting
	) IBUFDS_GTE2_inst (
		.O								( ADC_REF_CLK						),
		.ODIV2							( 									),
		.CEB							( 1'b0								),//clock enable
		.I								( ADC_GTH_CLKP						),
		.IB								( ADC_GTH_CLKN						) 
	);

endmodule
