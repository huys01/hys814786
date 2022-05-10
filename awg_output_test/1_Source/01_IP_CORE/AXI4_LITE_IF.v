
	`timescale 1ns / 1ps
	
	module AXI4_LITE_IF (
		////////////////////////////////////////////////////
		// AXI4 Lite Slave interface
		input			S_AXI_ACLK		,
		input			S_AXI_ARESETN	,
		// AXI write address channel signals
		output			S_AXI_AWREADY	,// Indicates slave is ready to accept 
		input	[31:0]	S_AXI_AWADDR	,// Write address
		input			S_AXI_AWVALID	,// Write address valid
		// AXI write data channel signals
		output			S_AXI_WREADY	,// Write data ready
		input	[31:0]	S_AXI_WDATA	,// Write data
		input	[ 3:0]	S_AXI_WSTRB	,// Write strobes
		input			S_AXI_WVALID	,// Write valid
		// AXI write response channel signals
		output	[ 1:0]	S_AXI_BRESP	,// Write response
		output			S_AXI_BVALID	,// Write reponse valid
		input			S_AXI_BREADY	,// Response ready
		// AXI read address channel signals
		output			S_AXI_ARREADY	,// Read address ready
		input	[31:0]	S_AXI_ARADDR	,// Read address
		input			S_AXI_ARVALID	,// Read address valid
		// AXI read data channel signals	
		output	[ 1:0]	S_AXI_RRESP	,// Read response
		output			S_AXI_RVALID	,// Read reponse valid
		output	[31:0]	S_AXI_RDATA	,// Read data
		input			S_AXI_RREADY	,// Read Response ready
		
		////////////////////////////////////////////////////
		// Local Bus User interface
		output			OP_LB_WREQ			,
		output	[31:0]	OP_LB_WADR			,
		output	[ 3:0]	OP_LB_WBEN			,
		output	[31:0]	OP_LB_WDAT			,
		input			IP_LB_WACK			,
		output			OP_LB_RREQ			,
		output	[31:0]	OP_LB_RADR			,
		input	[31:0]	IP_LB_RDAT			,
		input			IP_LB_RACK			
		
	);
	
	parameter	st_WR_IDLE	= 2'b00;
	parameter	st_WR_ADDR	= 2'b01;
	parameter	st_WR_DATA	= 2'b10;
	parameter	st_WR_ACK	= 2'b11;
	
	parameter	st_RD_IDLE	= 2'b00;
	parameter	st_RD_ADDR	= 2'b01;
	parameter	st_RD_DATA	= 2'b10;
	parameter	st_RD_ACK	= 2'b11;
	
	reg		[ 1:0]	r_fsm_wr	;
	reg				r_axi_wready;
	wire			w_lb_wreq	;
	reg		[31:0]	r_lb_wadr	;
	reg		[31:0]	r_lb_wdat	;
	reg		[ 3:0]	r_lb_wben	;
	reg		[ 1:0]	r_fsm_rd	;
	wire			w_lb_rreq	;
	reg		[31:0]	r_lb_radr	;
	reg		[31:0]	r_lb_rdat	;
	
	// Write Handle
	always @ ( posedge S_AXI_ACLK ) begin
		if ( !S_AXI_ARESETN ) begin
			r_fsm_wr <= st_WR_IDLE;
		end else begin
			case ( r_fsm_wr )
				st_WR_IDLE :
					if ( S_AXI_AWVALID ) begin
						r_fsm_wr <= st_WR_ADDR;
					end
				st_WR_ADDR :
					if ( S_AXI_WVALID ) begin
						r_fsm_wr <= st_WR_DATA;
					end
				st_WR_DATA :
					if ( IP_LB_WACK ) begin
						r_fsm_wr <= st_WR_ACK;
					end
				st_WR_ACK :
					if ( S_AXI_BREADY ) begin
						r_fsm_wr <= st_WR_IDLE;
					end
				default :
						r_fsm_wr <= st_WR_IDLE;
			endcase
		end
	end

	assign	w_lb_wreq = ( r_fsm_wr == st_WR_DATA ) ? 1'b1:1'b0;
	
	always @ ( posedge S_AXI_ACLK ) begin
		if ( !S_AXI_ARESETN ) begin
			r_lb_wadr <= 32'h0;
			r_lb_wdat <= 32'h0;
			r_lb_wben <= 4'b0;	
		end else begin
			if ( r_fsm_wr == st_WR_IDLE ) begin
				r_lb_wadr <= (S_AXI_AWADDR );
			end
			if ( r_fsm_wr == st_WR_ADDR ) begin
				r_lb_wdat <= S_AXI_WDATA;
				r_lb_wben <= S_AXI_WSTRB;
			end
		end
	end
	
	always @ ( posedge S_AXI_ACLK ) begin
		if ( !S_AXI_ARESETN ) begin
			r_axi_wready <= 1'b0;
		end else begin
			if ( r_fsm_wr == st_WR_IDLE ) begin
				r_axi_wready <= S_AXI_AWVALID;
			end else if ( r_fsm_wr == st_WR_ADDR ) begin
				r_axi_wready <= ~S_AXI_WVALID;
			end
		end
	end
	
	assign	OP_LB_WREQ = w_lb_wreq;
	assign	OP_LB_WADR = r_lb_wadr;
	assign	OP_LB_WDAT = r_lb_wdat;
	assign	OP_LB_WBEN = r_lb_wben;
	
	assign	S_AXI_AWREADY	= 1'b1;
	assign	S_AXI_WREADY	= r_axi_wready;
	assign	S_AXI_BVALID	= (r_fsm_wr == st_WR_ACK) ? 1'b1:1'b0;
	assign	S_AXI_BRESP	= 2'b00;
	
	// Read Handle
	always @ ( posedge S_AXI_ACLK ) begin
		if ( !S_AXI_ARESETN ) begin
			r_fsm_rd <= st_RD_IDLE;
		end else begin
			case ( r_fsm_rd ) 
				st_RD_IDLE :
					if ( S_AXI_ARVALID ) begin
						r_fsm_rd <= st_RD_ADDR;
					end
				st_RD_ADDR :
					if ( IP_LB_RACK ) begin
						r_fsm_rd <= st_RD_DATA;
					end
				st_RD_DATA :
					if ( S_AXI_RREADY ) begin
						r_fsm_rd <= st_RD_ACK;
					end
				st_RD_ACK : 
					r_fsm_rd <= st_RD_IDLE;
				default :
					r_fsm_rd <= st_RD_IDLE;
			endcase
 		end
	end
	
	assign	w_lb_rreq = ( r_fsm_rd == st_RD_ADDR ) ? 1'b1:1'b0;
	
	always @ ( posedge S_AXI_ACLK ) begin
		if ( !S_AXI_ARESETN ) begin
			r_lb_radr <= 32'h0;
		end else begin
			if ( r_fsm_rd  == st_RD_IDLE ) begin
				r_lb_radr <= (S_AXI_ARADDR );
			end
		end
	end
	assign	OP_LB_RREQ = w_lb_rreq;
	assign	OP_LB_RADR = r_lb_radr;
	
	always @ ( posedge S_AXI_ACLK ) begin
		if ( !S_AXI_ARESETN ) begin
			r_lb_rdat <= 32'h0;
		end else begin
			if ( IP_LB_RACK ) begin
				r_lb_rdat <= IP_LB_RDAT;
			end
		end
	end

	assign	S_AXI_ARREADY= 1'b1;
	assign	S_AXI_RVALID = ( r_fsm_rd == st_RD_DATA ) ? 1'b1:1'b0;
	assign	S_AXI_RDATA  = r_lb_rdat;
	assign	S_AXI_RRESP  = 2'b0;

endmodule



