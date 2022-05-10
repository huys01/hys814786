module HMC7044_REG (											 							
// Registers Access IF																	
	REG_BUS.slave						REG_BUS_IF							,//Slave				
//HMC7044 Config & Control Interface
	output								HMC7044_PWR_EN						,//o 
	output								HMC7044_SYNC						,//o 
	output								HMC7044_RESET						,//o 
// PLL Interface Check																	
	output								LB_REQ								,//o 					
	output								LB_RNW								,//o 					
	output	[14:0]						LB_ADR								,//o [14:0]				
	output	[ 7:0]						LB_WDAT								,//o 					
	input	[ 7:0]						LB_RDAT								,//i 					
	input								LB_ACK								 //i  					
);

	assign	CLK = REG_BUS_IF.CLK	;
	assign	RST = REG_BUS_IF.RST	;
	
	`define								REG_PLL_VER							4'h0	//W/R 4 Byte
	`define								REG_PLL_INIT						4'h1	//W/R 4 Byte
	`define								REG_PLL_CTRL						4'h2	//W/R 4 Byte
	`define								REG_PLL_ADDR						4'h3	//W/R 4 Byte
	`define								REG_PLL_WDAT						4'h4	//W/R 4*4 Byte
	`define								REG_PLL_RDAT						4'h5	//W/R 4*4 Byte

	`define								RST_PLL_VER							32'h20210721	
	`define								RST_PLL_INIT						32'h00	
	`define								RST_PLL_CTRL						32'h00	
	`define								RST_PLL_ADDR						32'h00	
	`define								RST_PLL_WDAT						32'h00	
	
	`define								MAX_HMC7044_REG						4'hF
	
	//--------------------------------------------------------------------------
	// Registers Signal name Declaration
	//--------------------------------------------------------------------------
	reg		[31:0]						REG_ARRAY[15:0]						;
	reg									r_reg_wren							;
	reg		[ 5:0]						r_reg_wadr							;
	reg		[31:0]						r_reg_wdat							;
	reg									r_lb_req							;
		
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
			REG_ARRAY[`REG_PLL_INIT		] <= `RST_PLL_INIT	;//
			REG_ARRAY[`REG_PLL_CTRL		] <= `RST_PLL_CTRL	;//
			REG_ARRAY[`REG_PLL_ADDR		] <= `RST_PLL_ADDR	;//
		end else begin
			if ( r_reg_wren && r_reg_wadr[3:0] <= `MAX_HMC7044_REG ) begin
				REG_ARRAY[r_reg_wadr[3:0]] <= r_reg_wdat;
			end
		end
	end
	
	assign	HMC7044_PWR_EN		= REG_ARRAY[`REG_PLL_INIT		][0];
	assign	HMC7044_RESET		= REG_ARRAY[`REG_PLL_INIT		][8];
	assign	HMC7044_SYNC		= REG_ARRAY[`REG_PLL_INIT		][16];
	
	reg		r_lb_req_pl;
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_req_pl <= 1'b0;
		end else begin
			if ( r_reg_wren && r_reg_wadr == `REG_PLL_CTRL ) begin
				r_lb_req_pl <= r_reg_wdat[0];
			end else begin
				r_lb_req_pl <= 1'b0;
			end
		end
	end

	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_req <= 1'b0;
		end else begin
			if ( LB_ACK ) begin
				r_lb_req <= 1'b0;
			end else if ( r_lb_req_pl ) begin
				r_lb_req <= 1'b1;
			end
		end
	end
	
	assign	LB_REQ		= r_lb_req							;//o [15:0]
	assign	LB_RNW		= REG_ARRAY[`REG_PLL_CTRL][8]		;//o [ 0:0]
	assign	LB_ADR		= REG_ARRAY[`REG_PLL_ADDR][14:0]	;
	assign	LB_WDAT		= REG_ARRAY[`REG_PLL_WDAT][ 7:0]	;
	
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
			`REG_PLL_VER		: r_reg_rdat <= `RST_PLL_VER;
			`REG_PLL_INIT		: r_reg_rdat <= REG_ARRAY[`REG_PLL_INIT];
			`REG_PLL_CTRL		: r_reg_rdat <= {r_lb_req,REG_ARRAY[`REG_PLL_CTRL][30:0]};
			`REG_PLL_ADDR		: r_reg_rdat <= REG_ARRAY[`REG_PLL_ADDR];
			`REG_PLL_WDAT		: r_reg_rdat <= REG_ARRAY[`REG_PLL_WDAT];
			`REG_PLL_RDAT		: r_reg_rdat <= {24'b0,LB_RDAT};
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