
// =============================================================================
// Timescale Define																
// =============================================================================
																				
`timescale 1ns / 1ps															
																				
module SPI_SIF # ( 																
	parameter					P_ADDR_WIDTH	= 8		,						
	parameter					P_DATA_WIDTH	= 8		 						
) (																				
//Clock & Reset																	
	input						CLK						,//i 					
	input						RST						,//i 					
//Local Bus 																	
	output						REG_WREN				,//o 					
	output	[P_ADDR_WIDTH-1:0]	REG_WADR				,//o 					
	output	[P_DATA_WIDTH-1:0]	REG_WDAT				,//o 					
	output						REG_RDEN				,//o 					
	output	[P_ADDR_WIDTH-1:0]	REG_RADR				,//o 					
	input	[P_DATA_WIDTH-1:0]	REG_RDAT				,//i 					
	input						REG_RVLD				,//i 					
//External Port																	
	input						SPI_CSN					,//i 					
	input						SPI_SCL					,//i 					
	input						SPI_SDI					,//i 					
	output						SPI_SDO					 //o 					
);																				
																				
	localparam					st_Idle	= 5'b00001		;
	localparam					st_Rnw	= 5'b00010		;
	localparam					st_Addr	= 5'b00100		;
	localparam					st_Data	= 5'b01000		;
	localparam					st_Wait	= 5'b10000		;
	
(* IOB="true" *)reg				r_spi_csn_iob			;
(* IOB="true" *)reg				r_spi_scl_iob			;
(* IOB="true" *)reg				r_spi_sdi_iob			;
(* IOB="true" *)reg				r_spi_sdo_iob			;
	reg		[ 1:0]				r_spi_csn_shf			;
	reg		[ 1:0]				r_spi_scl_shf			;
	reg		[ 1:0]				r_spi_sdi_shf			;
	wire						w_spi_csn_nl			;
	wire						w_spi_scl_pl			;
	wire						w_spi_scl_nl			;
	wire						w_spi_enable			;
	reg		[ 4:0]				r_main_fsm				;
	reg							r_lb_rnw				;
	reg		[P_ADDR_WIDTH-1:0]	r_lb_addr				;
	reg							r_reg_rden				;
	reg		[ 3:0]				r_addr_cnt				;
	wire						w_addr_end				;
	reg		[P_ADDR_WIDTH-1:0]	r_reg_radr				;
	reg		[P_DATA_WIDTH-1:0]	r_lb_data				;
	reg		[ 4:0]				r_data_cnt				;
	wire						w_data_end				;
	reg							r_reg_wren				;
	reg		[P_ADDR_WIDTH-1:0]	r_reg_wadr				;
	reg		[P_DATA_WIDTH-1:0]	r_reg_wdat				;
	reg		[P_DATA_WIDTH-1:0]	r_reg_rdat				;
	reg							r_spi_sdo				;
	reg							r_reg_rden_o			;
	reg							r_reg_wren_o			;
	reg		[ 2:0]				r_wait_cnt				;
	wire						w_wait_end				;	
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_spi_csn_iob <= 1'b0;
			r_spi_scl_iob <= 1'b0;
			r_spi_sdi_iob <= 1'b0;
		end else begin
			r_spi_csn_iob <= SPI_CSN;
			r_spi_scl_iob <= SPI_SCL;
			r_spi_sdi_iob <= SPI_SDI;
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_spi_csn_shf <= 2'b0;
			r_spi_scl_shf <= 2'b0;
			r_spi_sdi_shf <= 2'b0;
		end else begin
			r_spi_csn_shf <= {r_spi_csn_shf[0],r_spi_csn_iob};
			r_spi_scl_shf <= {r_spi_scl_shf[0],r_spi_scl_iob};
			r_spi_sdi_shf <= {r_spi_sdi_shf[0],r_spi_sdi_iob};
		end
	end
	
	assign	w_spi_csn_nl = ~r_spi_csn_shf[0] & r_spi_csn_shf[1];
	assign	w_spi_scl_pl = ~r_spi_scl_shf[1] & r_spi_scl_shf[0];
	assign	w_spi_scl_nl = ~r_spi_scl_shf[0] & r_spi_scl_shf[1];
	assign	w_spi_enable = ~r_spi_csn_shf[0];
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_main_fsm <= st_Idle;
		end else begin
			case ( r_main_fsm ) 
				st_Idle :
					if ( w_spi_csn_nl ) begin
						r_main_fsm <= st_Rnw;
					end
					
				st_Rnw :
					if ( w_spi_enable ) begin
						if ( w_spi_scl_pl ) begin
							r_main_fsm <= st_Addr;
						end
					end else begin
						r_main_fsm <= st_Idle;
					end
					
				st_Addr :
					if ( w_spi_enable ) begin
						if ( w_spi_scl_pl && w_addr_end ) begin
							r_main_fsm <= st_Data;
						end
					end else begin
						r_main_fsm <= st_Idle;
					end
					
				st_Data :
					if ( w_spi_enable ) begin
						if ( w_spi_scl_pl && w_data_end ) begin
							r_main_fsm <= st_Wait;
						end
					end else begin
						r_main_fsm <= st_Idle;
					end
					
				st_Wait : 
					if ( w_wait_end ) begin
						r_main_fsm <= st_Idle;
					end
					
				default :
					r_main_fsm <= st_Idle;
			endcase
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_rnw <= 1'b0;
		end else begin
			if ( r_main_fsm == st_Rnw && w_spi_scl_pl ) begin
				r_lb_rnw <= r_spi_sdi_shf[0];
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_addr <= {P_ADDR_WIDTH{1'b0}};
		end else begin
			if ( r_main_fsm == st_Addr && w_spi_scl_pl ) begin
				r_lb_addr[P_ADDR_WIDTH-1:1] <= r_lb_addr[P_ADDR_WIDTH-2:0];
				r_lb_addr[0] <= r_spi_sdi_shf[0];
			end else if ( r_main_fsm == st_Idle ) begin
				r_lb_addr <= {P_ADDR_WIDTH{1'b0}};
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_rden <= 1'b0;
		end else begin
			if ( ~r_lb_rnw && r_main_fsm == st_Addr && w_spi_scl_pl ) begin
				r_reg_rden <= w_addr_end ;
			end else begin
				r_reg_rden <= 1'b0;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_addr_cnt <= 4'b0;
		end else begin
			if ( r_main_fsm == st_Addr ) begin
				if ( w_spi_scl_pl ) begin
					r_addr_cnt <= r_addr_cnt + 1'b1;
				end
			end else begin
				r_addr_cnt <= 4'b0;
			end
		end
	end
	
	assign	w_addr_end = ( r_addr_cnt == P_ADDR_WIDTH-1'b1 ) ? 1'b1:1'b0;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_radr <= {P_ADDR_WIDTH{1'b0}};
		end else begin
			if ( r_reg_rden ) begin
				r_reg_radr <= r_lb_addr;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_data <= {P_DATA_WIDTH{1'b0}};
		end else begin
			if ( r_main_fsm == st_Data && w_spi_scl_pl ) begin
				r_lb_data[P_DATA_WIDTH-1:1] <= r_lb_data[P_DATA_WIDTH-2:0];
				r_lb_data[0] <= r_spi_sdi_shf[0];
			end else if ( r_main_fsm == st_Idle ) begin
				r_lb_data <= {P_DATA_WIDTH{1'b0}};
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_data_cnt <= 4'b0;
		end else begin
			if ( r_main_fsm == st_Data ) begin
				if ( w_spi_scl_pl ) begin
					r_data_cnt <= r_data_cnt + 1'b1;
				end
			end else begin
				r_data_cnt <= 4'b0;
			end
		end
	end
	
	assign	w_data_end = ( r_data_cnt == P_DATA_WIDTH-1'b1 ) ? 1'b1:1'b0;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_wren <= 1'b0;
		end else begin
			if ( r_lb_rnw && r_main_fsm == st_Data && w_spi_scl_pl ) begin
				r_reg_wren <= w_data_end ;
			end else begin
				r_reg_wren <= 1'b0;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_wadr <= {P_ADDR_WIDTH{1'b0}};
			r_reg_wdat <= {P_DATA_WIDTH{1'b0}};
		end else begin
			if ( r_reg_wren ) begin
				r_reg_wadr <= r_lb_addr;
				r_reg_wdat <= r_lb_data;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_rdat <= {P_DATA_WIDTH{1'b0}};
		end else begin
			if ( REG_RVLD ) begin
				r_reg_rdat <= REG_RDAT;
			end else if ( ~r_lb_rnw && r_main_fsm == st_Data ) begin
				if ( w_spi_scl_pl ) begin
					r_reg_rdat <= {r_reg_rdat[P_DATA_WIDTH-2:0],1'b0};
				end
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_spi_sdo <= 1'b0;
		end else begin
//			if ( w_spi_scl_pl ) begin
				r_spi_sdo <= r_reg_rdat[P_DATA_WIDTH-1];
//			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_spi_sdo_iob <= 1'b0;
		end else begin
			r_spi_sdo_iob <= r_spi_sdo;
		end
	end
	
	assign	SPI_SDO = r_spi_sdo_iob;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_rden_o <= 1'b0;
			r_reg_wren_o <= 1'b0;
		end else begin
			r_reg_rden_o <= r_reg_rden;
			r_reg_wren_o <= r_reg_wren;
		end
	end
	
	assign	REG_WREN = r_reg_wren_o;
	assign	REG_RDEN = r_reg_rden_o;
	assign	REG_WADR = r_reg_wadr;
	assign	REG_WDAT = r_reg_wdat;
	assign	REG_RADR = r_reg_radr;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_wait_cnt <= 3'b0;
		end else begin
			if ( r_main_fsm == st_Wait ) begin
				r_wait_cnt <= r_wait_cnt + 1'b1;
			end else begin
				r_wait_cnt <= 3'b0;
			end
		end
	end
	
	assign	w_wait_end = &r_wait_cnt;
	
endmodule