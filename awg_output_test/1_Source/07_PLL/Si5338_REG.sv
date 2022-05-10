module Si5338_REG (											 					
// Registers Access IF															
	REG_BUS.slave					REG_BUS_IF					,//Slave		
//user interface 
	output							USR_trig					,	//I2C transmit trig pulse,Active High 
	output							USR_rnw						,	//I2C transmit direction, 1:Read/0:Write
	output	[ 7:0]					USR_wrcyc					,	//I2C Write cycle
	output	[ 7:0]					USR_rdcyc					,	//I2C Read cycle
	output	[ 7:0]					USR_deivce_id				,	//I2C transmit Device ID
	output	[15:0]					USR_reg_addr				,	//I2C transmit Register Address
	input							USR_wvld					,	//I2C transmit write fetch signal 
	output	[ 7:0]					USR_wdata					,	//I2C transmit write data
	input							USR_rvld					,	//I2C transmit read data valid pulse 
	input	[ 7:0]					USR_rdata					,	//I2C transmit read data
	input							USR_error					,	//I2C status feedback,1:No Ack(abnormal)/0:Ack(normal)
	input							USR_end							//I2C transmit end signal 
);
	wire	CLK = REG_BUS_IF.CLK	;
	wire	RST = REG_BUS_IF.RST	;
	
	`define							REG_Si5338_VER			4'h0
	`define							REG_Si5338_INIT			4'h1
	`define							REG_Si5338_CTRL			4'h2
	`define							REG_Si5338_PARA			4'h3
	`define							REG_Si5338_WDAT			4'h4
	`define							REG_Si5338_RDAT			4'h5

	`define							RST_Si5338_VER			32'h20210806
	`define							RST_Si5338_INIT			32'h00000000	
	`define							RST_Si5338_CTRL			32'h00000000	
	`define							RST_Si5338_PARA			32'h00000000	
	`define							RST_Si5338_WDAT			32'h00000000	
	`define							RST_Si5338_RDAT			32'h00000000	
	
	`define							Si5338_REG_MAX_ADDR		 4'hF
	
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
			REG_ARRAY[`REG_Si5338_CTRL] <= `RST_Si5338_CTRL;
			REG_ARRAY[`REG_Si5338_INIT] <= `RST_Si5338_INIT;
		end else begin
			if ( r_reg_wren && r_reg_wadr <= `Si5338_REG_MAX_ADDR ) begin
				REG_ARRAY[r_reg_wadr[3:0]] <= r_reg_wdat;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_trig <= 1'b0;
		end else begin
			if ( r_reg_wren && r_reg_wadr == `REG_Si5338_CTRL ) begin
				r_trig <= r_reg_wdat[0];
			end else begin
				r_trig <= 1'b0;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_busy <= 1'b0;
		end else begin
			if ( r_trig ) begin
				r_busy <= 1'b1;
			end else if ( USR_end ) begin
				r_busy <= 1'b0;
			end
		end
	end
	
	assign	USR_rnw				= REG_ARRAY[`REG_Si5338_CTRL][1];	
	assign	USR_deivce_id		= REG_ARRAY[`REG_Si5338_CTRL][15: 8];	
	assign	USR_wrcyc			= REG_ARRAY[`REG_Si5338_PARA][ 7: 0];	
	assign	USR_rdcyc			= REG_ARRAY[`REG_Si5338_PARA][15: 8];	
	assign	USR_reg_addr		= REG_ARRAY[`REG_Si5338_PARA][31:16];
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_wdata <= 32'b0;
		end else begin
			if ( r_trig ) begin
				r_wdata <= REG_ARRAY[`REG_Si5338_WDAT];
			end else if ( USR_wvld ) begin
				r_wdata <= {8'b0,r_wdata[31:8]};
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_rdata <= 32'b0;
		end else begin
			if ( r_trig ) begin
				r_rdata <= 32'b0;
			end else if ( USR_rvld ) begin
				r_rdata <= {r_rdata[23:0],USR_rdata};
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_USR_trig  <= 1'b0;
			r_USR_wdata <= 8'b0;
		end else begin
			r_USR_trig <= r_trig;
			r_USR_wdata<= r_wdata[7:0] ;
		end
	end
	
	assign	USR_trig = r_USR_trig	;
	assign	USR_wdata= r_USR_wdata	;
	
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
			`REG_Si5338_VER		: r_reg_rdat <= `RST_Si5338_VER;
			`REG_Si5338_CTRL	: r_reg_rdat <= {r_busy,USR_error,REG_ARRAY[`REG_Si5338_CTRL][29:0]};
			`REG_Si5338_INIT	: r_reg_rdat <= REG_ARRAY[`REG_Si5338_INIT	];
			`REG_Si5338_PARA	: r_reg_rdat <= REG_ARRAY[`REG_Si5338_PARA	];
			`REG_Si5338_WDAT	: r_reg_rdat <= REG_ARRAY[`REG_Si5338_WDAT	];
			`REG_Si5338_RDAT	: r_reg_rdat <= r_rdata;
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