module CLK_DET1 (
	input				CLK_50M						,
	input				CLK_DET						,
	output	[31:0]		CLK_PERIOD					
);
	
	reg		[ 3:0]		r_clk_det_shf		= 4'b0	;
	wire				w_clk_det_pl				;
	reg		[31:0]		r_timer_1s			=32'h0	;
	wire				w_timer_1s_pl				;
	reg		[31:0]		r_timer_1s_cnt		= 32'b0	;
	reg		[31:0]		r_timer_1s_period			;
	reg		[31:0]		r_timer_1s_period_o			;
	
	always @ ( posedge CLK_50M ) begin
		r_clk_det_shf <= {r_clk_det_shf[2:0],CLK_DET};
	end
	
	assign	w_clk_det_pl = ~r_clk_det_shf[3] & r_clk_det_shf[2];
	
	always @ ( posedge CLK_50M ) begin
		if ( w_timer_1s_pl ) begin
			r_timer_1s <= 32'h0;
		end else begin
			r_timer_1s <= r_timer_1s + 1'b1;
		end
	end
	
	assign	w_timer_1s_pl = ( r_timer_1s == 32'd50000000-1 ) ? 1'b1:1'b0;
	
	always @ ( posedge CLK_50M ) begin
		if ( w_timer_1s_pl ) begin
			r_timer_1s_cnt <= 32'h0;
		end else if ( w_clk_det_pl ) begin
			r_timer_1s_cnt <= r_timer_1s_cnt + 1'b1;
		end
	end
	
	always @ ( posedge CLK_50M ) begin
		if ( w_timer_1s_pl ) begin
			if ( w_clk_det_pl ) begin
				r_timer_1s_period <= r_timer_1s_cnt + 1'b1 ;
			end else begin
				r_timer_1s_period <= r_timer_1s_cnt;
			end
		end
	end
	
	always @ ( posedge CLK_50M ) begin
		r_timer_1s_period_o <= r_timer_1s_period;
	end
	
	assign	CLK_PERIOD = r_timer_1s_period_o;
	
endmodule