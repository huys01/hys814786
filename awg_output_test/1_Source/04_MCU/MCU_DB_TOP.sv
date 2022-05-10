module MCU_DB_TOP (
	input							CLK									,
	input							RST									,
	REG_BUS.master					REG_BUS_IF							,
	output							UART_TXD							,
	input							UART_RXD						
);

	wire							w_REG_BUS_lb_rack					;
	wire	[31:0]					w_REG_BUS_lb_radr					;
	wire	[31:0]					w_REG_BUS_lb_rdat					;
	wire							w_REG_BUS_lb_rreq					;
	wire							w_REG_BUS_lb_wack					;
	wire	[31:0]					w_REG_BUS_lb_wadr					;
	wire	[31:0]					w_REG_BUS_lb_wdat					;
	wire							w_REG_BUS_lb_wreq					;
	wire	[31:0]					w_AXI4_LITE_araddr					; // [31:0]  
	wire	[ 2:0]					w_AXI4_LITE_arprot					; // [ 2:0]  
	wire	[ 0:0]					w_AXI4_LITE_arready					; // [ 0:0]  
	wire	[ 0:0]					w_AXI4_LITE_arvalid					; // [ 0:0]  
	wire	[31:0]					w_AXI4_LITE_awaddr					; // [31:0]  
	wire	[ 2:0]					w_AXI4_LITE_awprot					; // [ 2:0]  
	wire	[ 0:0]					w_AXI4_LITE_awready					; // [ 0:0]  
	wire	[ 0:0]					w_AXI4_LITE_awvalid					; // [ 0:0]  
	wire	[ 0:0]					w_AXI4_LITE_bready					; // [ 0:0]  
	wire	[ 1:0]					w_AXI4_LITE_bresp					; // [ 1:0]  
	wire	[ 0:0]					w_AXI4_LITE_bvalid					; // [ 0:0]  
	wire	[31:0]					w_AXI4_LITE_rdata					; // [31:0]  
	wire	[ 0:0]					w_AXI4_LITE_rready					; // [ 0:0]  
	wire	[ 1:0]					w_AXI4_LITE_rresp					; // [ 1:0]  
	wire	[ 0:0]					w_AXI4_LITE_rvalid					; // [ 0:0]  
	wire	[31:0]					w_AXI4_LITE_wdata					; // [31:0]  
	wire	[ 0:0]					w_AXI4_LITE_wready					; // [ 0:0]  
	wire	[ 3:0]					w_AXI4_LITE_wstrb					; // [ 3:0]  
	wire	[ 0:0]					w_AXI4_LITE_wvalid					; // [ 0:0]  
	
	LB_BUS							LB_BUS_IF						()	;

MCU_DB U_MCU_DB(
	.AUX_RST						( 1'b0								),
	.AXI4_LITE_araddr				( w_AXI4_LITE_araddr				),// output [31:0]
	.AXI4_LITE_arprot				( w_AXI4_LITE_arprot				),// output [2:0]	
	.AXI4_LITE_arready				( w_AXI4_LITE_arready				),// input  [0:0]	
	.AXI4_LITE_arvalid				( w_AXI4_LITE_arvalid				),// output [0:0]	
	.AXI4_LITE_awaddr				( w_AXI4_LITE_awaddr				),// output [31:0]
	.AXI4_LITE_awprot				( w_AXI4_LITE_awprot				),// output [2:0]	
	.AXI4_LITE_awready				( w_AXI4_LITE_awready				),// input  [0:0]	
	.AXI4_LITE_awvalid				( w_AXI4_LITE_awvalid				),// output [0:0]	
	.AXI4_LITE_bready				( w_AXI4_LITE_bready				),// output [0:0]	
	.AXI4_LITE_bresp				( w_AXI4_LITE_bresp					),// input  [1:0]	
	.AXI4_LITE_bvalid				( w_AXI4_LITE_bvalid				),// input  [0:0]	
	.AXI4_LITE_rdata				( w_AXI4_LITE_rdata					),// input  [31:0]  
	.AXI4_LITE_rready				( w_AXI4_LITE_rready				),// output [0:0]	
	.AXI4_LITE_rresp				( w_AXI4_LITE_rresp					),// input  [1:0]	
	.AXI4_LITE_rvalid				( w_AXI4_LITE_rvalid				),// input  [0:0]	
	.AXI4_LITE_wdata				( w_AXI4_LITE_wdata					),// output [31:0] 
	.AXI4_LITE_wready				( w_AXI4_LITE_wready				),// input  [0:0]	
	.AXI4_LITE_wstrb				( w_AXI4_LITE_wstrb					),// output [3:0]	
	.AXI4_LITE_wvalid				( w_AXI4_LITE_wvalid				),// output [0:0]	
	.DCM_LOCKED						( 1'b1								),
	.MCU_CLK						( CLK								),
	.MCU_RSTn						(~RST								),
	.UART_rxd						( UART_RXD							),
	.UART_txd						( UART_TXD							)
);

// Instantiation of Axi Bus Interface S00_AXI
AXI4_LITE_IF U_AXI4_LITE_IF0 ( 
	.S_AXI_ACLK						( CLK								),
	.S_AXI_ARESETN					( ~RST								),
	.S_AXI_AWADDR					( w_AXI4_LITE_awaddr				),//
//	.S_AXI_AWPROT					( w_AXI4_LITE_awprot				),//
	.S_AXI_AWVALID					( w_AXI4_LITE_awvalid				),//
	.S_AXI_AWREADY					( w_AXI4_LITE_awready				),//
	.S_AXI_WDATA					( w_AXI4_LITE_wdata					),//
	.S_AXI_WSTRB					( w_AXI4_LITE_wstrb					),//
	.S_AXI_WVALID					( w_AXI4_LITE_wvalid				),//
	.S_AXI_WREADY					( w_AXI4_LITE_wready				),//
	.S_AXI_BRESP					( w_AXI4_LITE_bresp					),//
	.S_AXI_BVALID					( w_AXI4_LITE_bvalid				),//
	.S_AXI_BREADY					( w_AXI4_LITE_bready				),//
	.S_AXI_ARADDR					( w_AXI4_LITE_araddr				),//
//	.S_AXI_ARPROT					( w_AXI4_LITE_arprot				),//
	.S_AXI_ARVALID					( w_AXI4_LITE_arvalid				),//
	.S_AXI_ARREADY					( w_AXI4_LITE_arready				),//
	.S_AXI_RDATA					( w_AXI4_LITE_rdata					),//
	.S_AXI_RRESP					( w_AXI4_LITE_rresp					),//
	.S_AXI_RVALID					( w_AXI4_LITE_rvalid				),//
	.S_AXI_RREADY					( w_AXI4_LITE_rready				),//
	.OP_LB_WREQ						( w_REG_BUS_lb_wreq					),	
	.OP_LB_WADR						( w_REG_BUS_lb_wadr					),	
	.OP_LB_WBEN						( 									),	
	.OP_LB_WDAT						( w_REG_BUS_lb_wdat					),	
	.IP_LB_WACK						( w_REG_BUS_lb_wack					),	
	.OP_LB_RREQ						( w_REG_BUS_lb_rreq					),	
	.OP_LB_RADR						( w_REG_BUS_lb_radr					),	
	.IP_LB_RDAT						( w_REG_BUS_lb_rdat					),	
	.IP_LB_RACK						( w_REG_BUS_lb_rack					) 	
);

assign	LB_BUS_IF.LB_WREQ = w_REG_BUS_lb_wreq;
assign	LB_BUS_IF.LB_WADR = w_REG_BUS_lb_wadr[31:0];
assign	LB_BUS_IF.LB_WDAT = w_REG_BUS_lb_wdat;
assign	LB_BUS_IF.LB_RREQ = w_REG_BUS_lb_rreq;
assign	LB_BUS_IF.LB_RADR = w_REG_BUS_lb_radr[31:0];
assign	w_REG_BUS_lb_rack = LB_BUS_IF.LB_RACK;
assign	w_REG_BUS_lb_wack = LB_BUS_IF.LB_WACK;
assign	w_REG_BUS_lb_rdat = LB_BUS_IF.LB_RDAT;

LB2REG_IF (
	.CLK							( CLK								),
	.RST							( RST								),
	.LB_BUS_IF						( LB_BUS_IF							),
	.REG_BUS_IF						( REG_BUS_IF						)
);

endmodule