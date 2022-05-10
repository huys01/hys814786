// =========================================================================
// INNORISE <Hefei> Electronic Co Ltd.										
// =========================================================================
// file name	: MEM_RD_IF_CTRL.v											
// module		: MEM_RD_IF_CTRL											
// =========================================================================
// function		: Memory Read Interface Controller Top Module				
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
`timescale 1 ps / 1 ps														
																			
module MEM_RD_IF_CTRL (														
// Clock & Reset															
	input					CLK					,//i 						
	input					RST					,//i 						
//Port0											 							
	MEMR_BUS.slave			MEMR_BUS_00			,// Slave					
	MEMR_BUS.slave			MEMR_BUS_01			,// Slave					
	MEMR_BUS.slave			MEMR_BUS_02			,// Slave					
	MEMR_BUS.slave			MEMR_BUS_03			,// Slave					
	MEMR_BUS.slave			MEMR_BUS_04			,// Slave					
	MEMR_BUS.slave			MEMR_BUS_05			,// Slave					
	MEMR_BUS.slave			MEMR_BUS_06			,// Slave					
	MEMR_BUS.slave			MEMR_BUS_07			,// Slave					
	MEMR_BUS.slave			MEMR_BUS_08			,// Slave					
	MEMR_BUS.slave			MEMR_BUS_09			,// Slave					
// AXI4 Read Master Interface												
	output	[  3:0]			M_AXI_ARID			,//o [  3:0] 				
	output	[ 31:0]			M_AXI_ARADDR		,//o [ 31:0] 				
	output	[  7:0]			M_AXI_ARLEN			,//o [  7:0] 				
	output	[  2:0]			M_AXI_ARSIZE		,//o [  2:0] 				
	output	[  1:0]			M_AXI_ARBURST		,//o [  1:0] Inrement mode,fixed to 0b01 
	output					M_AXI_ARLOCK		,//o 		 No used,fixed to 0                                           
	output	[  3:0]			M_AXI_ARCACHE		,//o [  3:0] Device Non-bufferable,fixed 0x0                              
	output	[  2:0]			M_AXI_ARPROT		,//o [  2:0] Unprivileged/Secure/Data access,fixed to 0b000               
	output	[  3:0]			M_AXI_ARQOS			,//o [  3:0] Interface is not participating in any QoS scheme,fixed to 0x0
	output					M_AXI_ARVALID		,//o 						
	input					M_AXI_ARREADY		,//i 						
	input	[  3:0]			M_AXI_RID			,//i [  3:0] No used		
	input	[511:0]			M_AXI_RDATA			,//i [511:0] 				
	input	[  1:0]			M_AXI_RRESP			,//i [  1:0] No used		
	input					M_AXI_RLAST			,//i 		 				
	input					M_AXI_RVALID		,//i 		 				
	output					M_AXI_RREADY		 //o 		 fixed to 1'b1	
);																			
																			
	//----------------------------------------------------------------------
	// State Machine Declaration											
	//----------------------------------------------------------------------
	parameter			st_idle				= 3'b001;						
	parameter			st_rcmd				= 3'b010;						
	parameter			st_wt_rcmdrdy		= 3'b100;						
	reg		[  2:0]		r_fsm_ctrl					;						
																			
	//----------------------------------------------------------------------
	// Signal Declaration													
	//----------------------------------------------------------------------
	wire	[  9:0]		w_usr_req			;								
	wire	[  9:0]		w_arb_gnt			;								
	wire				w_arb_req			;								
	reg		[  9:0]		r_arb_gnt			;								
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
	reg		[ 31:0]		r_usr0_addr			;								
	reg		[  7:0]		r_usr1_len			;								
	reg		[ 31:0]		r_usr1_addr			;								
	reg		[  9:0]		r_usr_ack			;								
	reg					r_arb_ack			;								
	reg		[ 31:0]		r_araddr			;								
	reg		[  7:0]		r_arlen				;								
	reg					r_arvalid			;								
(* dont_touch="true" *)		reg		[  9:0]		r_arb_gnt_lat		;								
(* dont_touch="true" *)		reg		[  3:0]		r_arid				;								
(* dont_touch="true" *)		wire	[  9:0]		w_rvld				;								
(* dont_touch="true" *)		wire	[  9:0]		w_rend				;								
(* dont_touch="true" *)		reg		[  9:0]		r_rvld				;								
(* dont_touch="true" *)		reg		[  9:0]		r_rend				;								
(* dont_touch="true" *)		reg		[511:0]		r_rdata0			;								
(* dont_touch="true" *)		reg		[511:0]		r_rdata1			;								
																			
	//--------------------------------------------------------------------//
	// synopsys translate_off												
	reg	[25*8:1]	S_FSM_CTRL;											
	always @ ( * ) begin													
		case ( r_fsm_ctrl ) 												
			st_idle			: S_FSM_CTRL = "st_idle			";				
			st_rcmd			: S_FSM_CTRL = "st_rcmd			";				
			st_wt_rcmdrdy	: S_FSM_CTRL = "st_wt_rcmdrdy	";				
		endcase																
	end																		
	// synopsys translate_on												
	//--------------------------------------------------------------------//
	
	//--------------------------------------------------------------------//
	// Port Arbitor
	//--------------------------------------------------------------------//
	assign w_usr_req[9:0] = {
							 MEMR_BUS_09.MEMR_REQ,
							 MEMR_BUS_08.MEMR_REQ,
							 MEMR_BUS_07.MEMR_REQ,
							 MEMR_BUS_06.MEMR_REQ,
							 MEMR_BUS_05.MEMR_REQ,
							 MEMR_BUS_04.MEMR_REQ,
							 MEMR_BUS_03.MEMR_REQ,
							 MEMR_BUS_02.MEMR_REQ,
							 MEMR_BUS_01.MEMR_REQ,
							 MEMR_BUS_00.MEMR_REQ };
	
	RR_ARB10 u_rr_arb (
		.CLK			( CLK				),
		.RST			( RST		 		),

		.REQ			( w_usr_req			),
		.ACK			( r_arb_ack			),

		.GNT			( w_arb_gnt			)
	);
	
	assign w_arb_req = ( MEMR_BUS_00.MEMR_REQ & w_arb_gnt[0] ) |
					   ( MEMR_BUS_01.MEMR_REQ & w_arb_gnt[1] ) |
					   ( MEMR_BUS_02.MEMR_REQ & w_arb_gnt[2] ) |
					   ( MEMR_BUS_03.MEMR_REQ & w_arb_gnt[3] ) |
					   ( MEMR_BUS_04.MEMR_REQ & w_arb_gnt[4] ) |
					   ( MEMR_BUS_05.MEMR_REQ & w_arb_gnt[5] ) |
					   ( MEMR_BUS_06.MEMR_REQ & w_arb_gnt[6] ) |
					   ( MEMR_BUS_07.MEMR_REQ & w_arb_gnt[7] ) |
					   ( MEMR_BUS_08.MEMR_REQ & w_arb_gnt[8] ) |
					   ( MEMR_BUS_09.MEMR_REQ & w_arb_gnt[9] ) ;
	
	//Arbiter Grant Delay
	always @ ( posedge CLK ) begin
		if (RST ) begin
			r_arb_gnt <= 10'b0;
		end else begin
			r_arb_gnt <= w_arb_gnt;
		end
	end
	
	always @ ( posedge CLK ) begin
		r_p0_len	<= MEMR_BUS_00.MEMR_LEN; 
		r_p0_addr	<= MEMR_BUS_00.MEMR_ADR; 
		r_p1_len	<= MEMR_BUS_01.MEMR_LEN; 
		r_p1_addr	<= MEMR_BUS_01.MEMR_ADR; 
		r_p2_len	<= MEMR_BUS_02.MEMR_LEN; 
		r_p2_addr	<= MEMR_BUS_02.MEMR_ADR; 
		r_p3_len	<= MEMR_BUS_03.MEMR_LEN; 
		r_p3_addr	<= MEMR_BUS_03.MEMR_ADR; 
		r_p4_len	<= MEMR_BUS_04.MEMR_LEN; 
		r_p4_addr	<= MEMR_BUS_04.MEMR_ADR; 
		r_p5_len	<= MEMR_BUS_05.MEMR_LEN; 
		r_p5_addr	<= MEMR_BUS_05.MEMR_ADR; 
		r_p6_len	<= MEMR_BUS_06.MEMR_LEN; 
		r_p6_addr	<= MEMR_BUS_06.MEMR_ADR; 
		r_p7_len	<= MEMR_BUS_07.MEMR_LEN; 
		r_p7_addr	<= MEMR_BUS_07.MEMR_ADR; 
		r_p8_len	<= MEMR_BUS_08.MEMR_LEN; 
		r_p8_addr	<= MEMR_BUS_08.MEMR_ADR; 
		r_p9_len	<= MEMR_BUS_09.MEMR_LEN; 
		r_p9_addr	<= MEMR_BUS_09.MEMR_ADR; 
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_usr0_len 	<=  8'b0;
			r_usr0_addr <= 32'b0;
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
			if ( r_fsm_ctrl == st_rcmd ) begin
				r_usr_ack <= w_arb_gnt;
				r_arb_ack <= 1'b1;
			end else begin
				r_usr_ack <= 5'b0;
				r_arb_ack <= 1'b0;
			end
		end
	end
	
	assign MEMR_BUS_00.MEMR_ACK   = r_usr_ack[0];
	assign MEMR_BUS_01.MEMR_ACK   = r_usr_ack[1];
	assign MEMR_BUS_02.MEMR_ACK   = r_usr_ack[2];
	assign MEMR_BUS_03.MEMR_ACK   = r_usr_ack[3];
	assign MEMR_BUS_04.MEMR_ACK   = r_usr_ack[4];
	assign MEMR_BUS_05.MEMR_ACK   = r_usr_ack[5];
	assign MEMR_BUS_06.MEMR_ACK   = r_usr_ack[6];
	assign MEMR_BUS_07.MEMR_ACK   = r_usr_ack[7];
	assign MEMR_BUS_08.MEMR_ACK   = r_usr_ack[8];
	assign MEMR_BUS_09.MEMR_ACK   = r_usr_ack[9];
	
	//--------------------------------------------------------------//
	// Timing Controller State Machine 
	//--------------------------------------------------------------//
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_fsm_ctrl <= st_idle;
		end else begin
			case ( r_fsm_ctrl )
				st_idle				:
					if ( w_arb_req ) begin 
						r_fsm_ctrl <= st_rcmd;
					end else begin 
						r_fsm_ctrl <= st_idle;
					end 
				
				st_rcmd				:
					r_fsm_ctrl <= st_wt_rcmdrdy;
				
				st_wt_rcmdrdy		: 
					if ( M_AXI_ARREADY ) begin 
						r_fsm_ctrl <= st_idle;
					end else begin 
						r_fsm_ctrl <= st_wt_rcmdrdy;
					end 
				
				default				:
					r_fsm_ctrl <= st_idle;
			endcase
		end
	end
	
	//--------------------------------------------------------------//
	//  Read Address Channel Signals generate 
	//--------------------------------------------------------------//
	
	//Read Address Length generate 
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_araddr <= 32'b0;
			r_arlen <= 8'b0;
		end else begin
			if ( r_fsm_ctrl == st_rcmd ) begin
				if ( |r_arb_gnt[4:0] ) begin 
					r_araddr <= r_usr0_addr;
					r_arlen  <= r_usr0_len-1'b1;
				end else begin
					r_araddr <= r_usr1_addr;
					r_arlen  <= r_usr1_len-1'b1;
				end
			end 
		end
	end	
	
	//Read Valid generate 	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_arvalid <= 1'b0;
		end else begin
			if ( r_fsm_ctrl == st_rcmd ) begin 
				r_arvalid <= 1'b1;
			end else if ( M_AXI_ARREADY ) begin 
				r_arvalid <= 1'b0;
			end 
		end
	end	
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_arb_gnt_lat <= 10'b0;
		end else begin
			if ( r_fsm_ctrl == st_idle ) begin 
				r_arb_gnt_lat<= w_arb_gnt;
			end 
		end
	end	
	
	//Read ID generate 	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_arid <= 4'b0;
		end else begin
			if ( r_fsm_ctrl == st_rcmd ) begin
				case ( r_arb_gnt_lat ) 
					10'H001	: r_arid <= 4'H0;
					10'H002	: r_arid <= 4'H1;
					10'H004	: r_arid <= 4'H2;
					10'H008	: r_arid <= 4'H3;
					10'H010	: r_arid <= 4'H4;
					10'H020	: r_arid <= 4'H5;
					10'H040	: r_arid <= 4'H6;
					10'H080	: r_arid <= 4'H7;
					10'H100	: r_arid <= 4'H8;
					10'H200	: r_arid <= 4'H9;
				endcase
			end 
		end
	end	
	
	assign M_AXI_ARID		= r_arid	;
	assign M_AXI_ARADDR		= r_araddr	;
	assign M_AXI_ARLEN		= r_arlen	;
	assign M_AXI_ARSIZE		= 3'b110	;
	assign M_AXI_ARBURST	= 2'b01		;
	assign M_AXI_ARLOCK		= 1'b0		;
	assign M_AXI_ARCACHE	= 4'b0		;
	assign M_AXI_ARPROT		= 3'b0		;
	assign M_AXI_ARQOS		= 4'b0		;
	assign M_AXI_ARVALID	= r_arvalid	;

	//////////////////////////////////////////////////////////
	/* Read Data Channel Signals */
	//////////////////////////////////////////////////////////
	
	assign	M_AXI_RREADY		= 1'b1;
	
	assign	w_rvld[0] = ( M_AXI_RID == 4'H0 ) ? M_AXI_RVALID : 1'b0 ;
	assign	w_rvld[1] = ( M_AXI_RID == 4'H1 ) ? M_AXI_RVALID : 1'b0 ;
	assign	w_rvld[2] = ( M_AXI_RID == 4'H2 ) ? M_AXI_RVALID : 1'b0 ;
	assign	w_rvld[3] = ( M_AXI_RID == 4'H3 ) ? M_AXI_RVALID : 1'b0 ;
	assign	w_rvld[4] = ( M_AXI_RID == 4'H4 ) ? M_AXI_RVALID : 1'b0 ;
	assign	w_rvld[5] = ( M_AXI_RID == 4'H5 ) ? M_AXI_RVALID : 1'b0 ;
	assign	w_rvld[6] = ( M_AXI_RID == 4'H6 ) ? M_AXI_RVALID : 1'b0 ;
	assign	w_rvld[7] = ( M_AXI_RID == 4'H7 ) ? M_AXI_RVALID : 1'b0 ;
	assign	w_rvld[8] = ( M_AXI_RID == 4'H8 ) ? M_AXI_RVALID : 1'b0 ;
	assign	w_rvld[9] = ( M_AXI_RID == 4'H9 ) ? M_AXI_RVALID : 1'b0 ;
	
	assign	w_rend[0] = ( M_AXI_RID == 4'H0 ) ? ( M_AXI_RLAST & M_AXI_RVALID ): 1'b0 ;
	assign	w_rend[1] = ( M_AXI_RID == 4'H1 ) ? ( M_AXI_RLAST & M_AXI_RVALID ): 1'b0 ;
	assign	w_rend[2] = ( M_AXI_RID == 4'H2 ) ? ( M_AXI_RLAST & M_AXI_RVALID ): 1'b0 ;
	assign	w_rend[3] = ( M_AXI_RID == 4'H3 ) ? ( M_AXI_RLAST & M_AXI_RVALID ): 1'b0 ;
	assign	w_rend[4] = ( M_AXI_RID == 4'H4 ) ? ( M_AXI_RLAST & M_AXI_RVALID ): 1'b0 ;
	assign	w_rend[5] = ( M_AXI_RID == 4'H5 ) ? ( M_AXI_RLAST & M_AXI_RVALID ): 1'b0 ;
	assign	w_rend[6] = ( M_AXI_RID == 4'H6 ) ? ( M_AXI_RLAST & M_AXI_RVALID ): 1'b0 ;
	assign	w_rend[7] = ( M_AXI_RID == 4'H7 ) ? ( M_AXI_RLAST & M_AXI_RVALID ): 1'b0 ;
	assign	w_rend[8] = ( M_AXI_RID == 4'H8 ) ? ( M_AXI_RLAST & M_AXI_RVALID ): 1'b0 ;
	assign	w_rend[9] = ( M_AXI_RID == 4'H9 ) ? ( M_AXI_RLAST & M_AXI_RVALID ): 1'b0 ;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_rvld	<= 10'b0;
			r_rend	<= 10'b0;
			r_rdata0<= 512'b0;
			r_rdata1<= 512'b0;
		end else begin
			r_rvld	<= w_rvld;
			r_rend	<= w_rend;
			r_rdata0<= M_AXI_RDATA;
			r_rdata1<= M_AXI_RDATA;
		end
	end	
	
	assign MEMR_BUS_00.MEMR_WREN		= r_rvld[0];
	assign MEMR_BUS_01.MEMR_WREN		= r_rvld[1];
	assign MEMR_BUS_02.MEMR_WREN		= r_rvld[2];
	assign MEMR_BUS_03.MEMR_WREN		= r_rvld[3];
	assign MEMR_BUS_04.MEMR_WREN		= r_rvld[4];
	assign MEMR_BUS_05.MEMR_WREN		= r_rvld[5];
	assign MEMR_BUS_06.MEMR_WREN		= r_rvld[6];
	assign MEMR_BUS_07.MEMR_WREN		= r_rvld[7];
	assign MEMR_BUS_08.MEMR_WREN		= r_rvld[8];
	assign MEMR_BUS_09.MEMR_WREN		= r_rvld[9];
	assign MEMR_BUS_00.MEMR_WEND		= r_rend[0];
	assign MEMR_BUS_01.MEMR_WEND		= r_rend[1];
	assign MEMR_BUS_02.MEMR_WEND		= r_rend[2];
	assign MEMR_BUS_03.MEMR_WEND		= r_rend[3];
	assign MEMR_BUS_04.MEMR_WEND		= r_rend[4];
	assign MEMR_BUS_05.MEMR_WEND		= r_rend[5];
	assign MEMR_BUS_06.MEMR_WEND		= r_rend[6];
	assign MEMR_BUS_07.MEMR_WEND		= r_rend[7];
	assign MEMR_BUS_08.MEMR_WEND		= r_rend[8];
	assign MEMR_BUS_09.MEMR_WEND		= r_rend[9];
	
	assign MEMR_BUS_00.MEMR_WDAT		= r_rdata0	;
	assign MEMR_BUS_01.MEMR_WDAT		= r_rdata0	;
	assign MEMR_BUS_02.MEMR_WDAT		= r_rdata0	;
	assign MEMR_BUS_03.MEMR_WDAT		= r_rdata0	;
	assign MEMR_BUS_04.MEMR_WDAT		= r_rdata0	;
	assign MEMR_BUS_05.MEMR_WDAT		= r_rdata1	;
	assign MEMR_BUS_06.MEMR_WDAT		= r_rdata1	;
	assign MEMR_BUS_07.MEMR_WDAT		= r_rdata1	;
	assign MEMR_BUS_08.MEMR_WDAT		= r_rdata1	;
	assign MEMR_BUS_09.MEMR_WDAT		= r_rdata1	;
	
endmodule 