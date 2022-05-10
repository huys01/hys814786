//============================================================================
// Project  : Multi-DA/AD Board
//----------------------------------------------------------------------------
// File     : DAC_REG.sv
//----------------------------------------------------------------------------
// Function : Register Array About DAC-Chip Config 
//----------------------------------------------------------------------------
// Author   : FREELANCE-FPGA@Shen.h
// Mail     : shen.h@aliyun.com
// Date     : 2021-06-16
//============================================================================
																			
`timescale 1ns / 100ps																	
																						
module DAC_REG (											 							
// Registers Access IF																	
	REG_BUS.slave					REG_BUS_IF					,//Slave				
// DAC Async Control Interface									
	output							SOFT_RST					,//o 		
// DAC Clock 
	input							DAC_CLK						,//i 			
	output							DAC_TST_SEL					,//o 			
	output	[127:0]					DAC_TST_DAT					,//o [127:0]	
	input							DAC_LMFC					,//i 			
	output	[  4:0]					txpostcursor				,//o [4:0]
	output	[  4:0]					txprecursor					,//o [4:0]
	output	[  3:0]					txdiffctrl					,//o [3:0]
	output	[  3:0]					AXI_LITE_ADDR				,//o [3:0]
// AD9173-0/1 Control Interface
	output							ADC_PWR_EN					,//o 
	output	[ 3:0]					PWR_EN_ADC					,//o 
	output							DA0_RESETn					,//o
	output							DA0_TXENABLE				,//o
	output							DA1_RESETn					,//o
	output							DA1_TXENABLE				,//o
	output							DA2_RESETn					,//o
	output							DA2_TXENABLE				,//o
	output							DA3_RESETn					,//o
	output							DA3_TXENABLE				,//o
// AD0173-0/1 Config interface	
	SPI_LB_BUS.master				SPI_LB_IF	[3:0]				 
);
	
	`define							REG_DAC_VERSION			 6'h00	// /R 4 Byte
	`define							REG_DAC_INIT			 6'h01	//W/R 4 Byte
	`define							REG_DAC_CTRL			 6'h02	//W/R 4 Byte
	`define							REG_DAC_ADDR			 6'h03	//W/R 4 Byte
	`define							REG_DAC_WDAT			 6'h04	//W/R 4*4 Byte
	`define							REG_DAC_RDAT			 6'h05	//W/R 4*4 Byte
	`define							REG_RAM_CTRL			 6'h06	
	`define							REG_RAM_ADDR			 6'h07	
	`define							REG_RAM_WDAT			 6'h08	
	`define							REG_RAM_RDAT			 6'h09	
	`define							REG_PHY_DRIVER			 6'h0A	
	`define							REG_AXI_ADDR			 6'h0B	

	`define							RST_DAC_VERSION			32'h20210928	
	`define							RST_DAC_INIT			32'h00	
	`define							RST_DAC_CTRL			32'h00	
	`define							RST_DAC_ADDR			32'h00	
	`define							RST_DAC_WDAT			32'h00	
	`define							RST_PHY_DRIVER			32'h0002020C	
	
	`define							MAX_WRITE_REG_ADDR		 6'h0F
	
	//--------------------------------------------------------------------------
	// Registers Signal name Declaration
	//--------------------------------------------------------------------------
	reg		[31:0]					REG_ARRAY[15:0]				;					
	reg								r_reg_wren					;					
	reg		[ 5:0]					r_reg_wadr					;					
	reg		[31:0]					r_reg_wdat					;					
	wire							w_dac_test_sel				;	
	reg								r_bram_wren					;
	reg		[11:0]					r_bram_wadr					;
	reg		[31:0]					r_bram_wdat					;
	wire	[31:0]					w_bram_rdat					;
	reg		[  3:0]					r_bram_rsel					;
	reg		[  9:0]					r_bram_radr					;
	wire	[127:0]					w_bram_dout					;
	reg		[  3:0]					r_lb_req_pl					;
	reg		[  3:0]					r_lb_req					;
	wire	[ 31:0]					w_REG_DAC_INIT				;
	wire	[ 31:0]					w_REG_DAC_CTRL				;
	wire	[ 31:0]					w_REG_DAC_RDAT				;
			
	//--------------------------------------------------------//
	// Write Registers Handle
	//--------------------------------------------------------//
	
	wire							CLK	= REG_BUS_IF.CLK	;
	wire							RST	= REG_BUS_IF.RST	;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_wren <= 1'b0;
			r_reg_wadr <= 6'h0;
			r_reg_wdat <= 32'h0;
		end else begin
			r_reg_wren <= REG_BUS_IF.WREN; 
			r_reg_wadr <= REG_BUS_IF.WADR[7:2] ;
			r_reg_wdat <= REG_BUS_IF.WDAT;
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			REG_ARRAY[`REG_DAC_INIT		] <= `RST_DAC_INIT	;//
			REG_ARRAY[`REG_DAC_CTRL		] <= `RST_DAC_CTRL	;//
			REG_ARRAY[`REG_PHY_DRIVER	] <= `RST_PHY_DRIVER;//
		end else begin
			if ( r_reg_wren && r_reg_wadr[3:0] <= `MAX_WRITE_REG_ADDR ) begin
				REG_ARRAY[r_reg_wadr[3:0]] <= r_reg_wdat;
			end
		end
	end
	
	assign	AXI_LITE_ADDR = REG_ARRAY[`REG_AXI_ADDR][11: 8];
	assign	txpostcursor= REG_ARRAY[`REG_PHY_DRIVER][20:16];
	assign	txprecursor	= REG_ARRAY[`REG_PHY_DRIVER][12: 8];
	assign	txdiffctrl	= REG_ARRAY[`REG_PHY_DRIVER][ 3: 0];
	
	assign	ADC_PWR_EN	= REG_ARRAY[`REG_DAC_INIT		][30];
	assign	SOFT_RST	= REG_ARRAY[`REG_DAC_INIT		][31];
	assign	PWR_EN_ADC	= REG_ARRAY[`REG_DAC_INIT		][27:24];
	
	assign	DA0_RESETn	= REG_ARRAY[`REG_DAC_INIT		][ 0];
	assign	DA0_EXENABLE= REG_ARRAY[`REG_DAC_INIT		][ 1];
	assign	DA1_RESETn	= REG_ARRAY[`REG_DAC_INIT		][ 4];
	assign	DA1_EXENABLE= REG_ARRAY[`REG_DAC_INIT		][ 5];
	assign	DA2_RESETn	= REG_ARRAY[`REG_DAC_INIT		][ 8];
	assign	DA2_EXENABLE= REG_ARRAY[`REG_DAC_INIT		][ 9];
	assign	DA3_RESETn	= REG_ARRAY[`REG_DAC_INIT		][12];
	assign	DA3_EXENABLE= REG_ARRAY[`REG_DAC_INIT		][13];
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_req_pl <= 4'b0;
		end else begin
			if ( r_reg_wren && r_reg_wadr == `REG_DAC_CTRL ) begin
				r_lb_req_pl <= r_reg_wdat[3:0];
			end else begin
				r_lb_req_pl <= 4'b0;
			end
		end
	end
	
genvar i;
generate
for(i=0;i<4;i=i+1)begin:inst1
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_req[i] <= 1'b0;
		end else begin
			if ( SPI_LB_IF[i].ACK) begin
				r_lb_req[i] <= 1'b0;
			end else if ( r_lb_req_pl[i] ) begin
				r_lb_req[i] <= 1'b1;
			end
		end
	end	
end
endgenerate	
	
	assign	SPI_LB_IF[0].REQ	= r_lb_req[0]						;//o [15:0]
	assign	SPI_LB_IF[0].RNW	= REG_ARRAY[`REG_DAC_CTRL][4]		;//o [ 0:0]
	assign	SPI_LB_IF[0].ADR	= REG_ARRAY[`REG_DAC_ADDR][6:0]		;
	assign	SPI_LB_IF[0].WDAT	= REG_ARRAY[`REG_DAC_WDAT][15:0]	;

	assign	SPI_LB_IF[1].REQ	= r_lb_req[1]						;//o [15:0]
	assign	SPI_LB_IF[1].RNW	= REG_ARRAY[`REG_DAC_CTRL][4]		;//o [ 0:0]
	assign	SPI_LB_IF[1].ADR	= REG_ARRAY[`REG_DAC_ADDR][6:0]		;
	assign	SPI_LB_IF[1].WDAT	= REG_ARRAY[`REG_DAC_WDAT][15:0]	;

	assign	SPI_LB_IF[2].REQ	= r_lb_req[2]						;//o [15:0]
	assign	SPI_LB_IF[2].RNW	= REG_ARRAY[`REG_DAC_CTRL][4]		;//o [ 0:0]
	assign	SPI_LB_IF[2].ADR	= REG_ARRAY[`REG_DAC_ADDR][6:0]		;
	assign	SPI_LB_IF[2].WDAT	= REG_ARRAY[`REG_DAC_WDAT][15:0]	;

	assign	SPI_LB_IF[3].REQ	= r_lb_req[3]						;//o [15:0]
	assign	SPI_LB_IF[3].RNW	= REG_ARRAY[`REG_DAC_CTRL][4]		;//o [ 0:0]
	assign	SPI_LB_IF[3].ADR	= REG_ARRAY[`REG_DAC_ADDR][6:0]		;
	assign	SPI_LB_IF[3].WDAT	= REG_ARRAY[`REG_DAC_WDAT][15:0]	;

	assign	w_REG_DAC_INIT[15: 0] = REG_ARRAY[`REG_DAC_INIT	][15: 0];
	assign	w_REG_DAC_INIT[31:20] = REG_ARRAY[`REG_DAC_INIT	][31:20];	
	
	assign	w_REG_DAC_CTRL[23: 0] = REG_ARRAY[`REG_DAC_CTRL][23: 0]	;
	assign	w_REG_DAC_CTRL[31:28] = REG_ARRAY[`REG_DAC_CTRL][31:28]	;
	assign	w_REG_DAC_CTRL[   24] = r_lb_req[0];
	assign	w_REG_DAC_CTRL[   25] = r_lb_req[1];
	assign	w_REG_DAC_CTRL[   26] = r_lb_req[2];
	assign	w_REG_DAC_CTRL[   27] = r_lb_req[3];
	
	reg		[15:0]	r_REG_DAC_RDAT;
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_REG_DAC_RDAT <= 16'b0;
		end else begin
			if ( SPI_LB_IF[0].ACK ) begin
				r_REG_DAC_RDAT <= SPI_LB_IF[0].RDAT;	
			end else if ( SPI_LB_IF[1].ACK ) begin
				r_REG_DAC_RDAT <= SPI_LB_IF[1].RDAT;	
			end else if ( SPI_LB_IF[2].ACK ) begin
				r_REG_DAC_RDAT <= SPI_LB_IF[2].RDAT;	
			end else if ( SPI_LB_IF[3].ACK ) begin
				r_REG_DAC_RDAT <= SPI_LB_IF[3].RDAT;	
			end 
		end
	end	
	
	assign	w_REG_DAC_RDAT[15: 0] = r_REG_DAC_RDAT;	
	assign	w_REG_DAC_RDAT[31:16] = 16'b0;	
	
	assign	w_dac_test_sel	= REG_ARRAY[`REG_DAC_INIT		][24];
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_bram_wren <= 1'b0;
			r_bram_wadr <= 12'b0;
			r_bram_wdat <= 32'h0;
		end else begin
			if ( r_reg_wren && r_reg_wadr == `REG_RAM_CTRL ) begin
				r_bram_wren <= r_reg_wdat[0];
			end else begin
				r_bram_wren <= 1'b0;
			end
			r_bram_wadr <= REG_ARRAY[`REG_RAM_ADDR][11:0]	;
			r_bram_wdat <= REG_ARRAY[`REG_RAM_WDAT][31:0]	;
		end
	end
	
XPM_TD_BRAM # (
	.P_ADDR_WIDTH_A					(  12					),	
	.P_ADDR_WIDTH_B					(  10					),	
	.P_DATA_WIDTH_A					(  32					),	
	.P_DATA_WIDTH_B					( 128					)	
) U_BRAM_4096x32to128 (
	.clka							( CLK					),
	.wea							( r_bram_wren			),
	.addra							( r_bram_wadr			),
	.dina							( r_bram_wdat			),
	.douta							( w_bram_rdat			),
	.clkb							( DAC_CLK				),
	.web							( 1'b0					),
	.addrb							( r_bram_radr			),
	.dinb							( 128'b0				),
	.doutb							( w_bram_dout			)
);
	
	assign	DAC_TST_SEL = r_bram_rsel[3];
	always @ ( posedge DAC_CLK ) begin
		if ( RST ) begin
			r_bram_rsel <= 4'h0;
		end else begin
			r_bram_rsel <= {r_bram_rsel[2:0],w_dac_test_sel};
		end
	end
	
	reg		r_DAC_LMFC;
	reg		r_bram_rd_start;
	always @ ( posedge DAC_CLK ) begin
		if ( RST ) begin
			r_DAC_LMFC <= 1'b0;
		end else begin
			r_DAC_LMFC <= DAC_LMFC;
		end
	end
	
	always @ ( posedge DAC_CLK ) begin
		if ( RST ) begin
			r_bram_rd_start <= 1'b0;
		end else begin
			if ( r_bram_rsel[2] && DAC_LMFC ) begin
				r_bram_rd_start <= 1'b1;
			end else if ( ~r_bram_rsel[2] )begin
				r_bram_rd_start <= 1'b0;
			end
		end
	end

	always @ ( posedge DAC_CLK ) begin
		if ( RST ) begin
			r_bram_radr <= 10'h0;
		end else begin
			if ( r_bram_radr == (REG_ARRAY[`REG_RAM_ADDR][11:2] - 1'b1) ) begin
				r_bram_radr <= 10'b0;
			end else if ( r_bram_rd_start ) begin
				r_bram_radr <= r_bram_radr + 1'b1;
			end else begin
				r_bram_radr <= 10'b0;
			end
		end
	end
	
	reg		[127:0]		r_dac0_data		;
	reg		[127:0]		r_dac1_data		;
	always @ ( posedge DAC_CLK ) begin
		r_dac0_data <= w_bram_dout[127:  0];
		r_dac1_data <= w_bram_dout[127:  0];
	end
	
	assign	DAC_TST_DAT = {r_dac0_data};

//----------------------------------------------------------------------------//
//Registers Read Handle                                                       //
//----------------------------------------------------------------------------//		
	reg		[31:0]				r_reg_rdat					;
	reg		[31:0]				r_reg_rdat_d0				;
	reg		[ 2:0]				r_reg_rden_shf				;
	reg		[31:0]				r_reg_rdat_d1				;
	reg							r_reg_rvld_d1				;
	always @ ( posedge CLK ) begin
		case ( REG_BUS_IF.RADR[5:2] ) 
			`REG_DAC_VERSION	: r_reg_rdat <= `RST_DAC_VERSION;
			`REG_DAC_INIT		: r_reg_rdat <= w_REG_DAC_INIT;
			`REG_DAC_CTRL		: r_reg_rdat <= w_REG_DAC_CTRL;
			`REG_DAC_ADDR		: r_reg_rdat <= REG_ARRAY[`REG_DAC_ADDR];
			`REG_DAC_WDAT		: r_reg_rdat <= REG_ARRAY[`REG_DAC_WDAT];
			`REG_RAM_CTRL		: r_reg_rdat <= REG_ARRAY[`REG_RAM_CTRL];
			`REG_RAM_WDAT		: r_reg_rdat <= REG_ARRAY[`REG_RAM_WDAT];
			`REG_RAM_ADDR		: r_reg_rdat <= REG_ARRAY[`REG_RAM_ADDR];
			`REG_PHY_DRIVER		: r_reg_rdat <= REG_ARRAY[`REG_PHY_DRIVER];
			`REG_AXI_ADDR		: r_reg_rdat <= REG_ARRAY[`REG_AXI_ADDR];
			`REG_RAM_RDAT		: r_reg_rdat <= w_bram_rdat;
			`REG_DAC_RDAT		: r_reg_rdat <= w_REG_DAC_RDAT;
			default				: r_reg_rdat <= REG_ARRAY[REG_BUS_IF.RADR[5:2]];
		endcase
	end

	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_rden_shf <= 3'b0;
		end else begin
			r_reg_rden_shf <= {r_reg_rden_shf[1:0],REG_BUS_IF.RDEN};
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_rdat_d0 <= 32'b0;
		end else begin
			r_reg_rdat_d0 <= r_reg_rdat;
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_rvld_d1 <= 1'b0;
			r_reg_rdat_d1 <= 32'b0;
		end else begin
			r_reg_rvld_d1 <= ~r_reg_rden_shf[2] & r_reg_rden_shf[1];
			r_reg_rdat_d1 <= r_reg_rdat_d0;
		end
	end
	
	assign	REG_BUS_IF.RDAT = r_reg_rdat_d1;
	assign	REG_BUS_IF.RVLD = r_reg_rvld_d1;
	
endmodule