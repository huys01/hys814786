// =========================================================================
// file name	: MEM_RD_SYNC.v												
// module		: MEM_RD_SYNC												
// =========================================================================
// function		: Read Memory SYNC Module									
// -------------------------------------------------------------------------
// updata history:															
// -------------------------------------------------------------------------
// rev.level	Date			Coded By			contents				
// v0.0.0		2016/09/14		IR.Shenh			create new				
// -------------------------------------------------------------------------
// Update Details :															
// -------------------------------------------------------------------------
// Date			Contents Detail												
// =========================================================================
// End revision																
// =========================================================================

// =========================================================================
// Timescale Define															
// =========================================================================
`timescale 1 ns / 1 ps

module MEM_RD_ASYNC_256b # (													
	parameter				P_MEM_LB_LEN			= 128 //128x256bit		
) (																			
// Clock & Reset															
	input					CLK						,//i 					
	input					RST						,//i 					
// From Memory Interface													
	input					SYS_LB_REQ				,//i 					
	input	[ 31:0]			SYS_LB_ADR				,//i [ 31:0]			
	input	[ 19:0]			SYS_LB_LEN				,//i [ 19:0]			
	output					SYS_LB_ACK				,//o 					
	input					SYS_LB_WRDY				,//i 					
	output					SYS_LB_WREN				,//o  					
	output	[255:0]			SYS_LB_WDAT				,//o [255:0]			
// Engine Request Port0														
	input					MEM_CLK					,//i				
	output					MEM_LB_REQ				,//o 					
	output	[ 31:0]			MEM_LB_ADR				,//o [ 31:0]			
	output	[  7:0]			MEM_LB_LEN				,//o [  7:0]			
	input					MEM_LB_ACK				,//i 					
	input					MEM_LB_WREN				,//i 					
	input	[511:0]			MEM_LB_WDAT				,//i [511:0]			
	input					MEM_LB_WEND				 //i 					
);	
	
	//----------------------------------------------------------------------
	// State Machine Declaration											
	//----------------------------------------------------------------------
	localparam			st_MEM_Idle		= 6'b00_0001;//					
	localparam			st_MEM_CMD		= 6'b00_0010;//					
	localparam			st_MEM_REQ		= 6'b00_0100;//					
	localparam			st_MEM_ACK		= 6'b00_1000;//					
	localparam			st_MEM_CHK		= 6'b01_0000;//					
	localparam			st_MEM_END		= 6'b10_0000;//					
	
	//----------------------------------------------------------------------
	// Signal Declaration													
	//----------------------------------------------------------------------
	
	reg		[  5:0]			r_fsm_ctrl					;
	reg						r_mem_req					;
	reg		[ 19:0]			r_mem_req_len_decr_cnt		;
	reg		[  7:0]			r_mem_req_len				;
	wire					w_mem_req_end				;
	reg		[ 19:0]			r_mem_wr_len_decr_cnt		;
	wire					w_mem_dat_end				;
	wire	[ 31:0]			w_MEM_LB_ADR				;
	reg		[ 31:0]			r_mem_lb_adr				;
	wire					w_bram_wren					;
	wire	[511:0]			w_bram_wdat					;
	reg		[  8:0]			r_bram_wadr					;
	wire	[255:0]			w_bram_rdat					;
	reg		[255:0]			r_bram_rdat					;
	wire					w_bram_wrdy					;
	reg						r_fifo_wren					;
	reg		[  8:0]			r_fifo_wdat					;
	reg						r_fifo_rden					;
	wire	[  8:0]			w_fifo_rdat					;
	wire					w_fifo_empt					;
	reg						r_fifo_rden_flag			;
	reg						r_bram_rden_flag			;
	reg		[  8:0]			r_bram_rlen					;
	reg		[  8:0]			r_bram_rcnt					;
	wire					w_bram_rend					;
	wire					w_bram_rden					;
	reg		[  9:0]			r_bram_radr					;
	reg		[  3:0]			r_bram_rden_shf				;
	reg						r_bram_decr_tg		= 1'b0	;
	reg		[ 7:0]			r_bram_decr_len				;
	reg		[  2:0]			r_sys_lb_ack_tg_shf = 3'b0	;
	wire					w_sys_lb_ack				;
	reg		[  3:0]			r_bram_decr_tg_shf  = 4'b0	;
	wire					w_bram_decr					;
	
	//--------------------------------------------------------------------//
	// synopsys translate_off												
	reg	[8*25:1]	S_FSM_CTRL;												
	always @ ( * ) begin													
		case ( r_fsm_ctrl ) 												
			st_MEM_Idle	: S_FSM_CTRL = "st_MEM_Idle	";						
			st_MEM_CMD	: S_FSM_CTRL = "st_MEM_CMD	";						
			st_MEM_REQ	: S_FSM_CTRL = "st_MEM_REQ	";						
			st_MEM_ACK	: S_FSM_CTRL = "st_MEM_ACK	";						
			st_MEM_CHK	: S_FSM_CTRL = "st_MEM_CHK	";						
			st_MEM_END	: S_FSM_CTRL = "st_MEM_END	";						
		endcase																
	end																		
	// synopsys translate_on												
	//--------------------------------------------------------------------//
	
	reg					r_sys_lb_req		= 1'b0	;
	reg		[ 3:0]		r_sys_lb_req_shf	= 4'b0	;
	wire				w_sys_lb_req				;
	always @ ( posedge CLK ) begin
		if ( SYS_LB_REQ ) begin
			r_sys_lb_req <= ~r_sys_lb_req;
		end
	end
	
	always @ ( posedge MEM_CLK ) begin
		r_sys_lb_req_shf <= {r_sys_lb_req_shf[2:0],r_sys_lb_req};
	end
	
	assign	w_sys_lb_req = r_sys_lb_req_shf[3] ^ r_sys_lb_req_shf[2];
	
	//----------------------------------------------------------------------
	// FSM:Main State Machine												
	//----------------------------------------------------------------------
	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_fsm_ctrl <= st_MEM_Idle ;
		end else begin
			case ( r_fsm_ctrl ) 
				st_MEM_Idle :
					if ( w_sys_lb_req ) begin
						r_fsm_ctrl <= st_MEM_CMD;
					end
					
				st_MEM_CMD :
					if ( w_bram_wrdy ) begin
						r_fsm_ctrl <= st_MEM_REQ;
					end
					
				st_MEM_REQ :
					if ( MEM_LB_ACK ) begin
						r_fsm_ctrl <= st_MEM_ACK ;
					end
					
				st_MEM_ACK :
						r_fsm_ctrl <= st_MEM_CHK;
						
				st_MEM_CHK :
					if ( w_mem_req_end ) begin
						r_fsm_ctrl <= st_MEM_END;
					end else if ( w_bram_wrdy ) begin
						r_fsm_ctrl <= st_MEM_REQ;
					end
					
				st_MEM_END :
					if ( w_mem_dat_end ) begin 
						r_fsm_ctrl <= st_MEM_Idle;
					end
					
				default :
						r_fsm_ctrl <= st_MEM_Idle;
			endcase
		end
	end
	
	// Packet Request Generate
	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_mem_req <= 1'b0;
		end else begin
			if ( MEM_LB_ACK ) begin
				r_mem_req <= 1'b0;
			end else if ( r_fsm_ctrl == st_MEM_REQ ) begin
				r_mem_req <= 1'b1;
			end
		end
	end
	
	// Request length Counter
	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_mem_req_len_decr_cnt <= 20'b0;
		end else begin
			if ( r_fsm_ctrl == st_MEM_CMD ) begin
				r_mem_req_len_decr_cnt <= {1'b0,SYS_LB_LEN[19:1]};
			end else if ( r_fsm_ctrl == st_MEM_ACK ) begin
				r_mem_req_len_decr_cnt <= r_mem_req_len_decr_cnt - r_mem_req_len;
			end
		end
	end
	
	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_mem_req_len <= 8'b0;
		end else begin
			if ( r_fsm_ctrl == st_MEM_REQ ) begin
				if ( r_mem_req_len_decr_cnt > P_MEM_LB_LEN ) begin
					r_mem_req_len <= P_MEM_LB_LEN;
				end else begin
					r_mem_req_len <= r_mem_req_len_decr_cnt[7:0];
				end
			end
		end
	end
	
	assign	w_mem_req_end = ~(|r_mem_req_len_decr_cnt) ;
	
	assign	w_MEM_LB_ADR= {P_MEM_LB_LEN,6'b0};
	
	// Packet Request Parameter Generate
	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_mem_lb_adr	<= 32'h0;
		end else begin
			if ( r_fsm_ctrl == st_MEM_CMD ) begin
				r_mem_lb_adr <= SYS_LB_ADR;
			end else if ( r_fsm_ctrl == st_MEM_ACK ) begin
				r_mem_lb_adr <= r_mem_lb_adr + w_MEM_LB_ADR;
			end
		end
	end
	
	assign	MEM_LB_LEN	= r_mem_req_len		;
	assign	MEM_LB_REQ	= r_mem_req			;
	assign	MEM_LB_ADR	= r_mem_lb_adr		;
	
	reg		[ 7:0]			r_mem_lb_len0			;
	reg						r_sys_lb_ack_tg = 1'b0	;
	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_mem_lb_len0	<= 8'h0;
		end else begin
			if ( r_fsm_ctrl == st_MEM_ACK ) begin
				r_mem_lb_len0 <= r_mem_req_len;
			end
		end
	end
	
	always @ ( posedge MEM_CLK  ) begin
		if ( r_fsm_ctrl == st_MEM_END && w_mem_dat_end ) begin
			r_sys_lb_ack_tg <= ~r_sys_lb_ack_tg;
		end
	end
	
	assign	w_bram_wren = MEM_LB_WREN		;
	assign	w_bram_wdat = MEM_LB_WDAT		;
	
	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_bram_wadr <= 9'h0;
		end else begin
			if ( w_bram_wren ) begin
				r_bram_wadr <= r_bram_wadr + 1'b1;
			end
		end
	end
	
	reg		[ 8:0]		r_bram_wvld_cnt	;
	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_bram_wvld_cnt <= 9'b0;
		end else begin
			if ( MEM_LB_ACK && w_bram_decr ) begin
				r_bram_wvld_cnt <= r_bram_wvld_cnt + r_mem_req_len - r_bram_decr_len;
			end else if ( w_bram_decr ) begin
				r_bram_wvld_cnt <= r_bram_wvld_cnt - r_bram_decr_len;
			end else if ( MEM_LB_ACK ) begin
				r_bram_wvld_cnt <= r_bram_wvld_cnt + r_mem_req_len;
			end
		end
	end
	
	assign	w_bram_wrdy   = ~r_bram_wvld_cnt[8] ;
	assign	w_mem_dat_end = ~|r_bram_wvld_cnt;
	
	XPM_TD_BRAM # (
		.P_ADDR_WIDTH_A		( 9						),
		.P_ADDR_WIDTH_B		( 10					),
		.P_DATA_WIDTH_A		( 512					),
		.P_DATA_WIDTH_B		( 256					)	
	) U_BRAM_512x512b_TO_256b (
		.clka				( MEM_CLK				),//i
		.wea				( w_bram_wren			),//i
		.addra				( r_bram_wadr			),//i
		.dina				( w_bram_wdat			),//i
		.clkb				( CLK					),//i
		.addrb				( r_bram_radr			),//i
		.doutb				( w_bram_rdat			) //o
	);

	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_fifo_wren <= 1'b0;
			r_fifo_wdat <= 9'b0;
		end else begin
			r_fifo_wren <= MEM_LB_WEND;
			r_fifo_wdat <={r_mem_lb_len0,1'b0};
		end
	end
	
	async_fifo_mlab # (									
		.P_ADDRESS			( 3						),	
		.P_DATA_WIDE		( 9						) 	
	) U_SYS2MEM_FIFO (									
		.rst				( RST					),	
		.wr_clk				( MEM_CLK				),	
		.wr_en				( r_fifo_wren			),	
		.wr_din				( r_fifo_wdat			),	
		.almost_full		( 						),	
		.full				( 						),	
		.rd_clk				( CLK					),	
		.rd_en				( r_fifo_rden			),	
		.rd_dout			( w_fifo_rdat			),	
		.rd_cnt				( 						),	
		.almost_empty		( 						),	
		.empty				( w_fifo_empt			)	
	);

	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_fifo_rden_flag <= 1'b0;
		end else begin
			if ( ~w_fifo_empt && ~r_fifo_rden_flag ) begin
				r_fifo_rden_flag <= 1'b1;
			end else if ( w_bram_rend ) begin
				r_fifo_rden_flag <= 1'b0;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_fifo_rden <= 1'b0;
		end else begin
			if ( ~w_fifo_empt && ~r_fifo_rden_flag ) begin
				r_fifo_rden <= 1'b1;
			end else begin
				r_fifo_rden <= 1'b0;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_bram_rden_flag <= 1'b0;
		end else begin
			if ( r_fifo_rden ) begin
				r_bram_rden_flag <= 1'b1;
			end else if ( w_bram_rend ) begin
				r_bram_rden_flag <= 1'b0;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_bram_rlen <= 9'b0;
			r_bram_rcnt <= 9'b0;
		end else begin
			if ( r_fifo_rden ) begin
				r_bram_rlen <= w_fifo_rdat;
				r_bram_rcnt <= w_fifo_rdat;
			end else if ( w_bram_rden ) begin
				r_bram_rcnt <= r_bram_rcnt - 1'b1;
			end
		end
	end
	
	assign	w_bram_rend = ~(|r_bram_rcnt[8:1]) & r_bram_rcnt[0] & w_bram_rden;
	
	assign	w_bram_rden = r_bram_rden_flag & SYS_LB_WRDY;
	
	always @ ( posedge CLK  ) begin
		if ( RST ) begin
			r_bram_radr <= 10'h0;
			r_bram_rdat <= 256'b0;
		end else begin
			if ( w_bram_rden ) begin
				r_bram_radr <= r_bram_radr + 1'b1;
			end
			r_bram_rdat <= w_bram_rdat;
		end
	end
	
	always @ ( posedge CLK  ) begin
		if ( RST ) begin
			r_bram_rden_shf <= 3'h0;
		end else begin
			r_bram_rden_shf <= {r_bram_rden_shf[1:0],w_bram_rden};
		end
	end
	
	assign	SYS_LB_ACK  = w_sys_lb_ack			;
	assign	SYS_LB_WREN = r_bram_rden_shf[1]	;
	assign	SYS_LB_WDAT = r_bram_rdat			;
	
	always @ ( posedge CLK ) begin
		if ( w_bram_rend ) begin
			r_bram_decr_tg <= ~ r_bram_decr_tg;
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_bram_decr_len <= 8'b0;
		end else begin
			if ( w_bram_rend ) begin
				r_bram_decr_len <= r_bram_rlen[8:1];
			end	
		end
	end

	
	always @ ( posedge CLK ) begin
		r_sys_lb_ack_tg_shf <= {r_sys_lb_ack_tg_shf[1:0],r_sys_lb_ack_tg};
	end
	
	assign	w_sys_lb_ack = r_sys_lb_ack_tg_shf[2] ^ r_sys_lb_ack_tg_shf[1];
		
	always @ ( posedge MEM_CLK ) begin
		r_bram_decr_tg_shf <= {r_bram_decr_tg_shf[2:0],r_bram_decr_tg};
	end
	
	assign	w_bram_decr = r_bram_decr_tg_shf[3] ^ r_bram_decr_tg_shf[2];	
	
endmodule
