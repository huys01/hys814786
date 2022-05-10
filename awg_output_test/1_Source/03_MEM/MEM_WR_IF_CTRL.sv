// =========================================================================
// file name	: MEM_WR_IF_CTRL.v											
// module		: MEM_WR_IF_CTRL											
// =========================================================================
// function		: Memory Write Interface Controller Top Module				
// -------------------------------------------------------------------------
// updata history:															
// -------------------------------------------------------------------------
// rev.level	Date			Coded By			contents				
// v0.0.0		2016/07/05		IR.Shenh			create new				
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
																			
module MEM_WR_IF_CTRL (														
// Clock & Reset															
	input					CLK					,//i 						
	input					RST					,//i 						
//Port0										 								
	MEMW_BUS.slave			MEMW_BUS_00			,// Slave					
	MEMW_BUS.slave			MEMW_BUS_01			,// Slave					
	MEMW_BUS.slave			MEMW_BUS_02			,// Slave					
	MEMW_BUS.slave			MEMW_BUS_03			,// Slave					
	MEMW_BUS.slave			MEMW_BUS_04			,// Slave					
	MEMW_BUS.slave			MEMW_BUS_05			,// Slave					
	MEMW_BUS.slave			MEMW_BUS_06			,// Slave					
	MEMW_BUS.slave			MEMW_BUS_07			,// Slave					
	MEMW_BUS.slave			MEMW_BUS_08			,// Slave					
	MEMW_BUS.slave			MEMW_BUS_09			,// Slave					
// AXI4 Write Master Interface												
	output	[  3:0]			M_AXI_AWID			,//o [  3:0] No used,fixed to 0x0
	output	[ 31:0]			M_AXI_AWADDR		,//o [ 31:0]					
	output	[  7:0]			M_AXI_AWLEN			,//o [  7:0]					
	output	[  2:0]			M_AXI_AWSIZE		,//o [  2:0]					
	output	[  1:0]			M_AXI_AWBURST		,//o [  1:0] Inrement mode,fixed to 0b01 
	output					M_AXI_AWLOCK		,//o 		 No used,fixed to 0
	output	[  3:0]			M_AXI_AWCACHE		,//o [  3:0] Device Non-bufferable,fixed 0x0
	output	[  2:0]			M_AXI_AWPROT		,//o [  2:0] /Unprivileged/Secure/Data access,fixed to 0b000
	output	[  3:0]			M_AXI_AWQOS			,//o [  3:0] Interface is not participating in any QoS scheme,fixed to 0x0
	output					M_AXI_AWVALID		,//o 		 					
	input					M_AXI_AWREADY		,//i 		 					
	output	[511:0]			M_AXI_WDATA			,//o [511:0] 					
	output	[ 63:0]			M_AXI_WSTRB			,//o [ 63:0] fixed to 0xFFFF_FFFF
	output					M_AXI_WLAST			,//o 		 					
	output					M_AXI_WVALID		,//o 		 					
	input					M_AXI_WREADY		,//i 		 					
	input	[  3:0]			M_AXI_BID			,//i [  3:0] No used			
	input	[  1:0]			M_AXI_BRESP			,//i [  1:0] No used			
	input					M_AXI_BVALID		,//i 		 No used			
	output					M_AXI_BREADY		 //o 		 fixed to 1'b1		
);																				
																			
	//----------------------------------------------------------------------
	// State Machine Declaration											
	//----------------------------------------------------------------------
	parameter			st_idle				= 5'b00001;						
	parameter			st_wcmd				= 5'b00010;						
	parameter			st_wt_wcmdrdy		= 5'b00100;						
	parameter			st_wtx_stachk		= 5'b01000;						
	parameter			st_wtx_trig			= 5'b10000;						
																			
	//----------------------------------------------------------------------
	// Signal Declaration													
	//----------------------------------------------------------------------
	wire	[  9:0]		w_usr_req			;
	wire	[  9:0]		w_arb_gnt			;
	wire				w_arb_req			;
	reg		[  7:0]		r_p0_len			;
	reg		[ 31:0]		r_p0_addr			;
	reg		[  7:0]		r_p1_len			;
	reg		[ 31:0]		r_p1_addr			;
	reg		[  7:0]		r_p2_len			;
	reg		[ 31:0]		r_p2_addr			;
	reg		[  7:0]		r_p3_len			;
	reg		[ 31:0]		r_p3_addr			;
	reg		[  7:0]		r_p4_len			;
	reg		[ 31:0]		r_p4_addr			;
	reg		[  7:0]		r_p5_len			;
	reg		[ 31:0]		r_p5_addr			;
	reg		[  7:0]		r_p6_len			;
	reg		[ 31:0]		r_p6_addr			;
	reg		[  7:0]		r_p7_len			;
	reg		[ 31:0]		r_p7_addr			;
	reg		[  7:0]		r_p8_len			;
	reg		[ 31:0]		r_p8_addr			;
	reg		[  7:0]		r_p9_len			;
	reg		[ 31:0]		r_p9_addr			;
	reg		[  7:0]		r_usr0_len			;
	reg		[  7:0]		r_usr1_len			;
	reg		[ 31:0]		r_usr0_addr			;
	reg		[ 31:0]		r_usr1_addr			;
	reg		[  9:0]		r_usr_ack			;
	reg					r_arb_ack			;
	reg		[  4:0]		r_fsm_ctrl			;
	reg		[ 31:0]		r_awaddr			;
	reg		[  7:0]		r_awlen				;
	reg					r_awvalid			;
	reg		[  7:0]		r_wtx_dcnt			;
	wire				w_wtx_dcnt_eq0		;
	reg					r_wtx_busy			;
(* dont_touch="true" *)	reg		[  9:0]		r_arb_gnt_lat		;
(* dont_touch="true" *)	reg		[  9:0]		r_wr_arb_gnt_lat	;
(* dont_touch="true" *)	reg		[  9:0]		r_wr_arb_gnt_lat_d0	;
(* dont_touch="true" *)	reg		[  9:0]		r_wr_arb_gnt_lat_d1	;
(* dont_touch="true" *)	reg		[  9:0]		r_wr_arb_gnt_lat_d2	;
(* dont_touch="true" *)	reg		[  9:0]		r_wdvld				;
(* dont_touch="true" *)	reg		[  9:0]		r_wend				;
	reg		[  3:0]		r_wdvld_shf			;
	reg		[  3:0]		r_wend_shf			;
	wire				w_fifo_wen 			;
	wire				w_fifo_wdata_last	;
	reg		[511:0]		r_wdata0			;
	reg		[511:0]		r_wdata1			;
	wire	[512:0]		w_fifo_wdata		;
	wire				w_fifo_empty		;
	wire				w_wfifo_prog_full	;
	wire				w_fifo_ren 			;
	wire	[512:0]		w_fifo_dout			;
	
	//--------------------------------------------------------------------//
	// synopsys translate_off												
	reg	[8*25:1]	S_FSM_CTRL;											
	always @ ( * ) begin													
		case ( r_fsm_ctrl ) 												
			st_idle			: S_FSM_CTRL = "st_idle			";				
			st_wcmd			: S_FSM_CTRL = "st_wcmd			";				
			st_wt_wcmdrdy	: S_FSM_CTRL = "st_wt_wcmdrdy	";				
			st_wtx_stachk	: S_FSM_CTRL = "st_wtx_stachk	";				
			st_wtx_trig		: S_FSM_CTRL = "st_wtx_trig		";				
		endcase																
	end																		
	// synopsys translate_on												
	//--------------------------------------------------------------------//
	
	//////////////////////////////////////////////////////////
	// Port Arbitor
	//////////////////////////////////////////////////////////
	assign w_usr_req = {
						MEMW_BUS_09.MEMW_REQ,
						MEMW_BUS_08.MEMW_REQ,
						MEMW_BUS_07.MEMW_REQ,
						MEMW_BUS_06.MEMW_REQ,
						MEMW_BUS_05.MEMW_REQ,
						MEMW_BUS_04.MEMW_REQ,
						MEMW_BUS_03.MEMW_REQ,
						MEMW_BUS_02.MEMW_REQ,
						MEMW_BUS_01.MEMW_REQ,
						MEMW_BUS_00.MEMW_REQ };
	
	RR_ARB10 u_rr_arb (
		.CLK			( CLK				),
		.RST			( RST		 		),

		.REQ			( w_usr_req			),
		.ACK			( r_arb_ack			),

		.GNT			( w_arb_gnt			)
	);
	
	assign w_arb_req = ( MEMW_BUS_00.MEMW_REQ & w_arb_gnt[0] ) |
					   ( MEMW_BUS_01.MEMW_REQ & w_arb_gnt[1] ) |
					   ( MEMW_BUS_02.MEMW_REQ & w_arb_gnt[2] ) |
					   ( MEMW_BUS_03.MEMW_REQ & w_arb_gnt[3] ) |
					   ( MEMW_BUS_04.MEMW_REQ & w_arb_gnt[4] ) | 
					   ( MEMW_BUS_05.MEMW_REQ & w_arb_gnt[5] ) | 
					   ( MEMW_BUS_06.MEMW_REQ & w_arb_gnt[6] ) | 
					   ( MEMW_BUS_07.MEMW_REQ & w_arb_gnt[7] ) | 
					   ( MEMW_BUS_08.MEMW_REQ & w_arb_gnt[8] ) | 
					   ( MEMW_BUS_09.MEMW_REQ & w_arb_gnt[9] ) ;
					   ;
	
	always @ ( posedge CLK ) begin
		r_p0_len	<= MEMW_BUS_00.MEMW_LEN;
		r_p0_addr	<= MEMW_BUS_00.MEMW_ADR;
		r_p1_len	<= MEMW_BUS_01.MEMW_LEN;
		r_p1_addr	<= MEMW_BUS_01.MEMW_ADR;
		r_p2_len	<= MEMW_BUS_02.MEMW_LEN;
		r_p2_addr	<= MEMW_BUS_02.MEMW_ADR;
		r_p3_len	<= MEMW_BUS_03.MEMW_LEN;
		r_p3_addr	<= MEMW_BUS_03.MEMW_ADR;
		r_p4_len	<= MEMW_BUS_04.MEMW_LEN;
		r_p4_addr	<= MEMW_BUS_04.MEMW_ADR;
		r_p5_len	<= MEMW_BUS_05.MEMW_LEN;
		r_p5_addr	<= MEMW_BUS_05.MEMW_ADR;
		r_p6_len	<= MEMW_BUS_06.MEMW_LEN;
		r_p6_addr	<= MEMW_BUS_06.MEMW_ADR;
		r_p7_len	<= MEMW_BUS_07.MEMW_LEN;
		r_p7_addr	<= MEMW_BUS_07.MEMW_ADR;
		r_p8_len	<= MEMW_BUS_08.MEMW_LEN;
		r_p8_addr	<= MEMW_BUS_08.MEMW_ADR;
		r_p9_len	<= MEMW_BUS_09.MEMW_LEN;
		r_p9_addr	<= MEMW_BUS_09.MEMW_ADR;
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_usr0_len 	<=  8'b0;
			r_usr0_addr	<= 32'b0;
		end else begin
			if ( w_arb_gnt[0] ) begin
				r_usr0_len 	<= r_p0_len ;
				r_usr0_addr <= r_p0_addr;
			end else if ( w_arb_gnt[1] ) begin
				r_usr0_len 	<= r_p1_len ;
				r_usr0_addr <= r_p1_addr;
			end else if ( w_arb_gnt[2] ) begin
				r_usr0_len 	<= r_p2_len ;
				r_usr0_addr <= r_p2_addr;
			end else if ( w_arb_gnt[3] ) begin
				r_usr0_len 	<= r_p3_len ;
				r_usr0_addr <= r_p3_addr;
			end else if ( w_arb_gnt[4] ) begin
				r_usr0_len 	<= r_p4_len ;
				r_usr0_addr <= r_p4_addr;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_usr1_len 	<=  8'b0;
			r_usr1_addr <= 32'b0;
		end else begin
			if ( w_arb_gnt[5] ) begin
				r_usr1_len 	<= r_p5_len ;
				r_usr1_addr <= r_p5_addr;
			end else if ( w_arb_gnt[6] ) begin
				r_usr1_len 	<= r_p6_len ;
				r_usr1_addr <= r_p6_addr;
			end else if ( w_arb_gnt[7] ) begin
				r_usr1_len 	<= r_p7_len ;
				r_usr1_addr <= r_p7_addr;
			end else if ( w_arb_gnt[8] ) begin
				r_usr1_len 	<= r_p8_len ;
				r_usr1_addr <= r_p8_addr;
			end else if ( w_arb_gnt[9] ) begin
				r_usr1_len 	<= r_p9_len ;
				r_usr1_addr <= r_p9_addr;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_usr_ack <= 10'b0;
			r_arb_ack <= 1'b0;
		end else begin
			if ( r_fsm_ctrl == st_wcmd ) begin
				r_usr_ack <= w_arb_gnt;
				r_arb_ack <= 1'b1;
			end else begin
				r_usr_ack <= 10'b0;
				r_arb_ack <= 1'b0;
			end
		end
	end
	
	assign MEMW_BUS_00.MEMW_ACK   = r_usr_ack[0];
	assign MEMW_BUS_01.MEMW_ACK   = r_usr_ack[1];
	assign MEMW_BUS_02.MEMW_ACK   = r_usr_ack[2];
	assign MEMW_BUS_03.MEMW_ACK   = r_usr_ack[3];
	assign MEMW_BUS_04.MEMW_ACK   = r_usr_ack[4];
	assign MEMW_BUS_05.MEMW_ACK   = r_usr_ack[5];
	assign MEMW_BUS_06.MEMW_ACK   = r_usr_ack[6];
	assign MEMW_BUS_07.MEMW_ACK   = r_usr_ack[7];
	assign MEMW_BUS_08.MEMW_ACK   = r_usr_ack[8];
	assign MEMW_BUS_09.MEMW_ACK   = r_usr_ack[9];
	
	//////////////////////////////////////////////////////////
	// Timing Controller State Machine 
	//////////////////////////////////////////////////////////
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_fsm_ctrl <= st_idle;
		end else begin
			case ( r_fsm_ctrl )
				st_idle				:
					if ( w_arb_req ) begin 
						r_fsm_ctrl <= st_wcmd;
					end else begin 
						r_fsm_ctrl <= st_idle;
					end 
				
				st_wcmd				:
					r_fsm_ctrl <= st_wt_wcmdrdy;
				
				st_wt_wcmdrdy		: 
					if ( M_AXI_AWREADY ) begin 
						r_fsm_ctrl <= st_wtx_stachk;
					end else begin 
						r_fsm_ctrl <= st_wt_wcmdrdy;
					end 
				
				st_wtx_stachk		:
					if ( !r_wtx_busy && !w_wfifo_prog_full ) begin 
						r_fsm_ctrl <= st_wtx_trig;
					end else begin 
						r_fsm_ctrl <= st_wtx_stachk;
					end 
				
				st_wtx_trig			:
					r_fsm_ctrl <= st_idle;
				
				default				:
					r_fsm_ctrl <= st_idle;
			endcase
		end
	end
	
	//////////////////////////////////////////////////////////
	//  Write Address Channel Signals generate 
	//////////////////////////////////////////////////////////
	//Write Address generate 
	//Write Length generate 
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_awaddr <= 32'b0;
			r_awlen <= 8'b0;
		end else begin
			if ( r_fsm_ctrl == st_wcmd ) begin
				if ( w_arb_gnt[4:0] ) begin 
					r_awaddr <= r_usr0_addr;
					r_awlen  <= r_usr0_len-1'b1;
				end else begin
					r_awaddr <= r_usr1_addr;
					r_awlen  <= r_usr1_len-1'b1;
				end
			end 
		end
	end	
	
	//Write Valid generate 	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_awvalid <= 1'b0;
		end else begin
			if ( r_fsm_ctrl == st_wcmd ) begin 
				r_awvalid <= 1'b1;
			end else if ( M_AXI_AWREADY ) begin 
				r_awvalid <= 1'b0;
			end 
		end
	end	
	
	assign M_AXI_AWID		= 4'b0		;
	assign M_AXI_AWADDR		= r_awaddr	;
	assign M_AXI_AWLEN		= r_awlen	;
	assign M_AXI_AWSIZE		= 3'b110	;
	assign M_AXI_AWBURST	= 2'b01		;
	assign M_AXI_AWLOCK		= 1'b0		;
	assign M_AXI_AWCACHE	= 4'b0		;
	assign M_AXI_AWPROT		= 3'b0		;
	assign M_AXI_AWQOS		= 4'b0		;
	assign M_AXI_AWVALID	= r_awvalid	;
	
	//////////////////////////////////////////////////////////
	//  Write Data Channel Signals generate 
	//////////////////////////////////////////////////////////
	//Write Data Counter
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_wtx_dcnt <= 8'b0;
		end else begin
			if ( r_fsm_ctrl == st_wtx_trig ) begin 
				r_wtx_dcnt <= r_awlen;
			end else if( !w_wtx_dcnt_eq0 ) begin 
				r_wtx_dcnt <= r_wtx_dcnt - 1'b1;
			end 
		end
	end	
	
	assign	w_wtx_dcnt_eq0 = ~(|r_wtx_dcnt) ;
	
	//Write Data Transfer Busy flag
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_wtx_busy <= 1'b0;
		end else begin
			if ( r_fsm_ctrl == st_wtx_trig ) begin
				r_wtx_busy <= 1'b1;
			end else if( w_wtx_dcnt_eq0 ) begin 
				r_wtx_busy <= 1'b0;
			end 
		end
	end	

	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_arb_gnt_lat <= 10'b0;
		end else begin
			if ( r_fsm_ctrl == st_wcmd ) begin 
				r_arb_gnt_lat<= w_arb_gnt;
			end 
		end
	end	

	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_wr_arb_gnt_lat <= 10'b0;
		end else begin
			if ( r_fsm_ctrl == st_wtx_trig ) begin 
				r_wr_arb_gnt_lat <= r_arb_gnt_lat;
			end 
		end
	end	
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_wdvld <= 10'b0;
			r_wend  <= 10'b0;
		end else begin
			r_wdvld[0] <= r_wtx_busy & r_wr_arb_gnt_lat[0];
			r_wdvld[1] <= r_wtx_busy & r_wr_arb_gnt_lat[1];
			r_wdvld[2] <= r_wtx_busy & r_wr_arb_gnt_lat[2];
			r_wdvld[3] <= r_wtx_busy & r_wr_arb_gnt_lat[3];
			r_wdvld[4] <= r_wtx_busy & r_wr_arb_gnt_lat[4];
			r_wdvld[5] <= r_wtx_busy & r_wr_arb_gnt_lat[5];
			r_wdvld[6] <= r_wtx_busy & r_wr_arb_gnt_lat[6];
			r_wdvld[7] <= r_wtx_busy & r_wr_arb_gnt_lat[7];
			r_wdvld[8] <= r_wtx_busy & r_wr_arb_gnt_lat[8];
			r_wdvld[9] <= r_wtx_busy & r_wr_arb_gnt_lat[9];
			r_wend[0]  <= r_wtx_busy & w_wtx_dcnt_eq0 & r_wr_arb_gnt_lat[0];
			r_wend[1]  <= r_wtx_busy & w_wtx_dcnt_eq0 & r_wr_arb_gnt_lat[1];
			r_wend[2]  <= r_wtx_busy & w_wtx_dcnt_eq0 & r_wr_arb_gnt_lat[2];
			r_wend[3]  <= r_wtx_busy & w_wtx_dcnt_eq0 & r_wr_arb_gnt_lat[3];
			r_wend[4]  <= r_wtx_busy & w_wtx_dcnt_eq0 & r_wr_arb_gnt_lat[4];
			r_wend[5]  <= r_wtx_busy & w_wtx_dcnt_eq0 & r_wr_arb_gnt_lat[5];
			r_wend[6]  <= r_wtx_busy & w_wtx_dcnt_eq0 & r_wr_arb_gnt_lat[6];
			r_wend[7]  <= r_wtx_busy & w_wtx_dcnt_eq0 & r_wr_arb_gnt_lat[7];
			r_wend[8]  <= r_wtx_busy & w_wtx_dcnt_eq0 & r_wr_arb_gnt_lat[8];
			r_wend[9]  <= r_wtx_busy & w_wtx_dcnt_eq0 & r_wr_arb_gnt_lat[9];
		end
	end	
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_wdvld_shf <= 4'b0;
			r_wend_shf  <= 4'b0;    
			r_wr_arb_gnt_lat_d0 <= 10'b0;
			r_wr_arb_gnt_lat_d1 <= 10'b0;
			r_wr_arb_gnt_lat_d2 <= 10'b0;
		end else begin
			r_wdvld_shf <= {r_wdvld_shf[3:0],r_wtx_busy};
			r_wend_shf[0] <= r_wtx_busy & w_wtx_dcnt_eq0;
			r_wend_shf[3:1] <=  r_wend_shf[2:0];
			r_wr_arb_gnt_lat_d0 <= r_wr_arb_gnt_lat;
			r_wr_arb_gnt_lat_d1 <= r_wr_arb_gnt_lat_d0;
			r_wr_arb_gnt_lat_d2 <= r_wr_arb_gnt_lat_d1;
		end
	end	
	
	assign	MEMW_BUS_00.MEMW_RDEN = r_wdvld[0]	;
	assign	MEMW_BUS_01.MEMW_RDEN = r_wdvld[1]	;
	assign	MEMW_BUS_02.MEMW_RDEN = r_wdvld[2]	;
	assign	MEMW_BUS_03.MEMW_RDEN = r_wdvld[3]	;
	assign	MEMW_BUS_04.MEMW_RDEN = r_wdvld[4]	;
	assign	MEMW_BUS_05.MEMW_RDEN = r_wdvld[5]	;
	assign	MEMW_BUS_06.MEMW_RDEN = r_wdvld[6]	;
	assign	MEMW_BUS_07.MEMW_RDEN = r_wdvld[7]	;
	assign	MEMW_BUS_08.MEMW_RDEN = r_wdvld[8]	;
	assign	MEMW_BUS_09.MEMW_RDEN = r_wdvld[9]	;
	assign	MEMW_BUS_00.MEMW_REND = r_wend[0]	;
	assign	MEMW_BUS_01.MEMW_REND = r_wend[1]	;
	assign	MEMW_BUS_02.MEMW_REND = r_wend[2]	;
	assign	MEMW_BUS_03.MEMW_REND = r_wend[3]	;
	assign	MEMW_BUS_04.MEMW_REND = r_wend[4]	;
	assign	MEMW_BUS_05.MEMW_REND = r_wend[5]	;
	assign	MEMW_BUS_06.MEMW_REND = r_wend[6]	;
	assign	MEMW_BUS_07.MEMW_REND = r_wend[7]	;
	assign	MEMW_BUS_08.MEMW_REND = r_wend[8]	;
	assign	MEMW_BUS_09.MEMW_REND = r_wend[9]	;
	
	assign	w_fifo_wen 			= r_wdvld_shf[3];
	assign	w_fifo_wdata_last	= r_wend_shf[3];

	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_wdata0 <= 512'b0;
		end else begin
			if ( r_wr_arb_gnt_lat_d2[0] ) begin 
				r_wdata0 <= MEMW_BUS_00.MEMW_RDAT;
			end else if ( r_wr_arb_gnt_lat_d2[1] ) begin 
				r_wdata0 <= MEMW_BUS_01.MEMW_RDAT;
			end else if ( r_wr_arb_gnt_lat_d2[2] ) begin 
				r_wdata0 <= MEMW_BUS_02.MEMW_RDAT;
			end else if ( r_wr_arb_gnt_lat_d2[3] ) begin 
				r_wdata0 <= MEMW_BUS_03.MEMW_RDAT;
			end else if ( r_wr_arb_gnt_lat_d2[4] ) begin 
				r_wdata0 <= MEMW_BUS_04.MEMW_RDAT;
			end 
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_wdata1 <= 512'b0;
		end else begin
			if ( r_wr_arb_gnt_lat_d2[5] ) begin 
				r_wdata1 <= MEMW_BUS_05.MEMW_RDAT;
			end else if ( r_wr_arb_gnt_lat_d2[6] ) begin 
				r_wdata1 <= MEMW_BUS_06.MEMW_RDAT;
			end else if ( r_wr_arb_gnt_lat_d2[7] ) begin 
				r_wdata1 <= MEMW_BUS_07.MEMW_RDAT;
			end else if ( r_wr_arb_gnt_lat_d2[8] ) begin 
				r_wdata1 <= MEMW_BUS_08.MEMW_RDAT;
			end else if ( r_wr_arb_gnt_lat_d2[9] ) begin 
				r_wdata1 <= MEMW_BUS_09.MEMW_RDAT;
			end 
		end
	end	
	
	assign	w_fifo_wdata[511:0] = (|r_wr_arb_gnt_lat_d2[9:5]) ? r_wdata1 : r_wdata0;
	assign	w_fifo_wdata[512]   = w_fifo_wdata_last;
	
	XPM_SYNC_FIFO # (
		.P_ADDR_WIDTH		( 8						),	
		.P_DATA_WIDTH		( 513					),	
		.P_PROG_EMPT_THRESH	( 10					),
		.P_PROG_FULL_THRESH	( 240					)
	)u_fwft_fifo (
		.clk				( CLK					),
		.rst				( RST					),
		.din				( w_fifo_wdata			),
		.wr_en				( w_fifo_wen			),
		.rd_en				( w_fifo_ren			),
		.dout				( w_fifo_dout			),
		.full				( 						),
		.empty				( w_fifo_empty			),
		.prog_full			( w_wfifo_prog_full		)
	);
	
	assign M_AXI_WDATA		= w_fifo_dout[511:0];
	assign M_AXI_WSTRB		= 64'HFFFF_FFFF_FFFF_FFFF;
	assign M_AXI_WLAST		= w_fifo_dout[512];
	assign M_AXI_WVALID		= ~w_fifo_empty;
	assign w_fifo_ren 		= ~w_fifo_empty & M_AXI_WREADY;

	//////////////////////////////////////////////////////////
	/* Write Data Response Channel Signals */		
	//////////////////////////////////////////////////////////
	assign M_AXI_BREADY    	= 1'b1;
	
endmodule