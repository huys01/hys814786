
	`timescale 1ns / 1ps
	
	module AXI4_LITE_MIF (
		input				CLK				,
		input				RST				,
		
		input				REG_WREN		,
		input	[15:0]		REG_WADR		,
		input	[31:0]		REG_WDAT		,
		input				REG_RDEN		,
		input	[15:0]		REG_RADR		,
		output	[31:0]		REG_RDAT		,
		output				REG_RVLD		,
		
		// AXI4 Lite Slave interface
		input				S_AXI_AWREADY	,
		output	[31:0]		S_AXI_AWADDR	,
		output				S_AXI_AWVALID	,
		input				S_AXI_WREADY	,
		output	[31:0]		S_AXI_WDATA		,
		output	[ 3:0]		S_AXI_WSTRB		,
		output				S_AXI_WVALID	,
		input	[ 1:0]		S_AXI_BRESP		,
		input				S_AXI_BVALID	,
		output				S_AXI_BREADY	,
		input				S_AXI_ARREADY	,
		output	[31:0]		S_AXI_ARADDR	,
		output				S_AXI_ARVALID	,
		input	[ 1:0]		S_AXI_RRESP		,
		input				S_AXI_RVALID	,
		input	[31:0]		S_AXI_RDATA		,
		output				S_AXI_RREADY	 
	);
	
	localparam	st_WR_IDLE	= 2'b00;
	localparam	st_WR_ADDR	= 2'b01;
	localparam	st_WR_DATA	= 2'b10;
	localparam	st_WR_ACK	= 2'b11;
	
	localparam	st_RD_IDLE	= 2'b00;
	localparam	st_RD_ADDR	= 2'b01;
	localparam	st_RD_DATA	= 2'b10;
	localparam	st_RD_ACK	= 2'b11;
	
	reg		[ 1:0]		r_fsm_wr			;
	reg		[ 1:0]		r_fsm_rd			;
	reg					r_reg_wren			;
	reg					r_reg_rden			;
	reg		[15:0]		r_reg_wadr			;
	reg		[15:0]		r_reg_radr			;
	reg		[31:0]		r_reg_wdat			;
	reg		[31:0]		r_axi_awaddr		;
	reg		[31:0]		r_axi_wdata			;
	reg					r_AXI_AWVALID		;
	reg					r_AXI_WVALID		;
	reg		[31:0]		r_axi_rwaddr		;
	reg					r_AXI_ARVALID		;
	reg		[31:0]		r_reg_rdat			;
	reg					r_reg_rvld			;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_wren <= 1'b0;
			r_reg_rden <= 1'b0;
			r_reg_wadr <= 16'b0;
			r_reg_radr <= 16'b0;
			r_reg_wdat <= 32'b0;
		end else begin
			r_reg_wren <= REG_WREN;
			r_reg_rden <= REG_RDEN;
			r_reg_wadr <= REG_WADR;
			r_reg_radr <= REG_RADR;
			r_reg_wdat <= REG_WDAT;
		end
	end 
	
	reg		r_reg_wren_d0;
	reg		r_reg_rden_d0;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_wren_d0 <= 1'b0;
			r_reg_rden_d0 <= 1'b0;
		end else begin
			r_reg_wren_d0 <= r_reg_wren;
			r_reg_rden_d0 <= r_reg_rden;
		end
	end
	
	// Write Handle
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_fsm_wr <= st_WR_IDLE;
		end else begin
			case ( r_fsm_wr )
				st_WR_IDLE :
					if ( r_reg_wren && ~r_reg_wren_d0 ) begin
						r_fsm_wr <= st_WR_ADDR;
					end
					
				st_WR_ADDR :
					if ( S_AXI_AWREADY ) begin
						r_fsm_wr <= st_WR_DATA;
					end
					
				st_WR_DATA :
					if ( S_AXI_WREADY ) begin
						r_fsm_wr <= st_WR_ACK;
					end
					
				st_WR_ACK :
					if ( S_AXI_BVALID ) begin
						r_fsm_wr <= st_WR_IDLE;
					end
					
				default :
						r_fsm_wr <= st_WR_IDLE;
			endcase
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_axi_awaddr <= 32'b0;
			r_axi_wdata  <= 32'b0;
			r_AXI_AWVALID <= 1'b0;
		end else begin
			if ( r_fsm_wr == st_WR_IDLE && r_reg_wren ) begin
				r_axi_awaddr <= {16'b0,r_reg_wadr};
				r_axi_wdata  <= r_reg_wdat;
				r_AXI_AWVALID <= 1'b1;
			end else if ( r_fsm_wr == st_WR_DATA && S_AXI_WREADY ) begin
				r_AXI_AWVALID <= 1'b0;
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_AXI_WVALID <= 1'b0;
		end else begin
			if ( r_fsm_wr == st_WR_IDLE && r_reg_wren ) begin
				r_AXI_WVALID <= 1'b1;
			end else if ( r_fsm_wr == st_WR_ADDR && S_AXI_AWREADY ) begin
				r_AXI_WVALID <= 1'b0;
			end
		end
	end
	
	/*always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_AXI_WVALID <= 1'b0;
		end else begin
			if ( r_fsm_wr == st_WR_DATA && S_AXI_WREADY ) begin
				r_AXI_WVALID <= 1'b1;
			end else begin
				r_AXI_WVALID <= 1'b0;
			end
		end
	end */
	
	assign	S_AXI_AWVALID = r_AXI_AWVALID;
	assign	S_AXI_AWADDR  = r_axi_awaddr;
	assign	S_AXI_WVALID  = r_AXI_WVALID;
	assign	S_AXI_WDATA   = r_axi_wdata;
	assign	S_AXI_WSTRB   = 4'hF;
	assign	S_AXI_BREADY  = 1'b1;
	
	// Read Handle
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_fsm_rd <= st_RD_IDLE;
		end else begin
			case ( r_fsm_rd ) 
				st_RD_IDLE :
					if ( r_reg_rden && ~r_reg_rden_d0 ) begin
						r_fsm_rd <= st_RD_ADDR;
					end
				st_RD_ADDR :
					if ( S_AXI_ARREADY ) begin
						r_fsm_rd <= st_RD_DATA;
					end
				st_RD_DATA :
					if ( S_AXI_RVALID ) begin
						r_fsm_rd <= st_RD_ACK;
					end
				st_RD_ACK :
					r_fsm_rd <= st_RD_IDLE;
				default :
					r_fsm_rd <= st_RD_IDLE;
			endcase
 		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_axi_rwaddr <= 32'b0;
		end else begin
			if ( r_fsm_rd == st_RD_IDLE && r_reg_rden ) begin
				r_axi_rwaddr <= {16'b0,r_reg_radr};
			end
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_AXI_ARVALID <= 1'b0;
		end else begin
			if ( r_fsm_rd == st_RD_ADDR && S_AXI_ARREADY ) begin
				r_AXI_ARVALID <= 1'b1;
			end else begin
				r_AXI_ARVALID <= 1'b0;
			end
		end
	end	

	assign	S_AXI_ARADDR	= r_axi_rwaddr	;// Read address
	assign	S_AXI_ARVALID	= r_AXI_ARVALID	;// Read address valid
	assign	S_AXI_RREADY	= 1'b1;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_rdat <= 32'b0;
			r_reg_rvld <= 1'b0;
		end else begin
			if ( r_fsm_rd == st_RD_DATA && S_AXI_RVALID ) begin
				r_reg_rdat <= S_AXI_RDATA;
				r_reg_rvld <= 1'b1;
			end else begin
				r_reg_rvld <= 1'b0;
			end
		end
	end	
	
	assign	REG_RDAT = r_reg_rdat;
	assign	REG_RVLD = r_reg_rvld;

endmodule



