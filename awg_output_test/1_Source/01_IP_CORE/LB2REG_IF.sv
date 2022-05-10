module LB2REG_IF (
	input					CLK					,
	input					RST					,
	LB_BUS.slave			LB_BUS_IF			,
	REG_BUS.master			REG_BUS_IF	
);
	
	reg						r_lb_wreq			;
	wire					w_reg1_wren			;
	reg						r_reg1_wren			;
	reg		[31:0]			r_reg1_wadr			;
	reg		[31:0]			r_reg1_wdat			;
	reg						r_lb_rreq			;
	wire					w_reg1_rden			;
	reg						r_reg1_rden			;
	reg		[31:0]			r_reg1_radr			;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_wreq <= 1'b0;
		end else begin
			r_lb_wreq <= LB_BUS_IF.LB_WREQ;
		end
	end
	
	assign	w_reg1_wren = ~r_lb_wreq & LB_BUS_IF.LB_WREQ;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg1_wren <= 1'b0;
			r_reg1_wadr <= 32'h0;
			r_reg1_wdat <= 32'h0;
		end else begin
			r_reg1_wren <= w_reg1_wren;
			r_reg1_wadr <= LB_BUS_IF.LB_WADR;
			r_reg1_wdat <= LB_BUS_IF.LB_WDAT;
		end
	end
	
	assign	LB_BUS_IF.LB_WACK = r_reg1_wren;
	
	assign	REG_BUS_IF.WREN = r_reg1_wren;
	assign	REG_BUS_IF.WADR = r_reg1_wadr;
	assign	REG_BUS_IF.WDAT = r_reg1_wdat;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_lb_rreq <= 1'b0;
		end else begin
			r_lb_rreq <= LB_BUS_IF.LB_RREQ;
		end
	end
	
	assign	w_reg1_rden = ~r_lb_rreq & LB_BUS_IF.LB_RREQ;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg1_rden <= 1'b0;
			r_reg1_radr <=32'h0;
		end else begin
			r_reg1_rden <= w_reg1_rden;
			r_reg1_radr <= LB_BUS_IF.LB_RADR;
		end
	end
	
	assign	REG_BUS_IF.RDEN = r_reg1_rden;
	assign	REG_BUS_IF.RADR = r_reg1_radr;
	
	assign	LB_BUS_IF.LB_RDAT = REG_BUS_IF.RDAT;
	assign	LB_BUS_IF.LB_RACK = REG_BUS_IF.RVLD;
	
endmodule