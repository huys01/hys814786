	
module DDR_TEST (
	// Clock & Reset(Active Low)											
		input							CLK									,//i 						
		input							RST									,//i 						
	// Test Interface																		
		DDR_TEST_BUS.slave				DDR_TEST_IF							,//slave					
	// Memory Read&Write Request Bus Interface												
		MEMW_BUS.master					MEMW_BUS_IF							,//Master					
		MEMR_BUS.master					MEMR_BUS_IF							 //Master					
	);
	
	localparam							P_BRUST_LEN				= 8'h80;//512bit length
`ifdef SIM
	localparam							TIMER_250ms				= 28'h0000020;
`else
	localparam							TIMER_250ms				= 28'h0BEBC20;
`endif
	
	localparam							st_Test_Idle			= 6'b000001	;
	localparam							st_Test_Init0			= 6'b000010	;
	localparam							st_Test_Write			= 6'b000100	;
	localparam							st_Test_Write_End		= 6'b001000	;
	localparam							st_Test_Read			= 6'b010000	;
	localparam							st_Test_End				= 6'b100000	;
	
	localparam							st_Write_Idle			= 6'b000001	;
	localparam							st_Write_Req			= 6'b000010	;
	localparam							st_Write_Brust			= 6'b000100	;
	localparam							st_Write_Ack			= 6'b001000	;
	localparam							st_Write_End			= 6'b010000	;
	localparam							st_Write_Wait			= 6'b100000	;
	
	localparam							st_Read_Idle			= 6'b000001	;
	localparam							st_Read_Req				= 6'b000010	;
	localparam							st_Read_Brust			= 6'b000100	;
	localparam							st_Read_Ack				= 6'b001000	;
	localparam							st_Read_End				= 6'b010000	;
	localparam							st_Read_Wait			= 6'b100000	;
	
	reg									r_test_start					;
	reg									r_test_end						;
	reg		[  5:0]						r_test_fsm						;
	reg		[511:0]						r_data_ini						;
	reg		[  1:0]						r_test_mode						;
	reg		[  7:0]						r_burst_size					;
	wire								w_wr_flag						;
	reg		[  5:0]						r_wr_fsm						;
	reg		[511:0]						r_wr_data						;
	reg		[511:0]						r_wr_data_d0					;
	reg		[511:0]						r_wr_data_d1					;
	wire								w_rd_flag						;
	reg		[  5:0]						r_rd_fsm						;
	reg									r_mem_wr_req					;
	reg									r_mem_rd_req					;
	reg		[ 31:0]						r_mem_wr_adr					;
	reg		[ 31:0]						r_mem_rd_adr					;
	reg		[ 31:0]						r_wr_brust_times				;
	wire								w_wr_burst_end					;
	reg		[ 31:0]						r_wr_brust_cnt					;
	wire								w_wr_burst_cnt_end				;
	reg		[ 31:0]						r_rd_brust_times				;
	wire								w_rd_burst_end					;
	reg		[ 31:0]						r_rd_brust_cnt					;
	wire								w_rd_burst_cnt_end				;
	reg		[511:0]						r_rd_data						;
	reg									r_rd_compare					;
	reg									r_rd_compare0					;
	reg		[  1:0]						r_test_case						;
	reg		[ 27:0]						r_pwm_cnt						;
	wire								w_250ms_flag					;
	reg									r_pwm_wave						;
	reg									r_test_led						;
	reg		[  3:0]						r_dip_sw2_shf					;
	reg		[  1:0]						r_test_busy						;
	wire	[ 24:0]						P_BRUST_SIZE					;
	reg		[  1:0]						r_test_end_wait					;
	
	assign	P_BRUST_SIZE = DDR_TEST_IF.DDR_TEST_SIZE[31:11];
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_dip_sw2_shf <= 4'b0;
		end else begin
			r_dip_sw2_shf <= {r_dip_sw2_shf[2:0],DDR_TEST_IF.DDR_TEST};
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_test_start<= 1'b0;
			r_test_end	<= 1'b0;
		end else begin
			r_test_start<=  (r_dip_sw2_shf[3]);
			r_test_end	<= ~(r_dip_sw2_shf[3]);
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_test_fsm <= st_Test_Idle;
		end else begin
			case ( r_test_fsm ) 
				st_Test_Idle : 
					if ( r_test_start ) begin
						r_test_fsm <= st_Test_Init0;
					end 
					
				st_Test_Init0:
						r_test_fsm <= st_Test_Write;
						
				st_Test_Write :
					if ( w_wr_burst_cnt_end & w_wr_burst_end ) begin
						r_test_fsm <= st_Test_Write_End;
					end
					
				st_Test_Write_End :
					r_test_fsm <= st_Test_Read;
					
				st_Test_Read:
					if ( w_rd_burst_cnt_end && w_rd_burst_end ) begin
						r_test_fsm <= st_Test_End;
					end
					
				st_Test_End :
					if ( &r_test_end_wait ) begin
						if ( r_test_end ) begin
							r_test_fsm <= st_Test_Idle;
						end else begin
							r_test_fsm <= st_Test_Init0;
						end
					end
					
				default : r_test_fsm <= st_Test_Idle;
			endcase 
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_test_end_wait <= 2'b0;
		end else begin	
			if ( r_test_fsm == st_Test_End ) begin
				r_test_end_wait <= r_test_end_wait + 1'b1;
			end else begin
				r_test_end_wait <= 2'b0;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_test_busy[0] <= 1'b0;
		end else begin	
			if ( r_test_fsm == st_Test_Idle ) begin
				r_test_busy[0] <= 1'b0;
			end else begin
				r_test_busy[0] <= 1'b1;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_test_busy[1] <= 1'b0;
		end else begin	
			if ( r_test_fsm == st_Test_Write ) begin
				r_test_busy[1] <= 1'b1;
			end else if ( r_test_fsm == st_Test_Read ) begin
				r_test_busy[1] <= 1'b0;
			end
		end
	end
	
	reg		[1:0]		r_dip_sw;
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_dip_sw <= 2'b0;
		end else begin	
			if ( r_test_fsm == st_Test_End && (r_test_end_wait == 2'b00) ) begin
				r_dip_sw <= r_dip_sw + 1'b1;
			end
		end
	end
	
	// Test MODE chioce
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_data_ini <= 'b0;
		end else begin	
			case ( r_dip_sw[1:0] ) 
				2'b00 : 
					r_data_ini <= { 64'h00020001_00020001,64'h00020001_00020001,
									64'h00020001_00020001,64'h00020001_00020001,
									64'h00020001_00020001,64'h00020001_00020001,
									64'h00020001_00020001,64'h00020001_00020001};
				2'b01 : 
					r_data_ini <= { 64'hFFFF0000_FFFF0000,64'hFFFF0000_FFFF0000,
									64'hFFFF0000_FFFF0000,64'hFFFF0000_FFFF0000,
									64'hFFFF0000_FFFF0000,64'hFFFF0000_FFFF0000,
									64'hFFFF0000_FFFF0000,64'hFFFF0000_FFFF0000};
				2'b10 : 
					r_data_ini <= { 64'hA5A5A5A5_A5A5A5A5,64'hA5A5A5A5_A5A5A5A5,
									64'hA5A5A5A5_A5A5A5A5,64'hA5A5A5A5_A5A5A5A5,
									64'hA5A5A5A5_A5A5A5A5,64'hA5A5A5A5_A5A5A5A5,
									64'hA5A5A5A5_A5A5A5A5,64'hA5A5A5A5_A5A5A5A5};
				2'b11 :  
					r_data_ini <= { 64'h0000000F_0000000E,64'h0000000D_0000000C,
									64'h0000000B_0000000A,64'h00000009_00000008,
									64'h00000007_00000006,64'h00000005_00000004,
									64'h00000003_00000002,64'h00000001_00000000};
				default : ;
			endcase
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_test_mode <= 2'b0;
		end else begin
			if ( r_test_fsm == st_Test_Init0 ) begin
				r_test_mode <= r_dip_sw[1:0];
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_burst_size <= 'b0;
		end else begin
			r_burst_size <= P_BRUST_LEN;
		end
	end
	
	assign	w_wr_flag = ( r_test_fsm == st_Test_Write ) ? 1'b1:1'b0;

	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_wr_fsm <= st_Write_Idle;
		end else begin
			case ( r_wr_fsm )
				st_Write_Idle :
					if ( w_wr_flag ) begin
						r_wr_fsm <= st_Write_Req;
					end
				st_Write_Req :
						r_wr_fsm <= st_Write_Brust;
				st_Write_Brust:
					if ( MEMW_BUS_IF.MEMW_ACK ) begin
						r_wr_fsm <= st_Write_Ack;
					end
				st_Write_Ack:
						r_wr_fsm <= st_Write_End;
				st_Write_End :
					if ( w_wr_burst_end ) begin
						r_wr_fsm <= st_Write_Wait;
					end else begin
						r_wr_fsm <= st_Write_Req;
					end
				st_Write_Wait : 
					if ( w_wr_burst_cnt_end ) begin
						r_wr_fsm <= st_Write_Idle ;
					end
					
				default :r_wr_fsm <= st_Write_Idle ;
			endcase
		end
	end
	
	integer i;
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_wr_data	<= 'h0;
			r_wr_data_d0<= 'h0;
			r_wr_data_d1<= 'h0;
		end else begin
			if ( r_test_fsm == st_Test_Init0 ) begin
				r_wr_data <= r_data_ini;
			end else if ( MEMW_BUS_IF.MEMW_RDEN ) begin
				case ( r_test_mode ) 
					2'b00:begin
							r_wr_data[((00+1)<<4)-1:(00<<4)]<={r_wr_data[((00+1)<<4)-3:(00<<4)],r_wr_data[((00+1)<<4)-1:((00+1)<<4)-2]};
							r_wr_data[((01+1)<<4)-1:(01<<4)]<={r_wr_data[((01+1)<<4)-3:(01<<4)],r_wr_data[((01+1)<<4)-1:((01+1)<<4)-2]};
							r_wr_data[((02+1)<<4)-1:(02<<4)]<={r_wr_data[((02+1)<<4)-3:(02<<4)],r_wr_data[((02+1)<<4)-1:((02+1)<<4)-2]};
							r_wr_data[((03+1)<<4)-1:(03<<4)]<={r_wr_data[((03+1)<<4)-3:(03<<4)],r_wr_data[((03+1)<<4)-1:((03+1)<<4)-2]};
							r_wr_data[((04+1)<<4)-1:(04<<4)]<={r_wr_data[((04+1)<<4)-3:(04<<4)],r_wr_data[((04+1)<<4)-1:((04+1)<<4)-2]};
							r_wr_data[((05+1)<<4)-1:(05<<4)]<={r_wr_data[((05+1)<<4)-3:(05<<4)],r_wr_data[((05+1)<<4)-1:((05+1)<<4)-2]};
							r_wr_data[((06+1)<<4)-1:(06<<4)]<={r_wr_data[((06+1)<<4)-3:(06<<4)],r_wr_data[((06+1)<<4)-1:((06+1)<<4)-2]};
							r_wr_data[((07+1)<<4)-1:(07<<4)]<={r_wr_data[((07+1)<<4)-3:(07<<4)],r_wr_data[((07+1)<<4)-1:((07+1)<<4)-2]};
							r_wr_data[((08+1)<<4)-1:(08<<4)]<={r_wr_data[((08+1)<<4)-3:(08<<4)],r_wr_data[((08+1)<<4)-1:((08+1)<<4)-2]};
							r_wr_data[((09+1)<<4)-1:(09<<4)]<={r_wr_data[((09+1)<<4)-3:(09<<4)],r_wr_data[((09+1)<<4)-1:((09+1)<<4)-2]};
							r_wr_data[((10+1)<<4)-1:(10<<4)]<={r_wr_data[((10+1)<<4)-3:(10<<4)],r_wr_data[((10+1)<<4)-1:((10+1)<<4)-2]};
							r_wr_data[((11+1)<<4)-1:(11<<4)]<={r_wr_data[((11+1)<<4)-3:(11<<4)],r_wr_data[((11+1)<<4)-1:((11+1)<<4)-2]};
							r_wr_data[((12+1)<<4)-1:(12<<4)]<={r_wr_data[((12+1)<<4)-3:(12<<4)],r_wr_data[((12+1)<<4)-1:((12+1)<<4)-2]};
							r_wr_data[((13+1)<<4)-1:(13<<4)]<={r_wr_data[((13+1)<<4)-3:(13<<4)],r_wr_data[((13+1)<<4)-1:((13+1)<<4)-2]};
							r_wr_data[((14+1)<<4)-1:(14<<4)]<={r_wr_data[((14+1)<<4)-3:(14<<4)],r_wr_data[((14+1)<<4)-1:((14+1)<<4)-2]};
							r_wr_data[((15+1)<<4)-1:(15<<4)]<={r_wr_data[((15+1)<<4)-3:(15<<4)],r_wr_data[((15+1)<<4)-1:((15+1)<<4)-2]};
							r_wr_data[((16+1)<<4)-1:(16<<4)]<={r_wr_data[((16+1)<<4)-3:(16<<4)],r_wr_data[((16+1)<<4)-1:((16+1)<<4)-2]};
							r_wr_data[((17+1)<<4)-1:(17<<4)]<={r_wr_data[((17+1)<<4)-3:(17<<4)],r_wr_data[((17+1)<<4)-1:((17+1)<<4)-2]};
							r_wr_data[((18+1)<<4)-1:(18<<4)]<={r_wr_data[((18+1)<<4)-3:(18<<4)],r_wr_data[((18+1)<<4)-1:((18+1)<<4)-2]};
							r_wr_data[((19+1)<<4)-1:(19<<4)]<={r_wr_data[((19+1)<<4)-3:(19<<4)],r_wr_data[((19+1)<<4)-1:((19+1)<<4)-2]};
							r_wr_data[((20+1)<<4)-1:(20<<4)]<={r_wr_data[((20+1)<<4)-3:(20<<4)],r_wr_data[((20+1)<<4)-1:((20+1)<<4)-2]};
							r_wr_data[((21+1)<<4)-1:(21<<4)]<={r_wr_data[((21+1)<<4)-3:(21<<4)],r_wr_data[((21+1)<<4)-1:((21+1)<<4)-2]};
							r_wr_data[((22+1)<<4)-1:(22<<4)]<={r_wr_data[((22+1)<<4)-3:(22<<4)],r_wr_data[((22+1)<<4)-1:((22+1)<<4)-2]};
							r_wr_data[((23+1)<<4)-1:(23<<4)]<={r_wr_data[((23+1)<<4)-3:(23<<4)],r_wr_data[((23+1)<<4)-1:((23+1)<<4)-2]};
							r_wr_data[((24+1)<<4)-1:(24<<4)]<={r_wr_data[((24+1)<<4)-3:(24<<4)],r_wr_data[((24+1)<<4)-1:((24+1)<<4)-2]};
							r_wr_data[((25+1)<<4)-1:(25<<4)]<={r_wr_data[((25+1)<<4)-3:(25<<4)],r_wr_data[((25+1)<<4)-1:((25+1)<<4)-2]};
							r_wr_data[((26+1)<<4)-1:(26<<4)]<={r_wr_data[((26+1)<<4)-3:(26<<4)],r_wr_data[((26+1)<<4)-1:((26+1)<<4)-2]};
							r_wr_data[((27+1)<<4)-1:(27<<4)]<={r_wr_data[((27+1)<<4)-3:(27<<4)],r_wr_data[((27+1)<<4)-1:((27+1)<<4)-2]};
							r_wr_data[((28+1)<<4)-1:(28<<4)]<={r_wr_data[((28+1)<<4)-3:(28<<4)],r_wr_data[((28+1)<<4)-1:((28+1)<<4)-2]};
							r_wr_data[((29+1)<<4)-1:(29<<4)]<={r_wr_data[((29+1)<<4)-3:(29<<4)],r_wr_data[((29+1)<<4)-1:((29+1)<<4)-2]};
							r_wr_data[((30+1)<<4)-1:(30<<4)]<={r_wr_data[((30+1)<<4)-3:(30<<4)],r_wr_data[((30+1)<<4)-1:((30+1)<<4)-2]};
							r_wr_data[((31+1)<<4)-1:(31<<4)]<={r_wr_data[((31+1)<<4)-3:(31<<4)],r_wr_data[((31+1)<<4)-1:((31+1)<<4)-2]};
						end
						
					2'b11:begin
							r_wr_data[(00+1)*32-1:00*32] <= r_wr_data[(00+1)*32-1:00*32] + 16;
							r_wr_data[(01+1)*32-1:01*32] <= r_wr_data[(01+1)*32-1:01*32] + 16;
							r_wr_data[(02+1)*32-1:02*32] <= r_wr_data[(02+1)*32-1:02*32] + 16;
							r_wr_data[(03+1)*32-1:03*32] <= r_wr_data[(03+1)*32-1:03*32] + 16;
							r_wr_data[(04+1)*32-1:04*32] <= r_wr_data[(04+1)*32-1:04*32] + 16;
							r_wr_data[(05+1)*32-1:05*32] <= r_wr_data[(05+1)*32-1:05*32] + 16;
							r_wr_data[(06+1)*32-1:06*32] <= r_wr_data[(06+1)*32-1:06*32] + 16;
							r_wr_data[(07+1)*32-1:07*32] <= r_wr_data[(07+1)*32-1:07*32] + 16;
							r_wr_data[(08+1)*32-1:08*32] <= r_wr_data[(08+1)*32-1:08*32] + 16;
							r_wr_data[(09+1)*32-1:09*32] <= r_wr_data[(09+1)*32-1:09*32] + 16;
							r_wr_data[(10+1)*32-1:10*32] <= r_wr_data[(10+1)*32-1:10*32] + 16;
							r_wr_data[(11+1)*32-1:11*32] <= r_wr_data[(11+1)*32-1:11*32] + 16;
							r_wr_data[(12+1)*32-1:12*32] <= r_wr_data[(12+1)*32-1:12*32] + 16;
							r_wr_data[(13+1)*32-1:13*32] <= r_wr_data[(13+1)*32-1:13*32] + 16;
							r_wr_data[(14+1)*32-1:14*32] <= r_wr_data[(14+1)*32-1:14*32] + 16;
							r_wr_data[(15+1)*32-1:15*32] <= r_wr_data[(15+1)*32-1:15*32] + 16;
						end
					default : begin
						r_wr_data <= r_wr_data;
					end
				endcase
			end
			r_wr_data_d0 <= r_wr_data;
			r_wr_data_d1 <= r_wr_data_d0;
		end
	end
	
	assign	w_rd_flag = ( r_test_fsm == st_Test_Read ) ? 1'b1:1'b0;
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_rd_fsm <= st_Read_Idle ;
		end else begin
			case ( r_rd_fsm ) 
				st_Read_Idle : 
					if ( w_rd_flag ) begin
						r_rd_fsm <= st_Read_Req;
					end 
				st_Read_Req:
						r_rd_fsm <= st_Read_Brust;
				st_Read_Brust :
					if ( MEMR_BUS_IF.MEMR_ACK ) begin
						r_rd_fsm <= st_Read_Ack;
					end
				st_Read_Ack:
						r_rd_fsm <= st_Read_End;
				st_Read_End:
					if ( w_rd_burst_end ) begin
						r_rd_fsm <= st_Read_Wait;
					end else begin
						r_rd_fsm <= st_Read_Req;
					end
				st_Read_Wait :
					if ( w_rd_burst_cnt_end ) begin
						r_rd_fsm <= st_Read_Idle;
					end
				default :r_rd_fsm <= st_Read_Idle;
			endcase
		end
	end

	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_mem_wr_req <= 1'b0;
			r_mem_rd_req <= 1'b0;
		end else begin
			if ( MEMW_BUS_IF.MEMW_ACK ) begin
				r_mem_wr_req <= 1'b0;
			end else if ( r_wr_fsm == st_Write_Req ) begin
				r_mem_wr_req <= 1'b1;
			end
			if ( MEMR_BUS_IF.MEMR_ACK ) begin
				r_mem_rd_req <= 1'b0;
			end else if ( r_rd_fsm == st_Read_Req ) begin
				r_mem_rd_req <= 1'b1;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_mem_wr_adr <= 'h0;
		end else begin
			if ( r_test_fsm == st_Test_Init0 ) begin
				r_mem_wr_adr <= DDR_TEST_IF.DDR_TEST_ADDR[31:0];
			end else if ( MEMW_BUS_IF.MEMW_ACK ) begin
				r_mem_wr_adr <= r_mem_wr_adr + {r_burst_size,6'b0};
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_mem_rd_adr <= 'h0;
		end else begin
			if ( r_test_fsm == st_Test_Write_End ) begin
				r_mem_rd_adr <= DDR_TEST_IF.DDR_TEST_ADDR[31:0];
			end else if ( MEMR_BUS_IF.MEMR_ACK ) begin
				r_mem_rd_adr <= r_mem_rd_adr + {r_burst_size,6'b0};
			end
		end
	end
	
	assign	MEMW_BUS_IF.MEMW_REQ = r_mem_wr_req;
	assign	MEMW_BUS_IF.MEMW_LEN = r_burst_size;
	assign	MEMW_BUS_IF.MEMW_ADR = r_mem_wr_adr;
	assign	MEMW_BUS_IF.MEMW_RDAT= r_wr_data_d1;
	
	assign	MEMR_BUS_IF.MEMR_REQ = r_mem_rd_req;
	assign	MEMR_BUS_IF.MEMR_LEN = r_burst_size;
	assign	MEMR_BUS_IF.MEMR_ADR = r_mem_rd_adr;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_wr_brust_times <= 32'h0;
		end else begin
			if ( r_test_fsm == st_Test_Init0 ) begin
				r_wr_brust_times <= P_BRUST_SIZE;
			end else if ( r_wr_fsm == st_Write_Ack  ) begin
				r_wr_brust_times <= r_wr_brust_times - 1'b1;
			end
		end
	end
	
	assign	w_wr_burst_end = ( r_wr_brust_times == 32'h0 ) ? 1'b1:1'b0;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_wr_brust_cnt <= 32'h0;
		end else begin
			if ( r_wr_fsm == st_Write_Req && MEMW_BUS_IF.MEMW_REND ) begin
				r_wr_brust_cnt <= r_wr_brust_cnt;
			end else if ( r_wr_fsm == st_Write_Req ) begin
				r_wr_brust_cnt <= r_wr_brust_cnt + r_burst_size;
			end else if ( MEMW_BUS_IF.MEMW_REND ) begin
				r_wr_brust_cnt <= r_wr_brust_cnt - r_burst_size; 
			end
		end
	end
	
	assign	w_wr_burst_cnt_end = ~(|r_wr_brust_cnt);

	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_rd_brust_times <= 32'h0;
		end else begin
			if ( r_test_fsm == st_Test_Write_End ) begin
				r_rd_brust_times <= P_BRUST_SIZE;
			end else if ( r_rd_fsm == st_Read_Ack ) begin
				r_rd_brust_times <= r_rd_brust_times - 1'b1;
			end
		end
	end
	
	assign	w_rd_burst_end = ( r_rd_brust_times == 32'h0 ) ? 1'b1:1'b0;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_rd_brust_cnt <= 32'h0;
		end else begin
			if ( r_rd_fsm == st_Read_Req && MEMR_BUS_IF.MEMR_WEND ) begin
				r_rd_brust_cnt <= r_rd_brust_cnt;
			end else if ( r_rd_fsm == st_Read_Req ) begin
				r_rd_brust_cnt <= r_rd_brust_cnt + r_burst_size;
			end else if ( MEMR_BUS_IF.MEMR_WEND ) begin
				r_rd_brust_cnt <= r_rd_brust_cnt - r_burst_size; 
			end
		end
	end
	
	assign	w_rd_burst_cnt_end = ~(|r_rd_brust_cnt);
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_rd_data <= 'h0;
		end else begin
			if ( r_test_fsm == st_Test_Init0 ) begin
				r_rd_data <= r_data_ini;
			end else if ( MEMR_BUS_IF.MEMR_WREN ) begin
				case ( r_test_mode ) 
					2'b00:begin
							r_rd_data[((00+1)<<4)-1:(00<<4)]<={r_rd_data[((00+1)<<4)-3:(00<<4)],r_rd_data[((00+1)<<4)-1:((00+1)<<4)-2]};
							r_rd_data[((01+1)<<4)-1:(01<<4)]<={r_rd_data[((01+1)<<4)-3:(01<<4)],r_rd_data[((01+1)<<4)-1:((01+1)<<4)-2]};
							r_rd_data[((02+1)<<4)-1:(02<<4)]<={r_rd_data[((02+1)<<4)-3:(02<<4)],r_rd_data[((02+1)<<4)-1:((02+1)<<4)-2]};
							r_rd_data[((03+1)<<4)-1:(03<<4)]<={r_rd_data[((03+1)<<4)-3:(03<<4)],r_rd_data[((03+1)<<4)-1:((03+1)<<4)-2]};
							r_rd_data[((04+1)<<4)-1:(04<<4)]<={r_rd_data[((04+1)<<4)-3:(04<<4)],r_rd_data[((04+1)<<4)-1:((04+1)<<4)-2]};
							r_rd_data[((05+1)<<4)-1:(05<<4)]<={r_rd_data[((05+1)<<4)-3:(05<<4)],r_rd_data[((05+1)<<4)-1:((05+1)<<4)-2]};
							r_rd_data[((06+1)<<4)-1:(06<<4)]<={r_rd_data[((06+1)<<4)-3:(06<<4)],r_rd_data[((06+1)<<4)-1:((06+1)<<4)-2]};
							r_rd_data[((07+1)<<4)-1:(07<<4)]<={r_rd_data[((07+1)<<4)-3:(07<<4)],r_rd_data[((07+1)<<4)-1:((07+1)<<4)-2]};
							r_rd_data[((08+1)<<4)-1:(08<<4)]<={r_rd_data[((08+1)<<4)-3:(08<<4)],r_rd_data[((08+1)<<4)-1:((08+1)<<4)-2]};
							r_rd_data[((09+1)<<4)-1:(09<<4)]<={r_rd_data[((09+1)<<4)-3:(09<<4)],r_rd_data[((09+1)<<4)-1:((09+1)<<4)-2]};
							r_rd_data[((10+1)<<4)-1:(10<<4)]<={r_rd_data[((10+1)<<4)-3:(10<<4)],r_rd_data[((10+1)<<4)-1:((10+1)<<4)-2]};
							r_rd_data[((11+1)<<4)-1:(11<<4)]<={r_rd_data[((11+1)<<4)-3:(11<<4)],r_rd_data[((11+1)<<4)-1:((11+1)<<4)-2]};
							r_rd_data[((12+1)<<4)-1:(12<<4)]<={r_rd_data[((12+1)<<4)-3:(12<<4)],r_rd_data[((12+1)<<4)-1:((12+1)<<4)-2]};
							r_rd_data[((13+1)<<4)-1:(13<<4)]<={r_rd_data[((13+1)<<4)-3:(13<<4)],r_rd_data[((13+1)<<4)-1:((13+1)<<4)-2]};
							r_rd_data[((14+1)<<4)-1:(14<<4)]<={r_rd_data[((14+1)<<4)-3:(14<<4)],r_rd_data[((14+1)<<4)-1:((14+1)<<4)-2]};
							r_rd_data[((15+1)<<4)-1:(15<<4)]<={r_rd_data[((15+1)<<4)-3:(15<<4)],r_rd_data[((15+1)<<4)-1:((15+1)<<4)-2]};
							r_rd_data[((16+1)<<4)-1:(16<<4)]<={r_rd_data[((16+1)<<4)-3:(16<<4)],r_rd_data[((16+1)<<4)-1:((16+1)<<4)-2]};
							r_rd_data[((17+1)<<4)-1:(17<<4)]<={r_rd_data[((17+1)<<4)-3:(17<<4)],r_rd_data[((17+1)<<4)-1:((17+1)<<4)-2]};
							r_rd_data[((18+1)<<4)-1:(18<<4)]<={r_rd_data[((18+1)<<4)-3:(18<<4)],r_rd_data[((18+1)<<4)-1:((18+1)<<4)-2]};
							r_rd_data[((19+1)<<4)-1:(19<<4)]<={r_rd_data[((19+1)<<4)-3:(19<<4)],r_rd_data[((19+1)<<4)-1:((19+1)<<4)-2]};
							r_rd_data[((20+1)<<4)-1:(20<<4)]<={r_rd_data[((20+1)<<4)-3:(20<<4)],r_rd_data[((20+1)<<4)-1:((20+1)<<4)-2]};
							r_rd_data[((21+1)<<4)-1:(21<<4)]<={r_rd_data[((21+1)<<4)-3:(21<<4)],r_rd_data[((21+1)<<4)-1:((21+1)<<4)-2]};
							r_rd_data[((22+1)<<4)-1:(22<<4)]<={r_rd_data[((22+1)<<4)-3:(22<<4)],r_rd_data[((22+1)<<4)-1:((22+1)<<4)-2]};
							r_rd_data[((23+1)<<4)-1:(23<<4)]<={r_rd_data[((23+1)<<4)-3:(23<<4)],r_rd_data[((23+1)<<4)-1:((23+1)<<4)-2]};
							r_rd_data[((24+1)<<4)-1:(24<<4)]<={r_rd_data[((24+1)<<4)-3:(24<<4)],r_rd_data[((24+1)<<4)-1:((24+1)<<4)-2]};
							r_rd_data[((25+1)<<4)-1:(25<<4)]<={r_rd_data[((25+1)<<4)-3:(25<<4)],r_rd_data[((25+1)<<4)-1:((25+1)<<4)-2]};
							r_rd_data[((26+1)<<4)-1:(26<<4)]<={r_rd_data[((26+1)<<4)-3:(26<<4)],r_rd_data[((26+1)<<4)-1:((26+1)<<4)-2]};
							r_rd_data[((27+1)<<4)-1:(27<<4)]<={r_rd_data[((27+1)<<4)-3:(27<<4)],r_rd_data[((27+1)<<4)-1:((27+1)<<4)-2]};
							r_rd_data[((28+1)<<4)-1:(28<<4)]<={r_rd_data[((28+1)<<4)-3:(28<<4)],r_rd_data[((28+1)<<4)-1:((28+1)<<4)-2]};
							r_rd_data[((29+1)<<4)-1:(29<<4)]<={r_rd_data[((29+1)<<4)-3:(29<<4)],r_rd_data[((29+1)<<4)-1:((29+1)<<4)-2]};
							r_rd_data[((30+1)<<4)-1:(30<<4)]<={r_rd_data[((30+1)<<4)-3:(30<<4)],r_rd_data[((30+1)<<4)-1:((30+1)<<4)-2]};
							r_rd_data[((31+1)<<4)-1:(31<<4)]<={r_rd_data[((31+1)<<4)-3:(31<<4)],r_rd_data[((31+1)<<4)-1:((31+1)<<4)-2]};
					end
					2'b11:begin
							r_rd_data[(00+1)*32-1:00*32] <= r_rd_data[(00+1)*32-1:00*32] + 16;
							r_rd_data[(01+1)*32-1:01*32] <= r_rd_data[(01+1)*32-1:01*32] + 16;
							r_rd_data[(02+1)*32-1:02*32] <= r_rd_data[(02+1)*32-1:02*32] + 16;
							r_rd_data[(03+1)*32-1:03*32] <= r_rd_data[(03+1)*32-1:03*32] + 16;
							r_rd_data[(04+1)*32-1:04*32] <= r_rd_data[(04+1)*32-1:04*32] + 16;
							r_rd_data[(05+1)*32-1:05*32] <= r_rd_data[(05+1)*32-1:05*32] + 16;
							r_rd_data[(06+1)*32-1:06*32] <= r_rd_data[(06+1)*32-1:06*32] + 16;
							r_rd_data[(07+1)*32-1:07*32] <= r_rd_data[(07+1)*32-1:07*32] + 16;
							r_rd_data[(08+1)*32-1:08*32] <= r_rd_data[(08+1)*32-1:08*32] + 16;
							r_rd_data[(09+1)*32-1:09*32] <= r_rd_data[(09+1)*32-1:09*32] + 16;
							r_rd_data[(10+1)*32-1:10*32] <= r_rd_data[(10+1)*32-1:10*32] + 16;
							r_rd_data[(11+1)*32-1:11*32] <= r_rd_data[(11+1)*32-1:11*32] + 16;
							r_rd_data[(12+1)*32-1:12*32] <= r_rd_data[(12+1)*32-1:12*32] + 16;
							r_rd_data[(13+1)*32-1:13*32] <= r_rd_data[(13+1)*32-1:13*32] + 16;
							r_rd_data[(14+1)*32-1:14*32] <= r_rd_data[(14+1)*32-1:14*32] + 16;
							r_rd_data[(15+1)*32-1:15*32] <= r_rd_data[(15+1)*32-1:15*32] + 16;
					end
					default : begin
						r_rd_data <= r_rd_data;
					end
				endcase
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_rd_compare <= 1'b0;
			r_rd_compare0<= 1'b0;
			r_test_case  <= 2'b0;
		end else begin
			if ( r_test_fsm == st_Test_Idle ) begin
				r_rd_compare <= 1'b0;
				r_test_case  <= 2'b0;
			end else if ( MEMR_BUS_IF.MEMR_WREN ) begin
				if ( r_rd_data != MEMR_BUS_IF.MEMR_WDAT ) begin
					r_rd_compare0 <= 1'b1;
					r_rd_compare  <= 1'b1;
					r_test_case   <= r_test_mode;
				end else begin
					r_rd_compare0 <= 1'b0;
				end
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_pwm_cnt <= 28'b0;
		end else begin	
			if ( w_250ms_flag ) begin
				r_pwm_cnt <= 28'h0;
			end else begin
				r_pwm_cnt <= r_pwm_cnt + 1'b1;
			end
		end
	end
	
	assign w_250ms_flag = ( r_pwm_cnt == TIMER_250ms ) ? 1'b1:1'b0;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_pwm_wave <= 1'b0;
		end else begin
			if ( w_250ms_flag ) begin
				r_pwm_wave <= ~r_pwm_wave;
			end
		end
	end
	
	//During Testing :					=> LED <= pwm_wave
	//Compare result :Error happens 	=> LED <= '1'
	//Compare result :Error not happens => LED <= '0'
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_test_led <= 1'b1;
		end else begin	
			if ( r_test_start ) begin
				if ( r_rd_compare ) begin
					r_test_led <= 1'b0;
				end else begin
					r_test_led <= r_pwm_wave;
				end
			end else begin
				r_test_led <= 1'b1 ;
			end
		end
	end
	
	assign	DDR_TEST_IF.DDR_TEST_BUSY		= r_test_busy		;
	assign	DDR_TEST_IF.DDR_TEST_ERR		= r_rd_compare		;
	assign	DDR_TEST_IF.DDR_TEST_LED		= r_test_led		;
	assign	DDR_TEST_IF.DDR_TEST_CASE		= r_test_case		;
	
	reg		[31:0]	r_ddr_wr_time	;
	reg		[31:0]	r_ddr_wr_time_o	;
	reg		[31:0]	r_ddr_rd_time	;
	reg		[31:0]	r_ddr_rd_time_o	;
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_ddr_wr_time <= 32'b0;
		end else begin
			if ( r_wr_fsm == st_Write_Idle ) begin
				r_ddr_wr_time <= 32'b0;
			end else begin
				r_ddr_wr_time <= r_ddr_wr_time + 1'b1;
			end
		end
	end 
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_ddr_wr_time_o <= 32'h0;
		end else begin
			if ( r_wr_fsm == st_Write_Wait && w_wr_burst_cnt_end ) begin
				r_ddr_wr_time_o <= r_ddr_wr_time + 1'b1;
			end
		end
	end 
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_ddr_rd_time <= 32'b0;
		end else begin
			if ( r_rd_fsm == st_Read_Idle ) begin
				r_ddr_rd_time <= 32'b0;
			end else begin
				r_ddr_rd_time <= r_ddr_rd_time + 1'b1;
			end
		end
	end 
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_ddr_rd_time_o <= 32'h0;
		end else begin
			if ( r_rd_fsm == st_Read_Wait && w_rd_burst_cnt_end ) begin
				r_ddr_rd_time_o <= r_ddr_rd_time + 1'b1;
			end
		end
	end
	
	assign	DDR_TEST_IF.DDR_TEST_WTIME = r_ddr_wr_time_o;
	assign	DDR_TEST_IF.DDR_TEST_RTIME = r_ddr_rd_time_o; 
	
endmodule