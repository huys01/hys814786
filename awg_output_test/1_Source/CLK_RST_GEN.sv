// =============================================================================
// file name	: CLK_RST_GEN.v													
// module		: CLK_RST_GEN													
// =============================================================================
// function		: System Clock&Reset Generate Module							
// -----------------------------------------------------------------------------
// updata history:																
// -----------------------------------------------------------------------------
// rev.level	Date			Coded By			contents					
// v0.0.0		2016/11/03		IR.Shenh			create new					
// -----------------------------------------------------------------------------
// Update Details :																
// -----------------------------------------------------------------------------
// Date			Contents Detail													
// =============================================================================
// End revision																	
// =============================================================================
																				
// =============================================================================
// Timescale Define																
// =============================================================================
																				
`timescale 1ns / 1ps															
																				
module CLK_RST_GEN (															
// From Clock Input																
	input					CLK25M_IN						,//25Mhz			
	input					RESETN_IN						,//Active Low		
// SOFT Reset																	
	input					SOFT_RST						,//i 				
// To System Clock																
	output					SYSCLK							,//200Mhz 			
	output					CLK50M							,//50Mhz			
	output					CLK250M							,//250Mhz			
	output					CLK125M							,//125Mhz			
	output					CLK500M							,//500Mhz			
	output					REGRST							,//					
	output					SYSRST							 //					
);																				
																				
	wire					w_ibufg_clkin					;					
	wire					w_pll_rst						;					
	wire					w_pll_clkout0					;					
	wire					w_pll_clkout1					;					
	wire					w_pll_clkout2					;					
	wire					w_pll_clkout3					;					
	wire					w_pll_clkout4					;					
	wire					w_pll_clkfbout					;					
	wire					w_pll_locked					;					
	wire					w_pll_clkfbout_bufgout			;					
	wire					w_pll_clkout0_bufgout			;					
	wire					w_pll_clkout1_bufgout			;					
	wire					w_pll_clkout2_bufgout			;					
	wire					w_pll_clkout3_bufgout			;					
	wire					w_pll_clkout4_bufgout			;					
	wire					w_pll_locked_dly				;					
 																				

	IBUFG clkin_buf (
		.O 						( w_ibufg_clkin				),
		.I 						( CLK25M_IN					)
	);

	SRL16E # (											
		.INIT					( 16'hFFFF					)
	) SRL16E_inst_0 (									
		.Q 						( w_pll_rst					),
		.A0						( 1'b1						),
		.A1						( 1'b1						),
		.A2						( 1'b1						),
		.A3						( 1'b1						),
		.CE						( 1'b1						),
		.CLK					( w_ibufg_clkin				),
		.D						(~RESETN_IN					) 
	);
	
	//////////////////////////////////////////////////
	// Memroy Clock & DDR Clock Generator
	//////////////////////////////////////////////////
	PLLE2_BASE #(
		.BANDWIDTH              ("OPTIMIZED"                ),  // OPTIMIZED, HIGH, LOW
		.CLKFBOUT_MULT          (40                         ),  // Multiply value for all CLKOUT, (2-64)
		.CLKFBOUT_PHASE         (0.0                        ),  // Phase offset in degrees of CLKFB, (-360.000-360.000).
		.CLKIN1_PERIOD          (40                         ),   // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
		// CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
		.CLKOUT0_DIVIDE         (20                         ),
		.CLKOUT1_DIVIDE         (5                          ),
		.CLKOUT2_DIVIDE         (4                          ),
		.CLKOUT3_DIVIDE         (8                          ),
		.CLKOUT4_DIVIDE         (2                          ),
		.CLKOUT5_DIVIDE         (15                         ),
		// CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
		.CLKOUT0_DUTY_CYCLE     (0.5                        ),
		.CLKOUT1_DUTY_CYCLE     (0.5                        ),
		.CLKOUT2_DUTY_CYCLE     (0.5                        ),
		.CLKOUT3_DUTY_CYCLE     (0.5                        ),
		.CLKOUT4_DUTY_CYCLE     (0.5                        ),
		.CLKOUT5_DUTY_CYCLE     (0.5                        ),
		// CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
		.CLKOUT0_PHASE          (0.0                        ),
		.CLKOUT1_PHASE          (0.0                        ),
		.CLKOUT2_PHASE          (0.0                        ),
		.CLKOUT3_PHASE          (0.0                        ),
		.CLKOUT4_PHASE          (0.0                        ),
		.CLKOUT5_PHASE          (0.0                        ),
		.DIVCLK_DIVIDE          (1                          ),  // Master		 division value, (1-56)
		.REF_JITTER1            (0.0                        ),  // Reference input jitter in UI, (0.000-0.999).
		.STARTUP_WAIT           ("FALSE"                    )   // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
	)
	PLLE2_BASE_inst (
		// Clock Outputs: 1-bit (each) output: User configurable clock outputs
		.CLKOUT0                (w_pll_clkout0              ),  // 1-bit output: CLKOUT0
		.CLKOUT1                (w_pll_clkout1              ),  // 1-bit output: CLKOUT1
		.CLKOUT2                (w_pll_clkout2              ),  // 1-bit output: CLKOUT2
		.CLKOUT3                (w_pll_clkout3              ),  // 1-bit output: CLKOUT3
		.CLKOUT4                (w_pll_clkout4              ),  // 1-bit output: CLKOUT4
		.CLKOUT5                (                           ),  // 1-bit output: CLKOUT5
		// Feedback Clocks: 1-bit (each) output: Clock feedback ports
		.CLKFBOUT               (w_pll_clkfbout             ),  // 1-bit output: Feedback clock
		.LOCKED                 (w_pll_locked               ),  // 1-bit output: LOCK
		.CLKIN1                 (w_ibufg_clkin              ),  // 1-bit input: Input clock
		// Control Ports: 1-bit (each) input: PLL control ports
		.PWRDWN                 (1'b0                       ),  // 1-bit input: Power-down
		.RST                    (w_pll_rst                  ),  // 1-bit input: Reset
		// Feedback Clocks: 1-bit (each) input: Clock feedback ports
		.CLKFBIN                (w_pll_clkfbout_bufgout     )   // 1-bit input: Feedback clock
	);
	
	BUFG u_bufg_0 (
		.O 						(w_pll_clkfbout_bufgout		),
		.I 						(w_pll_clkfbout				)
	);
	
	BUFG u_bufg_1 (
		.O   					(w_pll_clkout0_bufgout		),
		.I   					(w_pll_clkout0				)
	);

	BUFG u_bufg_2 (
		.O   					(w_pll_clkout1_bufgout		),
		.I   					(w_pll_clkout1				)
	);
	
	BUFG u_bufg_3 (
		.O   					(w_pll_clkout2_bufgout		),
		.I   					(w_pll_clkout2				)
	);

	BUFG u_bufg_4 (
		.O   					(w_pll_clkout3_bufgout		),
		.I   					(w_pll_clkout3				)
	);

	BUFG u_bufg_5 (
		.O   					(w_pll_clkout4_bufgout		),
		.I   					(w_pll_clkout4				)
	);

	SRL16E #(
		.INIT					(16'hFFFF                   )
	) SRL16E_inst_1 (
		.Q  					(w_pll_locked_dly           ),
		.A0 					(1'b1                       ),
		.A1 					(1'b1                       ),
		.A2 					(1'b1                       ),
		.A3 					(1'b1                       ),
		.CE 					(1'b1                       ),
		.CLK					(w_pll_clkout1_bufgout      ),
		.D  					(~w_pll_locked              ) 
	);
	
	assign	CLK50M			= w_pll_clkout0_bufgout	;
	assign	SYSCLK			= w_pll_clkout1_bufgout	;
	assign	CLK250M			= w_pll_clkout2_bufgout	;
	assign	CLK125M			= w_pll_clkout3_bufgout	;
	assign	CLK500M			= w_pll_clkout4_bufgout	;
	
	assign	w_rst = w_pll_locked_dly | SOFT_RST;
	
	reg            r_gen_rst0    =1'b1;
	reg            r_gen_rst1    =1'b1;
	reg    [3:0]   r_gen_rst0_shf=4'hF;
	reg    [3:0]   r_gen_rst1_shf=4'hF;
	always @ ( posedge w_pll_clkout1_bufgout or posedge w_rst ) begin
		if ( w_rst ) begin
			r_gen_rst0 <= 1'b1;
		end else begin
			r_gen_rst0 <= 1'b0;
		end
	end
	
	always @ ( posedge w_pll_clkout1_bufgout or posedge w_rst ) begin
		if ( w_rst ) begin
			r_gen_rst0_shf <= 4'hF;
		end else begin
			r_gen_rst0_shf <= { r_gen_rst0_shf[2:0],r_gen_rst0};
		end
	end
	
	assign	SYSRST			= r_gen_rst0_shf[3];
	
	always @ ( posedge w_pll_clkout0_bufgout or posedge w_pll_locked_dly ) begin
		if ( w_pll_locked_dly ) begin
			r_gen_rst1 <= 1'b1;
		end else begin
			r_gen_rst1 <= 1'b0;
		end
	end
	
	always @ ( posedge w_pll_clkout0_bufgout or posedge w_pll_locked_dly ) begin
		if ( w_pll_locked_dly ) begin
			r_gen_rst1_shf <= 4'hF;
		end else begin
			r_gen_rst1_shf <= { r_gen_rst1_shf[2:0],r_gen_rst1};
		end
	end
	
	assign	REGRST			= r_gen_rst1_shf[3];
	
endmodule