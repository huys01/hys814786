module LVDS_TEST (
	input								CLK_REG								,//i 
	input								CLK_250M							,//i 
	input								RST									,//i 
	output		[31:0]					DB_LVDS_CNT							,//o [31:0]
	output		[31:0]					DB_LVDS_CNT0						,//o [31:0]
	output		[31:0]					DB_LVDS_CNT1						,//o [31:0]
	output		[31:0]					DB_LVDS_CNT2						,//o [31:0]
	output		[31:0]					DB_LVDS_CNT3						,//o [31:0]
	output		[31:0]					DB_LVDS_CNT4						,//o [31:0]
	input								LVDS_I_CLKP							,//i 
	input								LVDS_I_CLKN							,//i 
	input		[ 4:0]					LVDS_I_P							,//i [ 4:0]	
	input		[ 4:0]					LVDS_I_N							,//i [ 4:0]	
	output								LVDS_O_CLKP							,//o 
	output								LVDS_O_CLKN							,//o 
	output		[ 4:0]					LVDS_O_P							,//o [ 4:0]	
	output		[ 4:0]					LVDS_O_N							 //o [ 4:0]	
);

	reg		[ 4:0]						r_lvds_o							;
	wire								w_LVDS_CLK							;
	wire								w_LVDS_CLK_I						;
	wire	[ 4:0]						w_LVDS_I							;
	reg		[ 4:0]						r_LVDS_I							;

	ODDRE1 # (
		.IS_C_INVERTED					( 1'b0								), // Optional inversion for C
		.IS_D1_INVERTED					( 1'b0								), // Unsupported, do not use
		.IS_D2_INVERTED					( 1'b0								), // Unsupported, do not use
		.SIM_DEVICE						( "ULTRASCALE"						), // Set the device version for simulation functionality (ULTRASCALE)
		.SRVAL							( 1'b0								)  // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
	) ODDRE1_inst (
		.Q								( w_LVDS_CLK						), // 1-bit output: Data output to IOB
		.C								( CLK_250M							), // 1-bit input: High-speed clock input
		.D1								( 1'b1								), // 1-bit input: Parallel data input 1
		.D2								( 1'b0								), // 1-bit input: Parallel data input 2
		.SR								( 1'b0								)  // 1-bit input: Active-High Async Reset
	);
	
	OBUFDS OBUFDS_LVDS_O_CLK (
		.O								( LVDS_O_CLKP						),
		.OB								( LVDS_O_CLKN						),
		.I								( w_LVDS_CLK						) 
	);
	
genvar i;
generate
for(i=0;i<5;i=i+1)begin:inst1
	OBUFDS OBUFDS_LVDS_O_P0 (
		.O								( LVDS_O_P[i]						),
		.OB								( LVDS_O_N[i]						),
		.I								( r_lvds_o[i]						) 
	);
end
endgenerate

	always @ ( posedge CLK_250M ) begin
		if ( RST ) begin
			r_lvds_o <= 5'b0;
		end else begin
			r_lvds_o <= r_lvds_o + 1'b1;
		end
	end

	IBUFDS IBUFDS_LVDS_I_P0 (
		.O								( w_LVDS_CLK_I						),
		.I								( LVDS_I_CLKP						),
		.IB								( LVDS_I_CLKN						) 
	);
	
generate
for(i=0;i<5;i=i+1)begin:inst2
	IBUFDS IBUFDS_LVDS_I_P1 (
		.O								( w_LVDS_I[i]						),
		.I								( LVDS_I_P[i]						),
		.IB								( LVDS_I_N[i]						) 
	);
end
endgenerate
	
	wire	[31:0]						w_clk_period						;
	CLK_DET0 U_CLK_DET (
		.CLK_50M						( CLK_REG							),
		.CLK_DET						( w_LVDS_CLK_I						),
		.CLK_PERIOD						( w_clk_period						)	
	);
	
	assign	DB_LVDS_CNT				  = w_clk_period;
	
	always @ ( posedge w_LVDS_CLK_I ) begin
		r_LVDS_I <= w_LVDS_I;
	end 
	
	reg		[29:0]		r_timer_1s_cnt	=30'h0;
	reg					r_timer_1s		=1'b0;
	always @ ( posedge w_LVDS_CLK_I ) begin
		if ( r_timer_1s_cnt ==30'd249999999 ) begin
			r_timer_1s_cnt <= 30'd0;
			r_timer_1s <= 1'b1;
		end else begin
			r_timer_1s_cnt <= r_timer_1s_cnt + 1'b1;
			r_timer_1s <= 1'b0;
		end
	end 
	
	reg		[3:0]	r_gpio_i0_shf;
	reg		[3:0]	r_gpio_i1_shf;
	reg		[3:0]	r_gpio_i2_shf;
	reg		[3:0]	r_gpio_i3_shf;
	reg		[3:0]	r_gpio_i4_shf;
	wire	[4:0]	w_gpio_i_pl	;
	always @ ( posedge w_LVDS_CLK_I ) begin
		r_gpio_i0_shf <= {r_gpio_i0_shf[2:0],r_LVDS_I[0]};
		r_gpio_i1_shf <= {r_gpio_i1_shf[2:0],r_LVDS_I[1]};
		r_gpio_i2_shf <= {r_gpio_i2_shf[2:0],r_LVDS_I[2]};
		r_gpio_i3_shf <= {r_gpio_i3_shf[2:0],r_LVDS_I[3]};
		r_gpio_i4_shf <= {r_gpio_i4_shf[2:0],r_LVDS_I[4]};
	end
	
	assign	w_gpio_i_pl[0] = ~r_gpio_i0_shf[3] & r_gpio_i0_shf[2];
	assign	w_gpio_i_pl[1] = ~r_gpio_i1_shf[3] & r_gpio_i1_shf[2];
	assign	w_gpio_i_pl[2] = ~r_gpio_i2_shf[3] & r_gpio_i2_shf[2];
	assign	w_gpio_i_pl[3] = ~r_gpio_i3_shf[3] & r_gpio_i3_shf[2];
	assign	w_gpio_i_pl[4] = ~r_gpio_i4_shf[3] & r_gpio_i4_shf[2];
	
	reg		[31:0]		r_gpio_i_cnt		[0:4];
	reg		[31:0]		r_gpio_cnt_latch	[0:4];
	
generate
for(i=0;i<5;i=i+1)begin:inst
	always @ ( posedge w_LVDS_CLK_I ) begin
		if ( RST ) begin
			r_gpio_i_cnt[i] <= 32'h0;
		end else begin
			if ( r_timer_1s ) begin
				r_gpio_i_cnt[i] <= 32'h0;
			end else if ( w_gpio_i_pl[i] ) begin
				r_gpio_i_cnt[i] <= r_gpio_i_cnt[i] + 1'b1;
			end
		end
	end
	
	always @ ( posedge w_LVDS_CLK_I ) begin
		if ( RST ) begin
			r_gpio_cnt_latch[i] <= 32'h0;
		end else begin
			if ( r_timer_1s ) begin
				r_gpio_cnt_latch[i] <= r_gpio_i_cnt[i];
			end
		end
	end
	end
endgenerate
	
assign	DB_LVDS_CNT0 = r_gpio_cnt_latch[0];
assign	DB_LVDS_CNT1 = r_gpio_cnt_latch[1];
assign	DB_LVDS_CNT2 = r_gpio_cnt_latch[2];
assign	DB_LVDS_CNT3 = r_gpio_cnt_latch[3];
assign	DB_LVDS_CNT4 = r_gpio_cnt_latch[4];
	
`ifndef SIM
	ila_lvds_in u_ila_lvds_in(
		.clk		( w_LVDS_CLK_I	),
		.probe0		( r_LVDS_I		) //[4:0]
	);
`endif
	
endmodule