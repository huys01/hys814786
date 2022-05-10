// =========================================================================
// file name	: MEM_WR_SYNC.v												
// module		: MEM_WR_SYNC												
// =========================================================================
// function		: Write Frame Request Module								
// -------------------------------------------------------------------------
// updata history:															
// -------------------------------------------------------------------------
// rev.level	Date			Coded By			contents				
// v0.0.0		2017/04/12		IR.Shenh			create new				
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
																			
module MEM_WR_ASYNC_256b # (													
	parameter				P_MEM_LB_LEN			= 128 //128x512bit=8K	
) (																			
// Clock & Reset															
	input					CLK						,//i 					
	input					RST						,//i 					
// Sys clock domain 														
	input					SYS_LB_REQ				,//i 					
	input	[ 31:0]			SYS_LB_ADR				,//i [ 31:0]			
	input	[ 19:0]			SYS_LB_LEN				,//i [ 19:0]			
	output					SYS_LB_ACK				,//o 					
	input					SYS_LB_RRDY				,//o 					
	output					SYS_LB_RDEN				,//i 					
	input	[255:0]			SYS_LB_RDAT				,//i [255:0]			
// Memory Clock Domain														
	input					MEM_CLK					,//i 				
	output					MEM_LB_REQ				,//o 					
	output	[ 31:0]			MEM_LB_ADR				,//o [ 31:0]			
	output	[  7:0]			MEM_LB_LEN				,//o [  7:0]			
	input					MEM_LB_ACK				,//i 					
	input					MEM_LB_RDEN				,//i 					
	input					MEM_LB_REND				,//i 					
	output	[511:0]			MEM_LB_RDAT				 //o [511:0]			
);																			
																			
	//----------------------------------------------------------------------
	// State Machine Declaration											
	//----------------------------------------------------------------------
	localparam				st_Idle		= 6'b000001	;
	localparam				st_BCHK		= 6'b000010	;
	localparam				st_Init		= 6'b000100	;
	localparam				st_Brust	= 6'b001000	;
	localparam				st_Check	= 6'b010000	;
	localparam				st_End		= 6'b100000	;
	
	//----------------------------------------------------------------------
	// Signal Declaration													
	//----------------------------------------------------------------------
	reg		[  5:0]			r_main_fsm				;
	reg						r_req_init				;
	reg		[ 19:0]			r_req_len				;
	wire					w_req_end				;
	reg		[ 31:0]			r_req_adr				;
	reg		[  8:0]			r_req_rd_len			;
	reg		[  8:0]			r_req_rd_cnt			;
	reg						r_req_rd_flag			;
	wire					w_brust_end 			;
	reg						r_brust_end				;
	reg						r_bram_wren_t 			;
	reg						r_bram_wren 			;
	reg		[  9:0]			r_bram_wadr 			;
	reg		[255:0]			r_bram_wdat 			;
	reg		[  9:0]			r_bram_wvld_cnt			;
	wire					w_bram_wrdy				;
	wire	[511:0]			w_bram_rdat				;
	reg		[511:0]			r_bram_rdat				;
	reg						r_fifo_wren				;
	reg		[ 39:0]			r_fifo_wdat				;
	wire	[ 39:0]			w_fifo_rdat				;
	wire					w_fifo_empt				;
	reg						r_fifo_rden_flag		;
	reg						r_fifo_rden				;
	reg						r_mem_lb_req			;
	reg		[  7:0]			r_mem_lb_len			;
	reg		[ 31:0]			r_mem_lb_adr			;
	reg		[  8:0]			r_bram_radr				;
	reg						r_bram_decr				;
	reg		[  7:0]			r_bram_decr_len0		;
	reg		[  8:0]			r_bram_decr_len			;
	reg						r_bram_decr_tg	 = 1'b0	;
	reg		[  3:0]			r_bram_decr_tg_shf=4'b0	;
	wire					w_bram_decr				;
																		
	//--------------------------------------------------------------------//
	// synopsys translate_off												
	reg	[8*25:1]	S_FSM_CTRL;												
	always @ ( * ) begin													
		case ( r_main_fsm ) 												
			st_Idle		: S_FSM_CTRL <= "st_Idle	";						
			st_BCHK		: S_FSM_CTRL <= "st_BCHK	";						
			st_Init		: S_FSM_CTRL <= "st_Init	";						
			st_Brust	: S_FSM_CTRL <= "st_Brust	";						
			st_Check	: S_FSM_CTRL <= "st_Check	";						
			st_End		: S_FSM_CTRL <= "st_End		";						
		endcase																
	end																		
	// synopsys translate_on												
	//--------------------------------------------------------------------//
																			
	//----------------------------------------------------------------------
	// FSM:Main State Machine												
	//----------------------------------------------------------------------
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_main_fsm <= st_Idle;
		end else begin
			case ( r_main_fsm ) 
				st_Idle :
					if ( SYS_LB_REQ ) begin
						r_main_fsm <= st_BCHK;
					end
					
				st_BCHK :
					if ( w_bram_wrdy ) begin
						r_main_fsm <= st_Init;
					end
					
				st_Init :
					r_main_fsm <= st_Brust ;
					
				st_Brust :
					if ( w_brust_end ) begin
						r_main_fsm <= st_Check ;
					end
					
				st_Check :
					if ( w_req_end ) begin
						r_main_fsm <= st_End ;
					end else if ( w_bram_wrdy ) begin
						r_main_fsm <= st_Init ;
					end
					
				st_End :
					if ( ~|r_bram_wvld_cnt ) begin
						r_main_fsm <= st_Idle ;
					end
					
				default :
					r_main_fsm <= st_Idle ;
					
			endcase
		end
	end
	
	reg			r_req_ack	;
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_req_ack <= 1'b0;
		end else begin
			if ( r_main_fsm == st_End ) begin
				r_req_ack <= ~|r_bram_wvld_cnt;
			end else begin
				r_req_ack <= 1'b0;
			end
		end
	end
	
	assign	SYS_LB_ACK = r_req_ack;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_req_init <= 1'b0;
		end else begin
			r_req_init <= ( r_main_fsm == st_Init ) ? 1'b1:1'b0;
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_req_len <= 20'b0;
		end else begin
			if ( SYS_LB_REQ ) begin
				r_req_len <= SYS_LB_LEN;
			end else if ( r_req_init ) begin
				r_req_len <= r_req_len - r_req_rd_len;
			end
		end
	end
	
	assign	w_req_end = ~(|r_req_len);
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_req_rd_len <= 9'b0;
		end else begin
			if ( r_main_fsm == st_Init ) begin
				if ( r_req_len > {P_MEM_LB_LEN,1'b0} ) begin
					r_req_rd_len <= {P_MEM_LB_LEN,1'b0};
				end else begin
					r_req_rd_len <= r_req_len[8:0];
				end
			end 
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_req_rd_cnt <= 9'b0;
		end else begin
			if ( r_main_fsm == st_Init ) begin
				r_req_rd_cnt <= 9'b0;
			end else if ( r_req_rd_flag & SYS_LB_RRDY ) begin
				r_req_rd_cnt <= r_req_rd_cnt + 1'b1;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_req_rd_flag <= 1'b0;
		end else begin
			if ( r_main_fsm == st_Init ) begin
				r_req_rd_flag <= 1'b1;
			end else if ( w_brust_end ) begin
				r_req_rd_flag <= 1'b0;
			end
		end
	end
	
	assign	SYS_LB_RDEN = r_req_rd_flag & SYS_LB_RRDY; 
	
	assign	w_brust_end = ( (r_req_rd_len-1'b1) == r_req_rd_cnt ) ? ( r_req_rd_flag & SYS_LB_RRDY) : 1'b0; 
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_brust_end <= 1'b0;
		end else begin
			r_brust_end <= w_brust_end;
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_req_adr <= 32'b0;
		end else begin
			if ( SYS_LB_REQ ) begin
				r_req_adr <= SYS_LB_ADR;
			end else if ( r_brust_end ) begin
				r_req_adr <= r_req_adr + {P_MEM_LB_LEN,6'b0};
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_bram_wren_t <= 1'b0;
			r_bram_wren   <= 1'b0;
		end else begin
			r_bram_wren_t <= r_req_rd_flag & SYS_LB_RRDY;
			r_bram_wren   <= r_bram_wren_t;
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_bram_wadr <= 10'b0;
			r_bram_wdat <= 10'b0;
		end else begin
			if ( r_bram_wren ) begin
				r_bram_wadr <= r_bram_wadr + 1'b1;
			end
			r_bram_wdat <= SYS_LB_RDAT;
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_bram_wvld_cnt <= 10'b0;
		end else begin
			if ( r_bram_wren && w_bram_decr ) begin
				r_bram_wvld_cnt <= r_bram_wvld_cnt + 1'b1 - r_bram_decr_len;
			end else if ( w_bram_decr ) begin
				r_bram_wvld_cnt <= r_bram_wvld_cnt - r_bram_decr_len;
			end else if ( r_bram_wren ) begin
				r_bram_wvld_cnt <= r_bram_wvld_cnt + 1'b1;
			end
		end
	end
	
	assign	w_bram_wrdy = ~r_bram_wvld_cnt[9] ;
	
	//---------------------------------------------------------//
	// 1024x256Bit = 8x128 x 256bit = 8x4096 Byte
	//---------------------------------------------------------//
	XPM_TD_BRAM # (
		.P_ADDR_WIDTH_A		( 10					),	
		.P_ADDR_WIDTH_B		( 9						),	
		.P_DATA_WIDTH_A		( 256					),		
		.P_DATA_WIDTH_B		( 512					)	
	) U_BRAM_1024x256b_TO_512b (
		.clka				( CLK					),//i
		.wea				( r_bram_wren			),//i
		.addra				( r_bram_wadr			),//i
		.dina				( r_bram_wdat			),//i
		.clkb				( MEM_CLK				),//i
		.addrb				( r_bram_radr			),//i
		.doutb				( w_bram_rdat			) //o
	);
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_fifo_wren <=  1'b0;
			r_fifo_wdat <= 40'b0;
		end else begin
			r_fifo_wren <= r_brust_end ;
			r_fifo_wdat <= {r_req_rd_len[8:1],r_req_adr};
		end
	end
	
	async_fifo_mlab # (									
		.P_ADDRESS			( 3						),	
		.P_DATA_WIDE		(40						) 	
	) U_SYS2MEM_FIFO (									
		.rst				( RST					),	
		.wr_clk				( CLK					),	
		.wr_en				( r_fifo_wren			),	
		.wr_din				( r_fifo_wdat			),	
		.almost_full		( 						),	
		.full				( 						),	
		.rd_clk				( MEM_CLK				),	
		.rd_en				( r_fifo_rden			),	
		.rd_dout			( w_fifo_rdat			),	
		.rd_cnt				( 						),	
		.almost_empty		( 						),	
		.empty				( w_fifo_empt			)	
	);
	
	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_fifo_rden_flag <= 1'b0;
		end else begin
			if ( ~w_fifo_empt && ~r_fifo_rden_flag ) begin
				r_fifo_rden_flag <= 1'b1;
			end else if ( MEM_LB_ACK ) begin
				r_fifo_rden_flag <= 1'b0;
			end
		end
	end
	
	always @ ( posedge MEM_CLK ) begin
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
	
	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_mem_lb_req <= 1'b0;
		end else begin
			if ( MEM_LB_ACK ) begin
				r_mem_lb_req <= 1'b0;
			end else if ( r_fifo_rden ) begin
				r_mem_lb_req <= 1'b1;
			end 
		end
	end
	
	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_mem_lb_len <= 8'b0;
			r_mem_lb_adr <=32'b0;
		end else begin
			if ( r_fifo_rden ) begin
				r_mem_lb_len <= w_fifo_rdat[39:32];
				r_mem_lb_adr <= w_fifo_rdat[31: 0];
			end
		end
	end
	
	assign	MEM_LB_REQ = r_mem_lb_req;
	assign 	MEM_LB_LEN = r_mem_lb_len;
	assign	MEM_LB_ADR = r_mem_lb_adr;
	
	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_bram_radr <= 9'b0;
			r_bram_rdat <= 512'b0;
		end else begin
			if ( MEM_LB_RDEN ) begin
				r_bram_radr <= r_bram_radr + 1'b1;
			end
			r_bram_rdat <= w_bram_rdat;
		end
	end
	
	assign	MEM_LB_RDAT = r_bram_rdat;
	
	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_bram_decr_len0 <= 8'b0;
		end else begin
			if ( MEM_LB_ACK ) begin
				r_bram_decr_len0 <= r_mem_lb_len;
			end
		end
	end
	
	always @ ( posedge MEM_CLK ) begin
		if ( MEM_LB_REND ) begin
			r_bram_decr_tg <= ~ r_bram_decr_tg;
		end
	end
	
	always @ ( posedge MEM_CLK ) begin
		if ( RST ) begin
			r_bram_decr_len <= 9'b0;
		end else begin
			if ( MEM_LB_REND ) begin
				r_bram_decr_len <= {r_bram_decr_len0,1'b0};
			end	
		end
	end
		
	always @ ( posedge CLK ) begin
		r_bram_decr_tg_shf <= {r_bram_decr_tg_shf[2:0],r_bram_decr_tg};
	end
	
	assign	w_bram_decr = r_bram_decr_tg_shf[3] ^ r_bram_decr_tg_shf[2];
	
endmodule