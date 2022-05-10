module IO_REG (
// Registers Access IF
	REG_BUS.slave						REG_BUS_IF							,//Slave		
// VPX-Interface
	output	[ 4:0]						VPX_GA								,//o [ 4:0]
	output								VPX_GAP								,//o 		
// T.emperature IO
	input	[31:0]						TEMP_DATA							,//i 
// VPX-P2 Interface(Bank24)
	output								VPX_ID_DIR							,//o 		
	output								VPX_CMD_DIR							,//o 		
	output								VPX_DCO_DIR							,//o 		
///With FPGA2 Interface	
	input	[31:0]						GPIO0_1V8_I_CNT						,//i [31:0]
	input	[31:0]						GPIO1_1V8_I_CNT0					,//i [31:0]
	input	[31:0]						GPIO1_1V8_I_CNT1					,//i [31:0]
	input	[31:0]						GPIO1_1V8_I_CNT2					,//i [31:0]
	input	[31:0]						GPIO1_1V8_I_CNT3					,//i [31:0]
	input	[31:0]						LVDS_I_CNT							,//i [31:0]
	input	[31:0]						LVDS_I_CNT0							,//i [31:0]
	input	[31:0]						LVDS_I_CNT1							,//i [31:0]
	input	[31:0]						LVDS_I_CNT2							,//i [31:0]
	input	[31:0]						LVDS_I_CNT3							,//i [31:0]
	input	[31:0]						LVDS_I_CNT4							 //i [31:0]
);
	wire	CLK = REG_BUS_IF.CLK	;
	wire	RST = REG_BUS_IF.RST	;
	
	`define								REG_IO_VER			4'h0
	`define								REG_GA_INIT			4'h1
	`define								REG_TEMP_DATA		4'h2
	`define								REG_GPIO0_I_CNT		4'h3
	`define								REG_GPIO1_I_CNT0	4'h4
	`define								REG_GPIO1_I_CNT1	4'h5
	`define								REG_GPIO1_I_CNT2	4'h6
	`define								REG_GPIO1_I_CNT3	4'h7
	`define								REG_LVDS_I_CNT		4'h8
	`define								REG_LVDS_I_CNT0		4'h9
	`define								REG_LVDS_I_CNT1		4'hA
	`define								REG_LVDS_I_CNT2		4'hB
	`define								REG_LVDS_I_CNT3		4'hC
	`define								REG_LVDS_I_CNT4		4'hD

	`define								RST_IO_VER			32'h20210822
	`define								RST_GA_INIT			32'h80000001	
	`define								RST_TEMP_DATA		32'h00000000	
	
	`define								IO_REG_MAX_REG_ADDR	 4'hF
	
	//--------------------------------------------------------------------------
	// Registers Signal name Declaration
	//--------------------------------------------------------------------------
	reg		[31:0]					REG_ARRAY[7:0]				;					
	reg								r_reg_wren					;					
	reg		[ 5:0]					r_reg_wadr					;					
	reg		[31:0]					r_reg_wdat					;					
	reg								r_trig						;
	reg								r_busy						;
	reg		[31:0]					r_wdata						;
	reg		[31:0]					r_rdata						;
	reg								r_USR_trig					;
	reg		[ 7:0]					r_USR_wdata					;
	
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
			REG_ARRAY[`REG_GA_INIT] <= `RST_GA_INIT;
		end else begin
			if ( r_reg_wren && r_reg_wadr <= `IO_REG_MAX_REG_ADDR ) begin
				REG_ARRAY[r_reg_wadr[3:0]] <= r_reg_wdat;
			end
		end
	end
	
	reg		[ 7:0]		r_ga_cnt		;
	reg					r_ga_pwm=1'b0	;
	always @ ( posedge CLK ) begin
		if ( r_ga_cnt == REG_ARRAY[`REG_GA_INIT][31:24] ) begin
			r_ga_cnt <= 8'h0;
			r_ga_pwm <=~r_ga_pwm;
		end else begin
			r_ga_cnt <= r_ga_cnt + 1'b1;
		end
	end
	
	assign	VPX_GA[0] = ( REG_ARRAY[`REG_GA_INIT][0] ) ? r_ga_pwm : REG_ARRAY[`REG_GA_INIT][ 8];
	assign	VPX_GA[1] = ( REG_ARRAY[`REG_GA_INIT][0] ) ? r_ga_pwm : REG_ARRAY[`REG_GA_INIT][ 9];
	assign	VPX_GA[2] = ( REG_ARRAY[`REG_GA_INIT][0] ) ? r_ga_pwm : REG_ARRAY[`REG_GA_INIT][10];
	assign	VPX_GA[3] = ( REG_ARRAY[`REG_GA_INIT][0] ) ? r_ga_pwm : REG_ARRAY[`REG_GA_INIT][11];
	assign	VPX_GA[4] = ( REG_ARRAY[`REG_GA_INIT][0] ) ? r_ga_pwm : REG_ARRAY[`REG_GA_INIT][12];
	assign	VPX_GAP   = ( REG_ARRAY[`REG_GA_INIT][0] ) ? r_ga_pwm : REG_ARRAY[`REG_GA_INIT][13];
	
	assign	VPX_ID_DIR	= REG_ARRAY[`REG_GA_INIT][16];
	assign	VPX_CMD_DIR	= REG_ARRAY[`REG_GA_INIT][17];
	assign	VPX_DCO_DIR	= REG_ARRAY[`REG_GA_INIT][18];
	
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
			`REG_IO_VER			: r_reg_rdat <= `RST_IO_VER;
			`REG_GA_INIT		: r_reg_rdat <= REG_ARRAY[`REG_GA_INIT];
			`REG_TEMP_DATA		: r_reg_rdat <= TEMP_DATA;
			`REG_GPIO0_I_CNT	: r_reg_rdat <= GPIO0_1V8_I_CNT		;
			`REG_GPIO1_I_CNT0	: r_reg_rdat <= GPIO1_1V8_I_CNT0	;
			`REG_GPIO1_I_CNT1	: r_reg_rdat <= GPIO1_1V8_I_CNT1	;
			`REG_GPIO1_I_CNT2	: r_reg_rdat <= GPIO1_1V8_I_CNT2	;
			`REG_GPIO1_I_CNT3	: r_reg_rdat <= GPIO1_1V8_I_CNT3	;
			`REG_LVDS_I_CNT		: r_reg_rdat <= LVDS_I_CNT			;
			`REG_LVDS_I_CNT0	: r_reg_rdat <= LVDS_I_CNT0			;
			`REG_LVDS_I_CNT1	: r_reg_rdat <= LVDS_I_CNT1			;
			`REG_LVDS_I_CNT2	: r_reg_rdat <= LVDS_I_CNT2			;
			`REG_LVDS_I_CNT3	: r_reg_rdat <= LVDS_I_CNT3			;
			`REG_LVDS_I_CNT4	: r_reg_rdat <= LVDS_I_CNT4			;
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