// =============================================================================
// file name	: MEM_TOP.v														
// module		: MEM_TOP														
// =============================================================================
// function		: Memory Controller Top Module									
// -----------------------------------------------------------------------------
// updata history:																
// -----------------------------------------------------------------------------
// rev.level	Date			Coded By			contents					
// v0.0.0		2018/12/13		ShenH				create new					
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

`timescale 1ns/1ps

module MEM_TOP (																					
// Memory Access Clock & Reset														
	output							MEM0_CLK						,//o 			
	output							MEM0_RST						,//o 			
	output							MEM1_CLK						,//o 			
	output							MEM1_RST						,//o 			
// DDR4-0/1 Interface
`ifndef SIM
	DDR4_BUS.master					DDR4_BUS_IF0					,//
	DDR4_BUS.master					DDR4_BUS_IF1					,//
`endif
// Registers Access IF															
	REG_BUS.slave					REG_BUS_IF						,//Slave		
//DDR3_0-Write Port0~7																
	MEMW_BUS.slave					MEMW_BUS_00						,//Slave 		
	MEMW_BUS.slave					MEMW_BUS_01						,//Slave 		
	MEMW_BUS.slave					MEMW_BUS_02						,//Slave 		
	MEMW_BUS.slave					MEMW_BUS_03						,//Slave 		
	MEMW_BUS.slave					MEMW_BUS_04						,//Slave 		
	MEMW_BUS.slave					MEMW_BUS_05						,//Slave 		
	MEMW_BUS.slave					MEMW_BUS_06						,//Slave 		
	MEMW_BUS.slave					MEMW_BUS_07						,//Slave 		
//DDR3_0-Read Port0~7																
	MEMR_BUS.slave					MEMR_BUS_00						,//Slave		
	MEMR_BUS.slave					MEMR_BUS_01						,//Slave		
	MEMR_BUS.slave					MEMR_BUS_02						,//Slave		
	MEMR_BUS.slave					MEMR_BUS_03						,//Slave		
	MEMR_BUS.slave					MEMR_BUS_04						,//Slave		
	MEMR_BUS.slave					MEMR_BUS_05						,//Slave		
	MEMR_BUS.slave					MEMR_BUS_06						,//Slave		
	MEMR_BUS.slave					MEMR_BUS_07						,//Slave		
//DDR3_1-Write Port0~7																
	MEMW_BUS.slave					MEMW_BUS_10						,//Slave 		
	MEMW_BUS.slave					MEMW_BUS_11						,//Slave 		
	MEMW_BUS.slave					MEMW_BUS_12						,//Slave 		
	MEMW_BUS.slave					MEMW_BUS_13						,//Slave 		
	MEMW_BUS.slave					MEMW_BUS_14						,//Slave 		
	MEMW_BUS.slave					MEMW_BUS_15						,//Slave 		
	MEMW_BUS.slave					MEMW_BUS_16						,//Slave 		
	MEMW_BUS.slave					MEMW_BUS_17						,//Slave 		
//DDR3_1-Read Port0~7																
	MEMR_BUS.slave					MEMR_BUS_10						,//Slave		
	MEMR_BUS.slave					MEMR_BUS_11						,//Slave		
	MEMR_BUS.slave					MEMR_BUS_12						,//Slave		
	MEMR_BUS.slave					MEMR_BUS_13						,//Slave		
	MEMR_BUS.slave					MEMR_BUS_14						,//Slave		
	MEMR_BUS.slave					MEMR_BUS_15						,//Slave		
	MEMR_BUS.slave					MEMR_BUS_16						,//Slave		
	MEMR_BUS.slave					MEMR_BUS_17						,//Slave		
// DDR3-0/1 Outside Interface														
	input							DDR4_RST_IN						,//i 			
	input							DDR4_0_CLK_IN					, //i 			
	input							DDR4_1_CLK_IN					  //i 			
);																				
	//--------------------------------------------------------------------------
	// Signal Declaration														
	//--------------------------------------------------------------------------
	wire	[  3:0] 				w_m0_c0_axi_awid				;//[  3:0]		
	wire	[ 31:0] 				w_m0_c0_axi_awaddr				;//[ 31:0]		
	wire	[  7:0] 				w_m0_c0_axi_awlen				;//[  7:0]		
	wire	[  2:0] 				w_m0_c0_axi_awsize				;//[  2:0]		
	wire	[  1:0] 				w_m0_c0_axi_awburst				;//[  1:0]		
	wire							w_m0_c0_axi_awlock				;//				
	wire	[  3:0] 				w_m0_c0_axi_awcache				;//[  3:0]		
	wire	[  2:0] 				w_m0_c0_axi_awprot				;//[  2:0]		
	wire	[  3:0] 				w_m0_c0_axi_awqos				;//[  3:0]		
	wire							w_m0_c0_axi_awvalid				;//				
	wire							w_m0_c0_axi_awready				;//				
	wire	[511:0] 				w_m0_c0_axi_wdata				;//[511:0]		
	wire	[ 63:0] 				w_m0_c0_axi_wstrb				;//[ 63:0]		
	wire							w_m0_c0_axi_wlast				;//				
	wire							w_m0_c0_axi_wvalid				;//				
	wire							w_m0_c0_axi_wready				;//				
	wire	[  3:0] 				w_m0_c0_axi_bid					;//[  3:0]		
	wire	[  1:0] 				w_m0_c0_axi_bresp				;//[  1:0]		
	wire							w_m0_c0_axi_bvalid				;//				
	wire							w_m0_c0_axi_bready				;//				
	wire	[  3:0] 				w_m0_c0_axi_arid				;//[  3:0]		
	wire	[ 31:0] 				w_m0_c0_axi_araddr				;//[ 31:0]		
	wire	[  7:0] 				w_m0_c0_axi_arlen				;//[  7:0]		
	wire	[  2:0] 				w_m0_c0_axi_arsize				;//[  2:0]		
	wire	[  1:0] 				w_m0_c0_axi_arburst				;//[  1:0]		
	wire							w_m0_c0_axi_arlock				;//				
	wire	[  3:0] 				w_m0_c0_axi_arcache				;//[  3:0]		
	wire	[  2:0] 				w_m0_c0_axi_arprot				;//[  2:0]		
	wire	[  3:0] 				w_m0_c0_axi_arqos				;//[  3:0]		
	wire							w_m0_c0_axi_arvalid				;//				
	wire							w_m0_c0_axi_arready				;//				
	wire	[  3:0] 				w_m0_c0_axi_rid					;//[  3:0]		
	wire	[511:0] 				w_m0_c0_axi_rdata				;//[511:0]		
	wire	[  1:0] 				w_m0_c0_axi_rresp				;//[  1:0]		
	wire							w_m0_c0_axi_rlast				;//				
	wire							w_m0_c0_axi_rvalid				;//				
	wire							w_m0_c0_axi_rready				;//				
	wire							w_ui0_clk						;//				
	wire							w_ui0_rst						;//				
	wire	[  3:0] 				w_m0_c1_axi_awid				;//[  3:0]		
	wire	[ 31:0] 				w_m0_c1_axi_awaddr				;//[ 31:0]		
	wire	[  7:0] 				w_m0_c1_axi_awlen				;//[  7:0]		
	wire	[  2:0] 				w_m0_c1_axi_awsize				;//[  2:0]		
	wire	[  1:0] 				w_m0_c1_axi_awburst				;//[  1:0]		
	wire							w_m0_c1_axi_awlock				;//				
	wire	[  3:0] 				w_m0_c1_axi_awcache				;//[  3:0]		
	wire	[  2:0] 				w_m0_c1_axi_awprot				;//[  2:0]		
	wire	[  3:0] 				w_m0_c1_axi_awqos				;//[  3:0]		
	wire							w_m0_c1_axi_awvalid				;//				
	wire							w_m0_c1_axi_awready				;//				
	wire	[511:0] 				w_m0_c1_axi_wdata				;//[511:0]		
	wire	[ 63:0] 				w_m0_c1_axi_wstrb				;//[ 63:0]		
	wire							w_m0_c1_axi_wlast				;//				
	wire							w_m0_c1_axi_wvalid				;//				
	wire							w_m0_c1_axi_wready				;//				
	wire	[  3:0] 				w_m0_c1_axi_bid					;//[  3:0]		
	wire	[  1:0] 				w_m0_c1_axi_bresp				;//[  1:0]		
	wire							w_m0_c1_axi_bvalid				;//				
	wire							w_m0_c1_axi_bready				;//				
	wire	[  3:0] 				w_m0_c1_axi_arid				;//[  3:0]		
	wire	[ 31:0] 				w_m0_c1_axi_araddr				;//[ 31:0]		
	wire	[  7:0] 				w_m0_c1_axi_arlen				;//[  7:0]		
	wire	[  2:0] 				w_m0_c1_axi_arsize				;//[  2:0]		
	wire	[  1:0] 				w_m0_c1_axi_arburst				;//[  1:0]		
	wire							w_m0_c1_axi_arlock				;//				
	wire	[  3:0] 				w_m0_c1_axi_arcache				;//[  3:0]		
	wire	[  2:0] 				w_m0_c1_axi_arprot				;//[  2:0]		
	wire	[  3:0] 				w_m0_c1_axi_arqos				;//[  3:0]		
	wire							w_m0_c1_axi_arvalid				;//				
	wire							w_m0_c1_axi_arready				;//				
	wire	[  3:0] 				w_m0_c1_axi_rid					;//[  3:0]		
	wire	[511:0] 				w_m0_c1_axi_rdata				;//[511:0]		
	wire	[  1:0] 				w_m0_c1_axi_rresp				;//[  1:0]		
	wire							w_m0_c1_axi_rlast				;//				
	wire							w_m0_c1_axi_rvalid				;//				
	wire							w_m0_c1_axi_rready				;//				
	wire							w_ui1_clk						;//				
	wire							w_ui1_rst						;//				
	
	MEMW_BUS						MEMW_BUS_IF0(.CLK(MEM0_CLK),.RST(MEM0_RST));
	MEMW_BUS						MEMW_BUS_IF1(.CLK(MEM0_CLK),.RST(MEM0_RST));
	MEMR_BUS						MEMR_BUS_IF0(.CLK(MEM0_CLK),.RST(MEM0_RST));
	MEMR_BUS						MEMR_BUS_IF1(.CLK(MEM0_CLK),.RST(MEM0_RST));
	MEMW_BUS						MEMW_BUS_IF2(.CLK(MEM1_CLK),.RST(MEM1_RST));
	MEMW_BUS						MEMW_BUS_IF3(.CLK(MEM1_CLK),.RST(MEM1_RST));
	MEMR_BUS						MEMR_BUS_IF2(.CLK(MEM1_CLK),.RST(MEM1_RST));
	MEMR_BUS						MEMR_BUS_IF3(.CLK(MEM1_CLK),.RST(MEM1_RST));
	
	DDR_TEST_BUS					DDR_TEST_IF0()					;	
	DDR_TEST_BUS					DDR_TEST_IF1()					;	
	DDR_TEST_BUS					DDR_TEST_IF2()					;	
	DDR_TEST_BUS					DDR_TEST_IF3()					;	

DDR_REG U_DDR_REG (											 					
//Clock & Reset																	
	.CLK							( REG_BUS_IF.CLK				),//i 			
	.RST							( REG_BUS_IF.RST				),//i 			
// Registers Access IF															
	.REG_BUS_IF						( REG_BUS_IF					),//Slave		
// DDR3 Init Done IF															
	.DDR4_0_INIT_DONE				( DDR4_0_INIT_DONE				),//i 			
	.DDR4_1_INIT_DONE				( DDR4_1_INIT_DONE				),//i 			
// DDR TEST Interface															
	.DDR_TEST_IF0					( DDR_TEST_IF0					),//				
	.DDR_TEST_IF1					( DDR_TEST_IF1					),//				
	.DDR_TEST_IF2					( DDR_TEST_IF2					),//				
	.DDR_TEST_IF3					( DDR_TEST_IF3					) //				
);

//------------------------------------------------------------------------------
// U_DDR_0TEST Instance													
//------------------------------------------------------------------------------
DDR_TEST U_DDR_0TEST (															
	.CLK							( MEM0_CLK						),//i 						
	.RST							( MEM0_RST						),//i 						
	.DDR_TEST_IF					( DDR_TEST_IF0					),//Slave					
	.MEMW_BUS_IF					( MEMW_BUS_IF0					),//Master
	.MEMR_BUS_IF					( MEMR_BUS_IF0					) //Master	
);

//------------------------------------------------------------------------------
// U_DDR_1TEST Instance													
//------------------------------------------------------------------------------
DDR_TEST U_DDR_1TEST (														
	.CLK							( MEM0_CLK						),//i 						
	.RST							( MEM0_RST						),//i 						
	.DDR_TEST_IF					( DDR_TEST_IF1					),//Slave					
	.MEMW_BUS_IF					( MEMW_BUS_IF1					),//Master
	.MEMR_BUS_IF					( MEMR_BUS_IF1					) //Master	
);

//------------------------------------------------------------------------------
// U_DDR_0TEST Instance													
//------------------------------------------------------------------------------
DDR_TEST U_DDR_2TEST (															
	.CLK							( MEM1_CLK						),//i 						
	.RST							( MEM1_RST						),//i 						
	.DDR_TEST_IF					( DDR_TEST_IF2					),//Slave					
	.MEMW_BUS_IF					( MEMW_BUS_IF2					),//Master
	.MEMR_BUS_IF					( MEMR_BUS_IF2					) //Master	
);

//------------------------------------------------------------------------------
// U_DDR_1TEST Instance													
//------------------------------------------------------------------------------
DDR_TEST U_DDR_3TEST (															
	.CLK							( MEM1_CLK						),//i 						
	.RST							( MEM1_RST						),//i 						
	.DDR_TEST_IF					( DDR_TEST_IF3					),//Slave					
	.MEMW_BUS_IF					( MEMW_BUS_IF3					),//Master
	.MEMR_BUS_IF					( MEMR_BUS_IF3					) //Master	
);
	
//------------------------------------------------------------------------------
// U_MEM_WR_IF_CTRL0 Instance													
//------------------------------------------------------------------------------
MEM_WR_IF_CTRL U_MEM_WR_IF_CTRL00 (												
// Clock & Reset																	
	.CLK							( w_ui0_clk						),//i 			
	.RST							( w_ui0_rst						),//i 			
//Port0														 						
	.MEMW_BUS_00					( MEMW_BUS_00					),//Slave		
	.MEMW_BUS_01					( MEMW_BUS_01					),//Slave		
	.MEMW_BUS_02					( MEMW_BUS_02					),//Slave		
	.MEMW_BUS_03					( MEMW_BUS_03					),//Slave		
	.MEMW_BUS_04					( MEMW_BUS_04					),//Slave		
	.MEMW_BUS_05					( MEMW_BUS_05					),//Slave		
	.MEMW_BUS_06					( MEMW_BUS_06					),//Slave		
	.MEMW_BUS_07					( MEMW_BUS_07					),//Slave		
	.MEMW_BUS_08					( MEMW_BUS_IF0					),//Slave		
	.MEMW_BUS_09					( MEMW_BUS_IF1					),//Slave		
// AXI4 Write Master Interface														
	.M_AXI_AWID						( w_m0_c0_axi_awid				),//o [  3:0] 	
	.M_AXI_AWADDR					( w_m0_c0_axi_awaddr			),//o [ 31:0]	
	.M_AXI_AWLEN					( w_m0_c0_axi_awlen				),//o [  7:0]	
	.M_AXI_AWSIZE					( w_m0_c0_axi_awsize			),//o [  2:0]	
	.M_AXI_AWBURST					( w_m0_c0_axi_awburst			),//o [  1:0] 	
	.M_AXI_AWLOCK					( w_m0_c0_axi_awlock			),//o 			
	.M_AXI_AWCACHE					( w_m0_c0_axi_awcache			),//o [  3:0]	
	.M_AXI_AWPROT					( w_m0_c0_axi_awprot			),//o [  2:0]	
	.M_AXI_AWQOS					( w_m0_c0_axi_awqos				),//o [  3:0]	
	.M_AXI_AWVALID					( w_m0_c0_axi_awvalid			),//o 			
	.M_AXI_AWREADY					( w_m0_c0_axi_awready			),//i 			
	.M_AXI_WDATA					( w_m0_c0_axi_wdata				),//o [511:0]	
	.M_AXI_WSTRB					( w_m0_c0_axi_wstrb				),//o [ 63:0]	
	.M_AXI_WLAST					( w_m0_c0_axi_wlast				),//o 		 	
	.M_AXI_WVALID					( w_m0_c0_axi_wvalid			),//o 		 	
	.M_AXI_WREADY					( w_m0_c0_axi_wready			),//i 		 	
	.M_AXI_BID						( w_m0_c0_axi_bid				),//i [  3:0]	
	.M_AXI_BRESP					( w_m0_c0_axi_bresp				),//i [  1:0]	
	.M_AXI_BVALID					( w_m0_c0_axi_bvalid			),//i 			
	.M_AXI_BREADY					( w_m0_c0_axi_bready			) //o 			
);																				
																				
																				
//------------------------------------------------------------------------------
// U_MEM_RD_IF_CTRL0 Instance													
//------------------------------------------------------------------------------
MEM_RD_IF_CTRL U_MEM_RD_IF_CTRL00 (												
// Clock & Reset																	
	.CLK							( w_ui0_clk						),//i 			
	.RST							( w_ui0_rst						),//i 			
//Port0													 							
	.MEMR_BUS_00					( MEMR_BUS_00					),//Slave		
	.MEMR_BUS_01					( MEMR_BUS_01					),//Slave		
	.MEMR_BUS_02					( MEMR_BUS_02					),//Slave		
	.MEMR_BUS_03					( MEMR_BUS_03					),//Slave		
	.MEMR_BUS_04					( MEMR_BUS_04					),//Slave		
	.MEMR_BUS_05					( MEMR_BUS_05					),//Slave		
	.MEMR_BUS_06					( MEMR_BUS_06					),//Slave		
	.MEMR_BUS_07					( MEMR_BUS_07					),//Slave		
	.MEMR_BUS_08					( MEMR_BUS_IF0					),//Slave		
	.MEMR_BUS_09					( MEMR_BUS_IF1					),//Slave		
// AXI4 Read Master Interface														
	.M_AXI_ARID						( w_m0_c0_axi_arid				),//o [  3:0] 	
	.M_AXI_ARADDR					( w_m0_c0_axi_araddr			),//o [ 31:0] 	
	.M_AXI_ARLEN					( w_m0_c0_axi_arlen				),//o [  7:0] 	
	.M_AXI_ARSIZE					( w_m0_c0_axi_arsize			),//o [  2:0] 	
	.M_AXI_ARBURST					( w_m0_c0_axi_arburst			),//o [  1:0] 	
	.M_AXI_ARLOCK					( w_m0_c0_axi_arlock			),//o 		  	
	.M_AXI_ARCACHE					( w_m0_c0_axi_arcache			),//o [  3:0] 	
	.M_AXI_ARPROT					( w_m0_c0_axi_arprot			),//o [  2:0] 	
	.M_AXI_ARQOS					( w_m0_c0_axi_arqos				),//o [  3:0] 	
	.M_AXI_ARVALID					( w_m0_c0_axi_arvalid			),//o 			
	.M_AXI_ARREADY					( w_m0_c0_axi_arready			),//i 			
	.M_AXI_RID						( w_m0_c0_axi_rid				),//i [  3:0] 	
	.M_AXI_RDATA					( w_m0_c0_axi_rdata				),//i [511:0] 	
	.M_AXI_RRESP					( w_m0_c0_axi_rresp				),//i [  1:0] 	
	.M_AXI_RLAST					( w_m0_c0_axi_rlast				),//i 			
	.M_AXI_RVALID					( w_m0_c0_axi_rvalid			),//i 			
	.M_AXI_RREADY					( w_m0_c0_axi_rready			) //o 			
);																				


//------------------------------------------------------------------------------
// U_MEM_WR_IF_CTRL0 Instance													
//------------------------------------------------------------------------------
MEM_WR_IF_CTRL U_MEM_WR_IF_CTRL10 (												
// Clock & Reset																	
	.CLK							( w_ui1_clk						),//i 			
	.RST							( w_ui1_rst						),//i 			
//Port0														 						
	.MEMW_BUS_00					( MEMW_BUS_10					),//Slave		
	.MEMW_BUS_01					( MEMW_BUS_11					),//Slave		
	.MEMW_BUS_02					( MEMW_BUS_12					),//Slave		
	.MEMW_BUS_03					( MEMW_BUS_13					),//Slave		
	.MEMW_BUS_04					( MEMW_BUS_14					),//Slave		
	.MEMW_BUS_05					( MEMW_BUS_15					),//Slave		
	.MEMW_BUS_06					( MEMW_BUS_16					),//Slave		
	.MEMW_BUS_07					( MEMW_BUS_17					),//Slave		
	.MEMW_BUS_08					( MEMW_BUS_IF2					),//Slave		
	.MEMW_BUS_09					( MEMW_BUS_IF3					),//Slave		
// AXI4 Write Master Interface														
	.M_AXI_AWID						( w_m0_c1_axi_awid				),//o [  3:0] 	
	.M_AXI_AWADDR					( w_m0_c1_axi_awaddr			),//o [ 31:0]	
	.M_AXI_AWLEN					( w_m0_c1_axi_awlen				),//o [  7:0]	
	.M_AXI_AWSIZE					( w_m0_c1_axi_awsize			),//o [  2:0]	
	.M_AXI_AWBURST					( w_m0_c1_axi_awburst			),//o [  1:0] 	
	.M_AXI_AWLOCK					( w_m0_c1_axi_awlock			),//o 			
	.M_AXI_AWCACHE					( w_m0_c1_axi_awcache			),//o [  3:0]	
	.M_AXI_AWPROT					( w_m0_c1_axi_awprot			),//o [  2:0]	
	.M_AXI_AWQOS					( w_m0_c1_axi_awqos				),//o [  3:0]	
	.M_AXI_AWVALID					( w_m0_c1_axi_awvalid			),//o 			
	.M_AXI_AWREADY					( w_m0_c1_axi_awready			),//i 			
	.M_AXI_WDATA					( w_m0_c1_axi_wdata				),//o [511:0]	
	.M_AXI_WSTRB					( w_m0_c1_axi_wstrb				),//o [ 63:0]	
	.M_AXI_WLAST					( w_m0_c1_axi_wlast				),//o 		 	
	.M_AXI_WVALID					( w_m0_c1_axi_wvalid			),//o 		 	
	.M_AXI_WREADY					( w_m0_c1_axi_wready			),//i 		 	
	.M_AXI_BID						( w_m0_c1_axi_bid				),//i [  3:0]	
	.M_AXI_BRESP					( w_m0_c1_axi_bresp				),//i [  1:0]	
	.M_AXI_BVALID					( w_m0_c1_axi_bvalid			),//i 			
	.M_AXI_BREADY					( w_m0_c1_axi_bready			) //o 			
);																				
																				
																				
//------------------------------------------------------------------------------
// U_MEM_RD_IF_CTRL0 Instance													
//------------------------------------------------------------------------------
MEM_RD_IF_CTRL U_MEM_RD_IF_CTRL10 (												
// Clock & Reset																	
	.CLK							( w_ui1_clk						),//i 			
	.RST							( w_ui1_rst						),//i 			
//Port0													 							
	.MEMR_BUS_00					( MEMR_BUS_10					),//Slave		
	.MEMR_BUS_01					( MEMR_BUS_11					),//Slave		
	.MEMR_BUS_02					( MEMR_BUS_12					),//Slave		
	.MEMR_BUS_03					( MEMR_BUS_13					),//Slave		
	.MEMR_BUS_04					( MEMR_BUS_14					),//Slave		
	.MEMR_BUS_05					( MEMR_BUS_15					),//Slave		
	.MEMR_BUS_06					( MEMR_BUS_16					),//Slave		
	.MEMR_BUS_07					( MEMR_BUS_17					),//Slave		
	.MEMR_BUS_08					( MEMR_BUS_IF2					),//Slave		
	.MEMR_BUS_09					( MEMR_BUS_IF3					),//Slave		
// AXI4 Read Master Interface														
	.M_AXI_ARID						( w_m0_c1_axi_arid				),//o [  3:0] 	
	.M_AXI_ARADDR					( w_m0_c1_axi_araddr			),//o [ 31:0] 	
	.M_AXI_ARLEN					( w_m0_c1_axi_arlen				),//o [  7:0] 	
	.M_AXI_ARSIZE					( w_m0_c1_axi_arsize			),//o [  2:0] 	
	.M_AXI_ARBURST					( w_m0_c1_axi_arburst			),//o [  1:0] 	
	.M_AXI_ARLOCK					( w_m0_c1_axi_arlock			),//o 		  	
	.M_AXI_ARCACHE					( w_m0_c1_axi_arcache			),//o [  3:0] 	
	.M_AXI_ARPROT					( w_m0_c1_axi_arprot			),//o [  2:0] 	
	.M_AXI_ARQOS					( w_m0_c1_axi_arqos				),//o [  3:0] 	
	.M_AXI_ARVALID					( w_m0_c1_axi_arvalid			),//o 			
	.M_AXI_ARREADY					( w_m0_c1_axi_arready			),//i 			
	.M_AXI_RID						( w_m0_c1_axi_rid				),//i [  3:0] 	
	.M_AXI_RDATA					( w_m0_c1_axi_rdata				),//i [511:0] 	
	.M_AXI_RRESP					( w_m0_c1_axi_rresp				),//i [  1:0] 	
	.M_AXI_RLAST					( w_m0_c1_axi_rlast				),//i 			
	.M_AXI_RVALID					( w_m0_c1_axi_rvalid			),//i 			
	.M_AXI_RREADY					( w_m0_c1_axi_rready			) //o 			
);																					

assign	MEM0_CLK = w_ui0_clk;
assign	MEM0_RST = w_ui0_rst;
assign	MEM1_CLK = w_ui1_clk;
assign	MEM1_RST = w_ui1_rst;

// Debug Bus
	wire [511:0]                         dbg_bus0;        
	wire [511:0]                         dbg_bus1;        

`ifndef SIM																		
//------------------------------------------------------------------------------
// MIG with Two Controller Instance												
//------------------------------------------------------------------------------
ddr4_if u_ddr4_if0 (																	
	.sys_rst						( DDR4_RST_IN					),
	.c0_sys_clk_i                   ( DDR4_0_CLK_IN					),
	.c0_init_calib_complete			( DDR4_0_INIT_DONE				),
// DDR4 Pins																		
	.c0_ddr4_act_n          		( DDR4_BUS_IF0.ddr4_act_n   	),
	.c0_ddr4_adr            		( DDR4_BUS_IF0.ddr4_adr     	),
	.c0_ddr4_ba             		( DDR4_BUS_IF0.ddr4_ba      	),
	.c0_ddr4_bg             		( DDR4_BUS_IF0.ddr4_bg      	),
	.c0_ddr4_cke            		( DDR4_BUS_IF0.ddr4_cke     	),
	.c0_ddr4_odt            		( DDR4_BUS_IF0.ddr4_odt     	),
	.c0_ddr4_cs_n           		( DDR4_BUS_IF0.ddr4_cs_n    	),
	.c0_ddr4_ck_t           		( DDR4_BUS_IF0.ddr4_ck_t    	),
	.c0_ddr4_ck_c           		( DDR4_BUS_IF0.ddr4_ck_c    	),
	.c0_ddr4_reset_n        		( DDR4_BUS_IF0.ddr4_reset_n 	),
	.c0_ddr4_dm_dbi_n       		( DDR4_BUS_IF0.ddr4_dm_dbi_n	),
	.c0_ddr4_dq             		( DDR4_BUS_IF0.ddr4_dq      	),
	.c0_ddr4_dqs_c          		( DDR4_BUS_IF0.ddr4_dqs_c   	),
	.c0_ddr4_dqs_t          		( DDR4_BUS_IF0.ddr4_dqs_t   	),
// user interface signals															
	.c0_ddr4_ui_clk					( w_ui0_clk						),//o 			
	.c0_ddr4_ui_clk_sync_rst		( w_ui0_rst						),//o 			
	.dbg_clk						( 1'b0							),//i 
// Slave Interface Write Address Ports											
	.c0_ddr4_aresetn				( 1'b1							),//i 			
	.c0_ddr4_s_axi_awid				( w_m0_c0_axi_awid[3:0]			),//i [ 7:0]	
	.c0_ddr4_s_axi_awaddr			( w_m0_c0_axi_awaddr[31:0]		),//i [30:0]	
	.c0_ddr4_s_axi_awlen			( w_m0_c0_axi_awlen				),//i [ 7:0]	
	.c0_ddr4_s_axi_awsize			( w_m0_c0_axi_awsize			),//i [ 2:0]	
	.c0_ddr4_s_axi_awburst			( w_m0_c0_axi_awburst			),//i [ 1:0]	
	.c0_ddr4_s_axi_awlock			( w_m0_c0_axi_awlock			),//i [ 0:0]	
	.c0_ddr4_s_axi_awcache			( w_m0_c0_axi_awcache			),//i [ 3:0]	
	.c0_ddr4_s_axi_awprot			( w_m0_c0_axi_awprot			),//i [ 2:0]	
	.c0_ddr4_s_axi_awqos			( w_m0_c0_axi_awqos				),//i [ 3:0]	
	.c0_ddr4_s_axi_awvalid			( w_m0_c0_axi_awvalid			),//i 			
	.c0_ddr4_s_axi_awready			( w_m0_c0_axi_awready			),//o 			
 // Slave Interface Write Data Ports											
	.c0_ddr4_s_axi_wdata			( w_m0_c0_axi_wdata				),//i [511:0]	
	.c0_ddr4_s_axi_wstrb			( w_m0_c0_axi_wstrb				),//i [ 63:0]	
	.c0_ddr4_s_axi_wlast			( w_m0_c0_axi_wlast				),//i 			
	.c0_ddr4_s_axi_wvalid			( w_m0_c0_axi_wvalid			),//i 			
	.c0_ddr4_s_axi_wready			( w_m0_c0_axi_wready			),//o 			
 // Slave Interface Write Response Ports										
	.c0_ddr4_s_axi_bready			( w_m0_c0_axi_bready			),//i 			
	.c0_ddr4_s_axi_bid				( w_m0_c0_axi_bid[3:0]			),//o [3:0]		
	.c0_ddr4_s_axi_bresp			( w_m0_c0_axi_bresp				),//o [1:0]		
	.c0_ddr4_s_axi_bvalid			( w_m0_c0_axi_bvalid			),//o 			
// Slave Interface Read Address Ports											
	.c0_ddr4_s_axi_arid				( w_m0_c0_axi_arid[3:0]			),//i [ 3:0]	
	.c0_ddr4_s_axi_araddr			( w_m0_c0_axi_araddr[31:0]		),//i [30:0]	
	.c0_ddr4_s_axi_arlen			( w_m0_c0_axi_arlen				),//i [ 7:0]	
	.c0_ddr4_s_axi_arsize			( w_m0_c0_axi_arsize			),//i [ 2:0]	
	.c0_ddr4_s_axi_arburst			( w_m0_c0_axi_arburst			),//i [ 1:0]	
	.c0_ddr4_s_axi_arlock			( w_m0_c0_axi_arlock			),//i [ 0:0]	
	.c0_ddr4_s_axi_arcache			( w_m0_c0_axi_arcache			),//i [ 3:0]	
	.c0_ddr4_s_axi_arprot			( w_m0_c0_axi_arprot			),//i [ 2:0]	
	.c0_ddr4_s_axi_arqos			( w_m0_c0_axi_arqos				),//i [ 3:0]	
	.c0_ddr4_s_axi_arvalid			( w_m0_c0_axi_arvalid			),//i       	
	.c0_ddr4_s_axi_arready			( w_m0_c0_axi_arready			),//o       	
// Slave Interface Read Data Ports												
	.c0_ddr4_s_axi_rready			( w_m0_c0_axi_rready			),//i 			
	.c0_ddr4_s_axi_rid				( w_m0_c0_axi_rid[3:0]			),//o [  3:0]	
	.c0_ddr4_s_axi_rdata			( w_m0_c0_axi_rdata				),//o [511:0]	
	.c0_ddr4_s_axi_rresp			( w_m0_c0_axi_rresp				),//o [  1:0]	
	.c0_ddr4_s_axi_rlast			( w_m0_c0_axi_rlast				),//o 			
	.c0_ddr4_s_axi_rvalid			( w_m0_c0_axi_rvalid			),//o 			
	
// Debug Port
	.dbg_bus       				  	( dbg_bus0						)                                             
);

ddr4_if u_ddr4_if1 (																	
	.sys_rst						( DDR4_RST_IN					),
	.c0_sys_clk_i                   ( DDR4_1_CLK_IN					),
	.c0_init_calib_complete			( DDR4_1_INIT_DONE				),
// DDR4 Pins																		
	.c0_ddr4_act_n          		( DDR4_BUS_IF1.ddr4_act_n   	),
	.c0_ddr4_adr            		( DDR4_BUS_IF1.ddr4_adr     	),
	.c0_ddr4_ba             		( DDR4_BUS_IF1.ddr4_ba      	),
	.c0_ddr4_bg             		( DDR4_BUS_IF1.ddr4_bg      	),
	.c0_ddr4_cke            		( DDR4_BUS_IF1.ddr4_cke     	),
	.c0_ddr4_odt            		( DDR4_BUS_IF1.ddr4_odt     	),
	.c0_ddr4_cs_n           		( DDR4_BUS_IF1.ddr4_cs_n    	),
	.c0_ddr4_ck_t           		( DDR4_BUS_IF1.ddr4_ck_t    	),
	.c0_ddr4_ck_c           		( DDR4_BUS_IF1.ddr4_ck_c    	),
	.c0_ddr4_reset_n        		( DDR4_BUS_IF1.ddr4_reset_n 	),
	.c0_ddr4_dm_dbi_n       		( DDR4_BUS_IF1.ddr4_dm_dbi_n	),
	.c0_ddr4_dq             		( DDR4_BUS_IF1.ddr4_dq      	),
	.c0_ddr4_dqs_c          		( DDR4_BUS_IF1.ddr4_dqs_c   	),
	.c0_ddr4_dqs_t          		( DDR4_BUS_IF1.ddr4_dqs_t   	),
// user interface signals															
	.c0_ddr4_ui_clk					( w_ui1_clk						),//o 			
	.c0_ddr4_ui_clk_sync_rst		( w_ui1_rst						),//o 			
	.dbg_clk						( 1'b0							),//i 
// Slave Interface Write Address Ports											
	.c0_ddr4_aresetn				( 1'b1							),//i 			
	.c0_ddr4_s_axi_awid				( w_m0_c1_axi_awid[3:0]			),//i [ 7:0]	
	.c0_ddr4_s_axi_awaddr			( w_m0_c1_axi_awaddr[31:0]		),//i [30:0]	
	.c0_ddr4_s_axi_awlen			( w_m0_c1_axi_awlen				),//i [ 7:0]	
	.c0_ddr4_s_axi_awsize			( w_m0_c1_axi_awsize			),//i [ 2:0]	
	.c0_ddr4_s_axi_awburst			( w_m0_c1_axi_awburst			),//i [ 1:0]	
	.c0_ddr4_s_axi_awlock			( w_m0_c1_axi_awlock			),//i [ 0:0]	
	.c0_ddr4_s_axi_awcache			( w_m0_c1_axi_awcache			),//i [ 3:0]	
	.c0_ddr4_s_axi_awprot			( w_m0_c1_axi_awprot			),//i [ 2:0]	
	.c0_ddr4_s_axi_awqos			( w_m0_c1_axi_awqos				),//i [ 3:0]	
	.c0_ddr4_s_axi_awvalid			( w_m0_c1_axi_awvalid			),//i 			
	.c0_ddr4_s_axi_awready			( w_m0_c1_axi_awready			),//o 			
 // Slave Interface Write Data Ports											
	.c0_ddr4_s_axi_wdata			( w_m0_c1_axi_wdata				),//i [511:0]	
	.c0_ddr4_s_axi_wstrb			( w_m0_c1_axi_wstrb				),//i [ 63:0]	
	.c0_ddr4_s_axi_wlast			( w_m0_c1_axi_wlast				),//i 			
	.c0_ddr4_s_axi_wvalid			( w_m0_c1_axi_wvalid			),//i 			
	.c0_ddr4_s_axi_wready			( w_m0_c1_axi_wready			),//o 			
 // Slave Interface Write Response Ports										
	.c0_ddr4_s_axi_bready			( w_m0_c1_axi_bready			),//i 			
	.c0_ddr4_s_axi_bid				( w_m0_c1_axi_bid[3:0]			),//o [3:0]		
	.c0_ddr4_s_axi_bresp			( w_m0_c1_axi_bresp				),//o [1:0]		
	.c0_ddr4_s_axi_bvalid			( w_m0_c1_axi_bvalid			),//o 			
// Slave Interface Read Address Ports											
	.c0_ddr4_s_axi_arid				( w_m0_c1_axi_arid[3:0]			),//i [ 3:0]	
	.c0_ddr4_s_axi_araddr			( w_m0_c1_axi_araddr[31:0]		),//i [30:0]	
	.c0_ddr4_s_axi_arlen			( w_m0_c1_axi_arlen				),//i [ 7:0]	
	.c0_ddr4_s_axi_arsize			( w_m0_c1_axi_arsize			),//i [ 2:0]	
	.c0_ddr4_s_axi_arburst			( w_m0_c1_axi_arburst			),//i [ 1:0]	
	.c0_ddr4_s_axi_arlock			( w_m0_c1_axi_arlock			),//i [ 0:0]	
	.c0_ddr4_s_axi_arcache			( w_m0_c1_axi_arcache			),//i [ 3:0]	
	.c0_ddr4_s_axi_arprot			( w_m0_c1_axi_arprot			),//i [ 2:0]	
	.c0_ddr4_s_axi_arqos			( w_m0_c1_axi_arqos				),//i [ 3:0]	
	.c0_ddr4_s_axi_arvalid			( w_m0_c1_axi_arvalid			),//i       	
	.c0_ddr4_s_axi_arready			( w_m0_c1_axi_arready			),//o       	
// Slave Interface Read Data Ports												
	.c0_ddr4_s_axi_rready			( w_m0_c1_axi_rready			),//i 			
	.c0_ddr4_s_axi_rid				( w_m0_c1_axi_rid[3:0]			),//o [  3:0]	
	.c0_ddr4_s_axi_rdata			( w_m0_c1_axi_rdata				),//o [511:0]	
	.c0_ddr4_s_axi_rresp			( w_m0_c1_axi_rresp				),//o [  1:0]	
	.c0_ddr4_s_axi_rlast			( w_m0_c1_axi_rlast				),//o 			
	.c0_ddr4_s_axi_rvalid			( w_m0_c1_axi_rvalid			),//o 			
	
// Debug Port
	.dbg_bus       				  	( dbg_bus1						)                                             
);																			
`else																			
//------------------------------------------------------------------------------
// U_MIG_TOP0 Instance	From SIM												
//------------------------------------------------------------------------------
DDR3Model # (
	.C_AXI_DATA_WIDTH				( 512							),
	.C_AXI_ID_WIDTH					( 4								)	
) U_MIG_TOP0 (																
	.s_axi_clk             			( w_ui0_clk             		),//(o) [  1]	
	.s_axi_rst             			( w_ui0_rst             		),//(o) [  1]	
	.s_axi_awid            			( w_m0_c0_axi_awid      		),//(i) [  4]	
	.s_axi_awaddr          			( w_m0_c0_axi_awaddr    		),//(i) [ 32]	
	.s_axi_awlen           			( w_m0_c0_axi_awlen     		),//(i) [  8]	
	.s_axi_awsize          			( w_m0_c0_axi_awsize    		),//(i) [  3]	
	.s_axi_awburst         			( w_m0_c0_axi_awburst   		),//(i) [  2]	
	.s_axi_awlock          			( w_m0_c0_axi_awlock    		),//(i) [  1]	
	.s_axi_awcache         			( w_m0_c0_axi_awcache   		),//(i) [  4]	
	.s_axi_awprot          			( w_m0_c0_axi_awprot    		),//(i) [  3]	
	.s_axi_awqos           			( w_m0_c0_axi_awqos     		),//(i) [  4]	
	.s_axi_awvalid         			( w_m0_c0_axi_awvalid   		),//(i) [  1]	
	.s_axi_awready         			( w_m0_c0_axi_awready   		),//(o) [  1]	
	.s_axi_wdata           			( w_m0_c0_axi_wdata     		),//(i) [256]	
	.s_axi_wstrb           			( w_m0_c0_axi_wstrb     		),//(i) [ 32]	
	.s_axi_wlast           			( w_m0_c0_axi_wlast     		),//(i) [  1]	
	.s_axi_wvalid          			( w_m0_c0_axi_wvalid    		),//(i) [  1]	
	.s_axi_wready          			( w_m0_c0_axi_wready    		),//(o) [  1]	
	.s_axi_bid             			( w_m0_c0_axi_bid       		),//(o) [  4]	
	.s_axi_bresp           			( w_m0_c0_axi_bresp     		),//(o) [  2]	
	.s_axi_bvalid          			( w_m0_c0_axi_bvalid    		),//(o) [  1]	
	.s_axi_bready          			( w_m0_c0_axi_bready    		),//(i) [  1]	
	.s_axi_arid            			( w_m0_c0_axi_arid      		),//(i) [  4]	
	.s_axi_araddr          			( w_m0_c0_axi_araddr    		),//(i) [ 32]	
	.s_axi_arlen           			( w_m0_c0_axi_arlen     		),//(i) [  8]	
	.s_axi_arsize          			( w_m0_c0_axi_arsize    		),//(i) [  3]	
	.s_axi_arburst         			( w_m0_c0_axi_arburst   		),//(i) [  2]	
	.s_axi_arlock          			( w_m0_c0_axi_arlock    		),//(i) [  1]	
	.s_axi_arcache         			( w_m0_c0_axi_arcache   		),//(i) [  4]	
	.s_axi_arprot          			( w_m0_c0_axi_arprot    		),//(i) [  3]	
	.s_axi_arqos           			( w_m0_c0_axi_arqos     		),//(i) [  4]	
	.s_axi_arvalid         			( w_m0_c0_axi_arvalid   		),//(i) [  1]	
	.s_axi_arready         			( w_m0_c0_axi_arready   		),//(o) [  1]	
	.s_axi_rid             			( w_m0_c0_axi_rid       		),//(o) [  4]	
	.s_axi_rdata           			( w_m0_c0_axi_rdata     		),//(o) [256]	
	.s_axi_rresp           			( w_m0_c0_axi_rresp     		),//(o) [  2]	
	.s_axi_rlast           			( w_m0_c0_axi_rlast     		),//(o) [  1]	
	.s_axi_rvalid          			( w_m0_c0_axi_rvalid    		),//(o) [  1]	
	.phy_init_done         			( DDR3_0_INIT_DONE				),//(o) [  1]	
	.s_axi_rready          			( w_m0_c0_axi_rready       		) //(i) [  1]	
);															 					

DDR3Model # (
	.C_AXI_DATA_WIDTH				( 512							),
	.C_AXI_ID_WIDTH					( 4								)	
) U_MIG_TOP1 (																
	.s_axi_clk             			( w_ui1_clk             		),//(o) [  1]	
	.s_axi_rst             			( w_ui1_rst             		),//(o) [  1]	
	.s_axi_awid            			( w_m0_c1_axi_awid      		),//(i) [  4]	
	.s_axi_awaddr          			( w_m0_c1_axi_awaddr    		),//(i) [ 32]	
	.s_axi_awlen           			( w_m0_c1_axi_awlen     		),//(i) [  8]	
	.s_axi_awsize          			( w_m0_c1_axi_awsize    		),//(i) [  3]	
	.s_axi_awburst         			( w_m0_c1_axi_awburst   		),//(i) [  2]	
	.s_axi_awlock          			( w_m0_c1_axi_awlock    		),//(i) [  1]	
	.s_axi_awcache         			( w_m0_c1_axi_awcache   		),//(i) [  4]	
	.s_axi_awprot          			( w_m0_c1_axi_awprot    		),//(i) [  3]	
	.s_axi_awqos           			( w_m0_c1_axi_awqos     		),//(i) [  4]	
	.s_axi_awvalid         			( w_m0_c1_axi_awvalid   		),//(i) [  1]	
	.s_axi_awready         			( w_m0_c1_axi_awready   		),//(o) [  1]	
	.s_axi_wdata           			( w_m0_c1_axi_wdata     		),//(i) [256]	
	.s_axi_wstrb           			( w_m0_c1_axi_wstrb     		),//(i) [ 32]	
	.s_axi_wlast           			( w_m0_c1_axi_wlast     		),//(i) [  1]	
	.s_axi_wvalid          			( w_m0_c1_axi_wvalid    		),//(i) [  1]	
	.s_axi_wready          			( w_m0_c1_axi_wready    		),//(o) [  1]	
	.s_axi_bid             			( w_m0_c1_axi_bid       		),//(o) [  4]	
	.s_axi_bresp           			( w_m0_c1_axi_bresp     		),//(o) [  2]	
	.s_axi_bvalid          			( w_m0_c1_axi_bvalid    		),//(o) [  1]	
	.s_axi_bready          			( w_m0_c1_axi_bready    		),//(i) [  1]	
	.s_axi_arid            			( w_m0_c1_axi_arid      		),//(i) [  4]	
	.s_axi_araddr          			( w_m0_c1_axi_araddr    		),//(i) [ 32]	
	.s_axi_arlen           			( w_m0_c1_axi_arlen     		),//(i) [  8]	
	.s_axi_arsize          			( w_m0_c1_axi_arsize    		),//(i) [  3]	
	.s_axi_arburst         			( w_m0_c1_axi_arburst   		),//(i) [  2]	
	.s_axi_arlock          			( w_m0_c1_axi_arlock    		),//(i) [  1]	
	.s_axi_arcache         			( w_m0_c1_axi_arcache   		),//(i) [  4]	
	.s_axi_arprot          			( w_m0_c1_axi_arprot    		),//(i) [  3]	
	.s_axi_arqos           			( w_m0_c1_axi_arqos     		),//(i) [  4]	
	.s_axi_arvalid         			( w_m0_c1_axi_arvalid   		),//(i) [  1]	
	.s_axi_arready         			( w_m0_c1_axi_arready   		),//(o) [  1]	
	.s_axi_rid             			( w_m0_c1_axi_rid       		),//(o) [  4]	
	.s_axi_rdata           			( w_m0_c1_axi_rdata     		),//(o) [256]	
	.s_axi_rresp           			( w_m0_c1_axi_rresp     		),//(o) [  2]	
	.s_axi_rlast           			( w_m0_c1_axi_rlast     		),//(o) [  1]	
	.s_axi_rvalid          			( w_m0_c1_axi_rvalid    		),//(o) [  1]	
	.phy_init_done         			( DDR3_1_INIT_DONE				),//(o) [  1]	
	.s_axi_rready          			( w_m0_c1_axi_rready       		) //(i) [  1]	
);

`endif																			
																				
endmodule																		