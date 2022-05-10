module GPIO_TEST (
	input								CLK									,//i 
	input								RST									,//i 
	input								TIMER_1S							,//i 
	output	[31:0]						GPIO0_1V8_I_CNT						,//o [31:0]
	output	[31:0]						GPIO1_1V8_I_CNT0					,//o [31:0]
	output	[31:0]						GPIO1_1V8_I_CNT1					,//o [31:0]
	output	[31:0]						GPIO1_1V8_I_CNT2					,//o [31:0]
	output	[31:0]						GPIO1_1V8_I_CNT3					,//o [31:0]
	input								GPIO0_1V8_I							,//i 		Bank45
	output								GPIO0_1V8_O							,//o 		Bank45
	input	[3:0]						GPIO1_1V8_I							,//i [ 3:0]Bank64
	output	[3:0]						GPIO1_1V8_O							 //o [ 3:0]Bank64
);

reg	[3:0]		r_cnt = 4'b0;
always @ ( posedge CLK ) begin
	if ( RST ) begin
		r_cnt <= 4'b0;
	end else begin
		r_cnt <= r_cnt + 1'b1;
	end
end

assign	GPIO0_1V8_O = r_cnt[0];
assign	GPIO1_1V8_O = r_cnt[3:0];

reg		[3:0]	r_gpio_i0_shf;
reg		[3:0]	r_gpio_i1_shf;
reg		[3:0]	r_gpio_i2_shf;
reg		[3:0]	r_gpio_i3_shf;
reg		[3:0]	r_gpio_i4_shf;
wire	[4:0]	w_gpio_i_pl	;
always @ ( posedge CLK ) begin
	r_gpio_i0_shf <= {r_gpio_i0_shf[2:0],GPIO0_1V8_I};
	r_gpio_i1_shf <= {r_gpio_i1_shf[2:0],GPIO1_1V8_I[0]};
	r_gpio_i2_shf <= {r_gpio_i2_shf[2:0],GPIO1_1V8_I[1]};
	r_gpio_i3_shf <= {r_gpio_i3_shf[2:0],GPIO1_1V8_I[2]};
	r_gpio_i4_shf <= {r_gpio_i4_shf[2:0],GPIO1_1V8_I[3]};
end

assign	w_gpio_i_pl[0] = ~r_gpio_i0_shf[3] & r_gpio_i0_shf[2];
assign	w_gpio_i_pl[1] = ~r_gpio_i1_shf[3] & r_gpio_i1_shf[2];
assign	w_gpio_i_pl[2] = ~r_gpio_i2_shf[3] & r_gpio_i2_shf[2];
assign	w_gpio_i_pl[3] = ~r_gpio_i3_shf[3] & r_gpio_i3_shf[2];
assign	w_gpio_i_pl[4] = ~r_gpio_i4_shf[3] & r_gpio_i4_shf[2];

reg		[31:0]		r_gpio_i_cnt		[0:4];
reg		[31:0]		r_gpio_cnt_latch	[0:4];

genvar i;
generate
for(i=0;i<5;i=i+1)begin:inst
always @ ( posedge CLK ) begin
	if ( RST ) begin
		r_gpio_i_cnt[i] <= 32'h0;
	end else begin
		if ( TIMER_1S ) begin
			r_gpio_i_cnt[i] <= 32'h0;
		end else if ( w_gpio_i_pl[i] ) begin
			r_gpio_i_cnt[i] <= r_gpio_i_cnt[i] + 1'b1;
		end
	end
end

always @ ( posedge CLK ) begin
	if ( RST ) begin
		r_gpio_cnt_latch[i] <= 32'h0;
	end else begin
		if ( TIMER_1S ) begin
			r_gpio_cnt_latch[i] <= r_gpio_i_cnt[i];
		end
	end
end
end
endgenerate

assign	GPIO0_1V8_I_CNT		= r_gpio_cnt_latch[0];
assign	GPIO1_1V8_I_CNT0	= r_gpio_cnt_latch[1];
assign	GPIO1_1V8_I_CNT1	= r_gpio_cnt_latch[2];
assign	GPIO1_1V8_I_CNT2	= r_gpio_cnt_latch[3];
assign	GPIO1_1V8_I_CNT3	= r_gpio_cnt_latch[4];

endmodule