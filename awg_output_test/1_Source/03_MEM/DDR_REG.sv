// =============================================================================
// file name	: DDR_REG.sv													
// module		: DDR_REG														
// =============================================================================
// function		: DDR Test Register Array  Module					
// -----------------------------------------------------------------------------
// updata history:																
// -----------------------------------------------------------------------------
// rev.level	Date			Coded By			contents					
// v0.0.1		2020/07/08		IR.Shenh			create new					
// -----------------------------------------------------------------------------
// Update Details :																
// -----------------------------------------------------------------------------
// Date			Contents Detail													
// =============================================================================
// End revision																	
// =============================================================================
																				
// =============================================================================
// Timescale Define																
// =============================================================================
																				
`timescale 1ns / 1ps															
																				
module DDR_REG (											 					
//Clock & Reset																	
	input							CLK							,//i 			
	input							RST							,//i 			
// Registers Access IF															
	REG_BUS.slave					REG_BUS_IF					,//Slave		
// DDR3 Init Done IF															
	input							DDR4_0_INIT_DONE			,//i 			
	input							DDR4_1_INIT_DONE			,//i 			
// DDR TEST Interface															
	DDR_TEST_BUS.master				DDR_TEST_IF0				,//				
	DDR_TEST_BUS.master				DDR_TEST_IF1				,//				
	DDR_TEST_BUS.master				DDR_TEST_IF2				,//				
	DDR_TEST_BUS.master				DDR_TEST_IF3				 //				
);
	
	`define							REG_FPGA_VER			6'h00				
	`define							REG_DDR_STATUS			6'h01				
	`define							REG_DDR_0TEST			6'h04	//W/R 4 Byte
	`define							REG_DDR_0SIZE			6'h05	//W/R 4 Byte
	`define							REG_DDR_0ADDR			6'h06	//W/R 4 Byte
	`define							REG_DDR_0WTIME			6'h07	//  R 4 Byte
	`define							REG_DDR_0RTIME			6'h08	//  R 4 Byte
	`define							REG_DDR_1TEST			6'h09	//W/R 4 Byte
	`define							REG_DDR_1SIZE			6'h0A	//W/R 4 Byte
	`define							REG_DDR_1ADDR			6'h0B	//W/R 4 Byte
	`define							REG_DDR_1WTIME			6'h0C	//  R 4 Byte
	`define							REG_DDR_1RTIME			6'h0D	//  R 4 Byte
	`define							REG_DDR_2TEST			6'h0E	//W/R 4 Byte
	`define							REG_DDR_2SIZE			6'h0F	//W/R 4 Byte
	`define							REG_DDR_2ADDR			6'h10	//W/R 4 Byte
	`define							REG_DDR_2WTIME			6'h11	//  R 4 Byte
	`define							REG_DDR_2RTIME			6'h12	//  R 4 Byte
	`define							REG_DDR_3TEST			6'h13	//W/R 4 Byte
	`define							REG_DDR_3SIZE			6'h14	//W/R 4 Byte
	`define							REG_DDR_3ADDR			6'h15	//W/R 4 Byte
	`define							REG_DDR_3WTIME			6'h16	//  R 4 Byte
	`define							REG_DDR_3RTIME			6'h17	//  R 4 Byte

	`define							RST_FPGA_VER			32'h20210808
	`define							RST_DDR_0TEST			32'h00	
	`define							RST_DDR_0SIZE			32'h00	
	`define							RST_DDR_0ADDR			32'h00	
	`define							RST_DDR_1TEST			32'h00	
	`define							RST_DDR_1SIZE			32'h00	
	`define							RST_DDR_1ADDR			32'h00	
	`define							RST_DDR_2TEST			32'h00	
	`define							RST_DDR_2SIZE			32'h00	
	`define							RST_DDR_2ADDR			32'h00	
	`define							RST_DDR_3TEST			32'h00	
	`define							RST_DDR_3SIZE			32'h00	
	`define							RST_DDR_3ADDR			32'h00	
	
	`define							DDR_REG_MAX_ADDR		 6'h1F
	
	//--------------------------------------------------------------------------
	// Registers Signal name Declaration
	//--------------------------------------------------------------------------
	reg		[31:0]					REG_ARRAY[63:0]				;					
	reg								r_reg_wren					;					
	reg		[ 5:0]					r_reg_wadr					;					
	reg		[31:0]					r_reg_wdat					;					
		
	//--------------------------------------------------------//
	// Write Registers Handle
	//--------------------------------------------------------//
	
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
			REG_ARRAY[`REG_DDR_0TEST		] <= `RST_DDR_0TEST		;//
			REG_ARRAY[`REG_DDR_0SIZE		] <= `RST_DDR_0SIZE		;//
			REG_ARRAY[`REG_DDR_0ADDR		] <= `RST_DDR_0ADDR		;//
			REG_ARRAY[`REG_DDR_1TEST		] <= `RST_DDR_1TEST		;//
			REG_ARRAY[`REG_DDR_1SIZE		] <= `RST_DDR_1SIZE		;//
			REG_ARRAY[`REG_DDR_1ADDR		] <= `RST_DDR_1ADDR		;//
			REG_ARRAY[`REG_DDR_2TEST		] <= `RST_DDR_2TEST		;//
			REG_ARRAY[`REG_DDR_2SIZE		] <= `RST_DDR_2SIZE		;//
			REG_ARRAY[`REG_DDR_2ADDR		] <= `RST_DDR_2ADDR		;//
			REG_ARRAY[`REG_DDR_3TEST		] <= `RST_DDR_3TEST		;//
			REG_ARRAY[`REG_DDR_3SIZE		] <= `RST_DDR_3SIZE		;//
			REG_ARRAY[`REG_DDR_3ADDR		] <= `RST_DDR_3ADDR		;//
		end else begin
			if ( r_reg_wren && r_reg_wadr <= `DDR_REG_MAX_ADDR ) begin
				REG_ARRAY[r_reg_wadr] <= r_reg_wdat;
			end
		end
	end
	
	assign	DDR_TEST_IF0.DDR_TEST		= REG_ARRAY[`REG_DDR_0TEST		][0];
	assign	DDR_TEST_IF1.DDR_TEST		= REG_ARRAY[`REG_DDR_1TEST		][0];
	assign	DDR_TEST_IF2.DDR_TEST		= REG_ARRAY[`REG_DDR_2TEST		][0];
	assign	DDR_TEST_IF3.DDR_TEST		= REG_ARRAY[`REG_DDR_3TEST		][0];
	
	assign	DDR_TEST_IF0.DDR_TEST_SIZE	= REG_ARRAY[`REG_DDR_0SIZE		]; 
	assign	DDR_TEST_IF0.DDR_TEST_ADDR	= REG_ARRAY[`REG_DDR_0ADDR		]; 
	assign	DDR_TEST_IF1.DDR_TEST_SIZE	= REG_ARRAY[`REG_DDR_1SIZE		]; 
	assign	DDR_TEST_IF1.DDR_TEST_ADDR	= REG_ARRAY[`REG_DDR_1ADDR		]; 
	assign	DDR_TEST_IF2.DDR_TEST_SIZE	= REG_ARRAY[`REG_DDR_2SIZE		]; 
	assign	DDR_TEST_IF2.DDR_TEST_ADDR	= REG_ARRAY[`REG_DDR_2ADDR		]; 
	assign	DDR_TEST_IF3.DDR_TEST_SIZE	= REG_ARRAY[`REG_DDR_3SIZE		]; 
	assign	DDR_TEST_IF3.DDR_TEST_ADDR	= REG_ARRAY[`REG_DDR_3ADDR		]; 
	
	reg		[31:0]		r_REG_DDR_0TEST;
	reg		[31:0]		r_REG_DDR_1TEST;
	reg		[31:0]		r_REG_DDR_2TEST;
	reg		[31:0]		r_REG_DDR_3TEST;
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_REG_DDR_0TEST <= 32'h0;
			r_REG_DDR_1TEST <= 32'h0;
			r_REG_DDR_2TEST <= 32'h0;
			r_REG_DDR_3TEST <= 32'h0;
		end else begin
			r_REG_DDR_0TEST[    0] <= REG_ARRAY[`REG_DDR_0TEST		][0];
			r_REG_DDR_0TEST[ 5: 4] <= DDR_TEST_IF0.DDR_TEST_BUSY;
			r_REG_DDR_0TEST[    8] <= DDR_TEST_IF0.DDR_TEST_ERR;
			r_REG_DDR_0TEST[13:12] <= DDR_TEST_IF0.DDR_TEST_CASE;
			r_REG_DDR_1TEST[    0] <= REG_ARRAY[`REG_DDR_1TEST		][0];
			r_REG_DDR_1TEST[ 5: 4] <= DDR_TEST_IF1.DDR_TEST_BUSY;
			r_REG_DDR_1TEST[    8] <= DDR_TEST_IF1.DDR_TEST_ERR;
			r_REG_DDR_1TEST[13:12] <= DDR_TEST_IF1.DDR_TEST_CASE;
			r_REG_DDR_2TEST[    0] <= REG_ARRAY[`REG_DDR_2TEST		][0];
			r_REG_DDR_2TEST[ 5: 4] <= DDR_TEST_IF2.DDR_TEST_BUSY;
			r_REG_DDR_2TEST[    8] <= DDR_TEST_IF2.DDR_TEST_ERR;
			r_REG_DDR_2TEST[13:12] <= DDR_TEST_IF2.DDR_TEST_CASE;
			r_REG_DDR_3TEST[    0] <= REG_ARRAY[`REG_DDR_3TEST		][0];
			r_REG_DDR_3TEST[ 5: 4] <= DDR_TEST_IF3.DDR_TEST_BUSY;
			r_REG_DDR_3TEST[    8] <= DDR_TEST_IF3.DDR_TEST_ERR;
			r_REG_DDR_3TEST[13:12] <= DDR_TEST_IF3.DDR_TEST_CASE;
		end 
	end
	
//----------------------------------------------------------------------------//
//Registers Read Handle                                                       //
//----------------------------------------------------------------------------//		
	reg		[31:0]				r_reg_rdat					;
	reg		[31:0]				r_reg_rdat_d0				;
	reg		[ 2:0]				r_reg_rden_shf				;
	reg		[31:0]				r_reg_rdat_d1				;
	reg							r_reg_rvld_d1				;
	always @ ( posedge CLK ) begin
		case ( REG_BUS_IF.RADR[7:2] ) 
			`REG_FPGA_VER		: r_reg_rdat <= `RST_FPGA_VER;
			`REG_DDR_STATUS		: r_reg_rdat <= {30'b0,DDR4_1_INIT_DONE,DDR4_0_INIT_DONE};
			`REG_DDR_0TEST		: r_reg_rdat <= r_REG_DDR_0TEST;
			`REG_DDR_0SIZE		: r_reg_rdat <= REG_ARRAY[`REG_DDR_0SIZE	] ;
			`REG_DDR_0ADDR		: r_reg_rdat <= REG_ARRAY[`REG_DDR_0ADDR	] ;
			`REG_DDR_0WTIME		: r_reg_rdat <= DDR_TEST_IF0.DDR_TEST_WTIME;
			`REG_DDR_0RTIME		: r_reg_rdat <= DDR_TEST_IF0.DDR_TEST_RTIME;
			`REG_DDR_1TEST		: r_reg_rdat <= r_REG_DDR_1TEST;
			`REG_DDR_1SIZE		: r_reg_rdat <= REG_ARRAY[`REG_DDR_1SIZE	] ;
			`REG_DDR_1ADDR		: r_reg_rdat <= REG_ARRAY[`REG_DDR_1ADDR	] ;
			`REG_DDR_1WTIME		: r_reg_rdat <= DDR_TEST_IF1.DDR_TEST_WTIME;
			`REG_DDR_1RTIME		: r_reg_rdat <= DDR_TEST_IF1.DDR_TEST_RTIME;
			`REG_DDR_2TEST		: r_reg_rdat <= r_REG_DDR_2TEST;
			`REG_DDR_2SIZE		: r_reg_rdat <= REG_ARRAY[`REG_DDR_2SIZE	] ;
			`REG_DDR_2ADDR		: r_reg_rdat <= REG_ARRAY[`REG_DDR_2ADDR	] ;
			`REG_DDR_2WTIME		: r_reg_rdat <= DDR_TEST_IF2.DDR_TEST_WTIME;
			`REG_DDR_2RTIME		: r_reg_rdat <= DDR_TEST_IF2.DDR_TEST_RTIME;
			`REG_DDR_3TEST		: r_reg_rdat <= r_REG_DDR_3TEST;
			`REG_DDR_3SIZE		: r_reg_rdat <= REG_ARRAY[`REG_DDR_3SIZE	] ;
			`REG_DDR_3ADDR		: r_reg_rdat <= REG_ARRAY[`REG_DDR_3ADDR	] ;
			`REG_DDR_3WTIME		: r_reg_rdat <= DDR_TEST_IF3.DDR_TEST_WTIME;
			`REG_DDR_3RTIME		: r_reg_rdat <= DDR_TEST_IF3.DDR_TEST_RTIME;
			default				: r_reg_rdat <= REG_ARRAY[REG_BUS_IF.RADR[7:2]];
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