module TEMP_DATA (
	input								CLK									,
	input								RST									,
	input								TEMP_DQ								,
	output	[31:0]						TEMP_DATA							 
);

	wire								w_TEMP_DQ							;
	reg		[ 3:0]						r_temp_dq_shf						;
	wire								w_temp_dq_pl						;
	reg		[ 5:0]						r_timer_1us_cnt						;
	reg		[15:0]						r_timer_1ms_cnt						;
	wire								w_timer_1us							;
	wire								w_timer_1ms							;
	wire								w_timer_10ms_flag					;
	reg		[15:0]						r_timer_10ms_cnt					;
	reg		[15:0]						r_temp_cnt							;
	reg		[15:0]						r_temp_dat							;

filter u_filter (
	.clk								( CLK								),
	.rst								( RST								),
	.din								( TEMP_DQ							),
	.dout								( w_TEMP_DQ							)
);
	
	always @ ( posedge CLK ) begin
		r_temp_dq_shf <= {r_temp_dq_shf[2:0],w_TEMP_DQ};
	end

	assign	w_temp_dq_pl = ~r_temp_dq_shf[3] & r_temp_dq_shf[2];
		
	always @ ( posedge CLK ) begin
		if ( w_timer_1us ) begin
			r_timer_1us_cnt <= 6'h0;
		end else begin
			r_timer_1us_cnt <= r_timer_1us_cnt + 1'b1;
		end
	end
	
	assign	w_timer_1us = ( r_timer_1us_cnt == 6'd49 ) ? 1'b1:1'b0;
	
	always @ ( posedge CLK ) begin
		if ( w_timer_1ms ) begin
			r_timer_1ms_cnt <= 10'h0;
		end else if ( w_timer_1us ) begin
			r_timer_1ms_cnt <= r_timer_1ms_cnt + 1'b1;
		end
	end
	
	assign	w_timer_1ms = ( r_timer_1ms_cnt == 10'd999 ) ? w_timer_1us : 1'b0;
	
	always @ ( posedge CLK ) begin
		if ( w_temp_dq_pl ) begin
			if ( w_timer_10ms_flag ) begin
				r_temp_cnt <= r_temp_cnt + 1'b1;
			end else begin
				r_temp_cnt <= 16'h0001;
			end
			r_timer_10ms_cnt <= 8'b0;
		end else if ( w_timer_1ms ) begin
			r_timer_10ms_cnt <= r_timer_10ms_cnt + 1'b1;
		end
	end
	
	assign	w_timer_10ms_flag = (r_timer_10ms_cnt < 8'h2) ? 1'b1:1'b0;
	
	always @ ( posedge CLK ) begin
		if ( w_temp_dq_pl ) begin
			if ( ~w_timer_10ms_flag ) begin
				r_temp_dat <= r_temp_cnt;
			end
		end
	end
	
	assign	TEMP_DATA = r_temp_dat;

endmodule