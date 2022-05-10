																				
// =============================================================================
// Timescale Define																
// =============================================================================
																				
`timescale 1ns / 1ps															
																				
module SPI_MIF0 # ( 															
	parameter							P_SCLK_WIDTH	= 4		,
	parameter							P_ADDR_WIDTH	= 15	,				
	parameter							P_DATA_WIDTH	= 16					
) (																				
//Clock & Reset																	
	input								CLK						,//i 			
	input								RST						,//i 			
//Local Bus 																	
	input								LB_REQ					,//i 			
	input								LB_RNW					,//i 			
	input	[P_ADDR_WIDTH-1:0]			LB_ADR					,//i 			
	input	[P_DATA_WIDTH-1:0]			LB_WDAT					,//i 			
	output	[P_DATA_WIDTH-1:0]			LB_RDAT					,//o 			
	output								LB_ACK					,//o  			
//External Port																	
	output								SPI_CSN					,//o 			
	output								SPI_SCL					,//o 			
	output								SPI_SDO					,//o 			
	output								SPI_SDO_t				,//o 			
	input								SPI_SDI					 //i 			
);																				
																				
	localparam							st_Idle	= 5'b00001		;
	localparam							st_Rnw	= 5'b00010		;
	localparam							st_Addr	= 5'b00100		;
	localparam							st_Data	= 5'b01000		;
	localparam							st_End	= 5'b10000		;

	reg									r_lb_req				;
	wire								w_lb_req_pl				;
	reg									r_lb_rnw				;
	reg		[P_ADDR_WIDTH-1:0]			r_lb_adr				;
	reg		[P_DATA_WIDTH-1:0]			r_lb_wdat				;
	reg		[ 4:0]						r_main_fsm				;
	reg									r_csn					;
	reg									r_sclk_gen_flag			;
	reg		[P_SCLK_WIDTH-1:0]			r_sclk_cnt				;
	wire								w_sclk_pl				;
	wire								w_sclk_nl				;
	reg									r_sclk					;
	reg		[ 3:0]						r_lb_addr_cnt			;
	wire								w_addr_end				;
	reg		[P_ADDR_WIDTH-1:0]			r_lb_addr_shf			;
	reg		[ 3:0]						r_lb_data_cnt			;
	wire								w_data_end				;
	reg		[P_DATA_WIDTH-1:0]			r_lb_wdat_shf			;
	reg									r_mosi					;
	reg									r_mosi_t				;
	reg									r_mosi_o_t				;
	reg		[P_DATA_WIDTH-1:0]			r_lb_rdat_shf			;
	reg		[ 1:0]						r_wait_cnt				;
	wire								w_wait_end				;
	reg		[P_SCLK_WIDTH+1:0]			r_end_cnt				;
	wire								w_end_end				;
	reg		[P_DATA_WIDTH-1:0]			r_lb_rdat				;
	reg									r_lb_ack				;

(* IOB="true" *)reg						r_csn_o					;
(* IOB="true" *)reg						r_sclk_o				;
(* IOB="true" *)reg						r_mosi_o				;
(* IOB="true" *)reg						r_miso_i				;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_req <= 1'b0;
		end else begin
			r_lb_req <= LB_REQ;
		end
	end
	
	assign	w_lb_req_pl = ~r_lb_req & LB_REQ;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_rnw  <= 1'b0;
			r_lb_adr  <= 'b0;
			r_lb_wdat <= 'b0;
		end else begin
			if ( w_lb_req_pl ) begin
				r_lb_rnw <= LB_RNW	;
				r_lb_adr <= LB_ADR	;
				r_lb_wdat<= LB_WDAT	;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_main_fsm <= st_Idle;
		end else begin
			case ( r_main_fsm ) 
				st_Idle :
					if ( w_lb_req_pl ) begin
						r_main_fsm <= st_Rnw;
					end
					
				st_Rnw :
					if ( w_sclk_nl ) begin
						r_main_fsm <= st_Addr;
					end
					
				st_Addr :
					if ( w_sclk_nl && w_addr_end ) begin
						r_main_fsm <= st_Data;
					end
					
				st_Data :
					if ( w_sclk_nl && w_data_end ) begin
						r_main_fsm <= st_End;
					end
					
				st_End : 
					if( w_end_end ) begin
						r_main_fsm <= st_Idle;
					end
					
				default :
					r_main_fsm <= st_Idle;
			endcase
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_csn <= 1'b1;
		end else begin
			if ( r_main_fsm == st_Rnw ) begin
				r_csn <= 1'b0;
			end else if ( r_main_fsm <= st_Data && w_data_end && w_sclk_nl ) begin
				r_csn <= 1'b1;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_sclk_gen_flag <= 1'b0;
		end else begin
			if ( r_main_fsm == st_Rnw ) begin
				r_sclk_gen_flag <= 1'b1;
			end else if ( r_main_fsm == st_End ) begin
				r_sclk_gen_flag <= 1'b0;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_sclk_cnt <= 'b0;
		end else begin
			if ( r_sclk_gen_flag ) begin
				r_sclk_cnt <= r_sclk_cnt + 1'b1;
			end else begin
				r_sclk_cnt <= 'b0;
			end
		end
	end
	
	assign	w_sclk_pl = (&r_sclk_cnt[P_SCLK_WIDTH-2:0]) & ~(r_sclk_cnt[P_SCLK_WIDTH-1]);
	assign	w_sclk_nl = (&r_sclk_cnt[P_SCLK_WIDTH-2:0]) &  (r_sclk_cnt[P_SCLK_WIDTH-1]);
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_sclk <= 1'b0;
		end else begin
			if ( w_sclk_pl ) begin
				r_sclk <= 1'b1;
			end else if ( w_sclk_nl ) begin
				r_sclk <= 1'b0;
			end
		end
	end
	
	// Addr Cunter
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_addr_cnt <= 4'b0;
		end else begin
			if ( r_main_fsm == st_Rnw ) begin
				r_lb_addr_cnt <= P_ADDR_WIDTH-1'b1;
			end else if ( r_main_fsm == st_Addr ) begin
				if ( w_sclk_nl ) begin
					r_lb_addr_cnt <= r_lb_addr_cnt - 1'b1;
				end
			end
		end
	end
	
	assign	w_addr_end = ~(|r_lb_addr_cnt);
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_addr_shf <= {P_ADDR_WIDTH{1'b0}};
		end else begin
			if ( r_main_fsm == st_Rnw ) begin
				r_lb_addr_shf <= r_lb_adr;
			end else if ( r_main_fsm == st_Addr ) begin
				if ( w_sclk_nl ) begin
					r_lb_addr_shf <= {r_lb_addr_shf[P_ADDR_WIDTH-2:0],1'b0};
				end
			end
		end
	end
	
	// Data Counter
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_data_cnt <= 4'b0;
		end else begin
			if ( r_main_fsm == st_Rnw ) begin
				r_lb_data_cnt <= P_DATA_WIDTH-1'b1;
			end else if ( r_main_fsm == st_Data ) begin
				if ( w_sclk_nl ) begin
					r_lb_data_cnt <= r_lb_data_cnt - 1'b1;
				end
			end
		end
	end
	
	assign	w_data_end = ~(|r_lb_data_cnt);
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_wdat_shf <= 'b0;
		end else begin
			if ( r_main_fsm == st_Rnw ) begin
				if ( ~r_lb_rnw ) begin
					r_lb_wdat_shf <= {r_lb_wdat};
				end
			end else if ( r_main_fsm == st_Data ) begin
				if ( w_sclk_nl ) begin
					r_lb_wdat_shf <= {r_lb_wdat_shf[P_DATA_WIDTH-2:0],1'b0};
				end
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_mosi <= 1'b0;
		end else begin
			case ( r_main_fsm )  
				st_Rnw  : r_mosi <= r_lb_rnw;
				st_Addr : r_mosi <= r_lb_addr_shf[P_ADDR_WIDTH-1'b1];
				st_Data : r_mosi <= r_lb_wdat_shf[P_DATA_WIDTH-1'b1];
				default : r_mosi <= 1'b0;
			endcase
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_mosi_t <= 1'b0;
		end else begin
			case ( r_main_fsm )  
				st_Rnw  : r_mosi_t <= 1'b0;
				st_Addr : r_mosi_t <= 1'b0;
				st_Data : r_mosi_t <= r_lb_rnw;
				default : r_mosi_t <= 1'b0;
			endcase
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_rdat_shf <= 'b0;
		end else begin
			if ( r_main_fsm == st_Rnw ) begin
				r_lb_rdat_shf <= 'b0;
			end else if ( r_main_fsm == st_Data ) begin
				if ( w_sclk_pl ) begin
					r_lb_rdat_shf <= {r_lb_rdat_shf[P_DATA_WIDTH-2:0],r_miso_i};
				end
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_rdat <= 'b0;
		end else begin
			if ( r_main_fsm == st_End && r_lb_rnw ) begin
				r_lb_rdat <= r_lb_rdat_shf[P_DATA_WIDTH-1:0];
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_end_cnt <= 'b0;
		end else begin
			if ( r_main_fsm == st_End ) begin
				r_end_cnt <= r_end_cnt + 1'b1;
			end else begin
				r_end_cnt <= 'b0;
			end
		end
	end
	
	assign	w_end_end = &r_end_cnt;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_ack <= 1'b0;
		end else begin
			if ( r_main_fsm == st_End && w_end_end) begin
				r_lb_ack <= 1'b1;
			end else begin
				r_lb_ack <= 1'b0;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin  
			r_csn_o  <= 1'b1	;
			r_sclk_o <= 1'b0	;
			r_mosi_o <= 1'b0	;
			r_miso_i <= 1'b0	;
			r_mosi_o_t <= 1'b0	;
		end else begin
			r_csn_o  <= r_csn	;
			r_sclk_o <= r_sclk	;
			r_mosi_o <= r_mosi	;
			r_miso_i <= SPI_SDI ;
			r_mosi_o_t <= r_mosi_t	;
		end
	end
	
	assign	SPI_CSN		= r_csn_o	;
	assign	SPI_SCL		= r_sclk_o	;
	assign	SPI_SDO		= r_mosi_o	;
	assign	SPI_SDO_t	= r_mosi_o_t;
	
	assign	LB_RDAT		= r_lb_rdat	;
	assign	LB_ACK		= r_lb_ack	;
	
endmodule