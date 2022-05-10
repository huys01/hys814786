

module SYS_REG (
// Registers Access IF
	REG_BUS.slave						REG_BUS_IF							,//Slave				
//Soft Reset Output																	
	output								SOFT_RST							,//o	
	output								DB_CLK_EN							,//o 
// Clock Form Board PLL input detect
	input	[ 7:0]						CLK_DET								 //i					
);
	
	assign	CLK = REG_BUS_IF.CLK	;
	assign	RST = REG_BUS_IF.RST	;

	localparam							P_FPGA_VERSION = 32'h2021_1006;

	`define								REG_SYS_VERSION			(6'h00>>2)// /R 4 Byte
	`define								REG_SYS_CTRL			(6'h04>>2)//W/R 4 Byte
	`define								REG_PLL_CLK0			(6'h08>>2)//  R 4 Byte
	`define								REG_PLL_CLK1			(6'h0C>>2)//  R 4 Byte
	`define								REG_PLL_CLK2			(6'h10>>2)//  R 4 Byte
	`define								REG_PLL_CLK3			(6'h14>>2)//  R 4 Byte
	`define								REG_PLL_CLK4			(6'h18>>2)//  R 4 Byte
	`define								REG_PLL_CLK5			(6'h1C>>2)//  R 4 Byte
	`define								REG_PLL_CLK6			(6'h20>>2)//  R 4 Byte
	`define								REG_PLL_CLK7			(6'h24>>2)//  R 4 Byte

	localparam							RST_SYS_VERSION			= P_FPGA_VERSION ;
	localparam							RST_SYS_CTRL			= 32'h00;//W/R 4 Byte
	
	`define								SYS_REG_MAX_ADDR		6'h0F	
	
	//--------------------------------------------------------------------------
	// Registers Signal name Declaration
	//--------------------------------------------------------------------------
	reg		[31:0]				REG_ARRAY[15:0]				;
	reg							r_reg_wren					;
	reg		[ 5:0]				r_reg_wadr					;
	reg		[31:0]				r_reg_wdat					;
	wire	[31:0]				w_clk_period	[0:7]		;	
		
	//--------------------------------------------------------//
	// Write Registers Handle
	//--------------------------------------------------------//
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_wren <= 1'b0;
			r_reg_wadr <= 6'h0;
			r_reg_wdat <= 32'h0;
		end else begin
			r_reg_wren <= REG_BUS_IF.WREN ;
			r_reg_wadr <= REG_BUS_IF.WADR[7:2] ; 
			r_reg_wdat <= REG_BUS_IF.WDAT ; 
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			REG_ARRAY[`REG_SYS_CTRL			] <= RST_SYS_CTRL		;//
		end else begin
			if ( r_reg_wren && r_reg_wadr[3:0] <= `SYS_REG_MAX_ADDR ) begin
				REG_ARRAY[r_reg_wadr[3:0]] <= r_reg_wdat;
			end
		end
	end
	
	assign	SOFT_RST		= REG_ARRAY[`REG_SYS_CTRL ][0];
	assign	DB_CLK_EN		= REG_ARRAY[`REG_SYS_CTRL ][8];
	
//----------------------------------------------------------------------------//
//Registers Read Handle                                                       //
//----------------------------------------------------------------------------//		
	reg		[31:0]				r_reg_rdat						;
	reg		[31:0]				r_reg_rdat_d0					;
	reg		[ 2:0]				r_reg_rden_shf					;
	reg		[31:0]				r_reg_rdat_d1					;
	reg							r_reg_rvld_d1					;
	always @ ( posedge CLK ) begin
		case ( REG_BUS_IF.RADR[5:2] ) 
			`REG_SYS_VERSION	: r_reg_rdat <= P_FPGA_VERSION;
			`REG_SYS_CTRL		: r_reg_rdat <= REG_ARRAY[`REG_SYS_CTRL];
			`REG_PLL_CLK0		: r_reg_rdat <= w_clk_period[0];
			`REG_PLL_CLK1		: r_reg_rdat <= w_clk_period[1];
			`REG_PLL_CLK2		: r_reg_rdat <= w_clk_period[2];
			`REG_PLL_CLK3		: r_reg_rdat <= w_clk_period[3];
			`REG_PLL_CLK4		: r_reg_rdat <= w_clk_period[4];
			`REG_PLL_CLK5		: r_reg_rdat <= w_clk_period[5];
			`REG_PLL_CLK6		: r_reg_rdat <= w_clk_period[6];
			`REG_PLL_CLK7		: r_reg_rdat <= w_clk_period[7];
			default 			: r_reg_rdat <= REG_ARRAY[REG_BUS_IF.RADR[5:2]];
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
			r_reg_rdat_d1 <= 32'b0;
		end else begin
			r_reg_rdat_d1 <= r_reg_rdat_d0;
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_rvld_d1 <= 1'b0;
		end else begin
			r_reg_rvld_d1 <= ~r_reg_rden_shf[2] & r_reg_rden_shf[1];
		end
	end
	
	assign	REG_BUS_IF.RDAT = r_reg_rdat_d1;
	assign	REG_BUS_IF.RVLD = r_reg_rvld_d1;

genvar i;
generate
	for(i=0;i<8;i=i+1)begin:inst
		if (i<6) begin
			CLK_DET0 U_CLK_DET0 (
				.CLK_50M					( CLK				),
				.CLK_DET					( CLK_DET[i]		),
				.CLK_PERIOD					( w_clk_period[i]	)	
			);
		end else begin
			CLK_DET1 U_CLK_DET1 (
				.CLK_50M					( CLK				),
				.CLK_DET					( CLK_DET[i]		),
				.CLK_PERIOD					( w_clk_period[i]	)	
			);
		end
	end
endgenerate

endmodule