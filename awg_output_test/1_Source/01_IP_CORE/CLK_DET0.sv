module CLK_DET0 (
	input				CLK_50M						,
	input				CLK_DET						,
	output	[31:0]		CLK_PERIOD					
);
	
	reg		[31:0]		r_timer0_1s			=32'h0	;
	reg					r_timer0_1s_tg 		= 1'b0	;
	wire				w_timer0_1s_pl				;
	reg		[ 3:0]		r_timer0_1s_tg_shf	= 4'b0	;
	wire				w_timer0_1s_tg_pl			;
	reg					r_flag = 1'b0				;
	reg		[31:0]		r_timer0_1s_period_o		;
	reg		[ 3:0]		r_timer1_1s_tg_shf	= 4'b0	;
	wire				w_timer1_1s_tg_pl			;
	reg					r_timer1_1s_tg				;
	reg		[31:0]		r_timer1_1s_cnt		= 32'b0	;
	reg		[31:0]		r_timer1_1s_period			;
	
	always @ ( posedge CLK_50M ) begin
		if ( w_timer0_1s_pl ) begin
			r_timer0_1s <= 32'h0;
		end else begin
			r_timer0_1s <= r_timer0_1s + 1'b1;
		end
	end
	
	always @ ( posedge CLK_50M ) begin
		if ( w_timer0_1s_pl ) begin
			r_timer0_1s_tg <= ~r_timer0_1s_tg;
		end
	end
	
	assign	w_timer0_1s_pl = ( r_timer0_1s == 32'd25000000-1 ) ? 1'b1:1'b0;
	
	always @ ( posedge CLK_50M ) begin
		r_timer0_1s_tg_shf <= {r_timer0_1s_tg_shf[2:0],r_timer1_1s_tg};
	end
	
	assign	w_timer0_1s_tg_pl = r_timer0_1s_tg_shf[3] ^ r_timer0_1s_tg_shf[2];
	
	always @ ( posedge CLK_50M ) begin
		if ( w_timer0_1s_pl ) begin
			r_flag <= 1'b1;
		end else if ( w_timer0_1s_tg_pl ) begin
			r_flag <= 1'b0;
		end
	end
	
	always @ ( posedge CLK_50M ) begin
		if ( w_timer0_1s_pl ) begin
			if ( r_flag ) begin
				r_timer0_1s_period_o <= 32'h0;
			end else begin
				r_timer0_1s_period_o <= r_timer1_1s_period;
			end
		end
	end
	
	always @ ( posedge CLK_DET ) begin
		r_timer1_1s_tg_shf <= {r_timer1_1s_tg_shf[2:0],r_timer0_1s_tg};
	end
	
	assign	w_timer1_1s_tg_pl = r_timer1_1s_tg_shf[3] ^ r_timer1_1s_tg_shf[2];
	
	always @ ( posedge CLK_DET ) begin
		if ( w_timer1_1s_tg_pl ) begin
			r_timer1_1s_tg <= ~r_timer1_1s_tg;
		end
	end
	
	always @ ( posedge CLK_DET ) begin
		if ( w_timer1_1s_tg_pl ) begin
			r_timer1_1s_cnt <= 32'h0;
		end else begin
			r_timer1_1s_cnt <= r_timer1_1s_cnt + 1'b1;
		end
	end
	
	always @ ( posedge CLK_DET ) begin
		if ( w_timer1_1s_tg_pl ) begin
			r_timer1_1s_period <= r_timer1_1s_cnt + 1'b1 ;
		end
	end
	
	assign	CLK_PERIOD = r_timer0_1s_period_o;
	
endmodule