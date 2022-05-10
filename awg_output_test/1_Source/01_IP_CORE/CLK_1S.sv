module CLK_1S # (
	parameter				P_CLK_PERIOD	= 50000000
) (
	input					CLK				,
	output					TIMER_LED		
);

	reg		[ 31:0]			r_timer_1s		=32'h0;
	wire					w_timer_1s_pl	;
	reg						r_timer_1s_tg	=1'b0;
	reg						r_timer_1s_o	=1'b0;
	always @ ( posedge CLK ) begin
		if ( w_timer_1s_pl ) begin
			r_timer_1s <= 32'h0;
		end else begin
			r_timer_1s <= r_timer_1s + 1'b1;
		end
	end
	
	assign	w_timer_1s_pl = ( r_timer_1s == (P_CLK_PERIOD/2-1) ) ? 1'b1:1'b0;
	
	always @ ( posedge CLK ) begin
		if ( w_timer_1s_pl ) begin
			r_timer_1s_tg <=  ~r_timer_1s_tg ;
		end
	end
	
	always @ ( posedge CLK ) begin
		r_timer_1s_o <=  r_timer_1s_tg ;
	end
	
	assign	 TIMER_LED = r_timer_1s_o;
	
	endmodule