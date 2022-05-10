module DAC_TOP (
// Reference Clock 
	input								DAC1_REF_CLKP						,//i 
	input								DAC1_REF_CLKN						,//i 
	input								DAC2_REF_CLKP						,//i 
	input								DAC2_REF_CLKN						,//i 

///USER interface
    output                             DAC_CLK,
    output                             DAC_READY,	
    output                             DAC_LMFC,
	
// Registers Access IF																
	REG_BUS.slave						REG_BUS_IF							,//Slave
// Power On 
	output								ADC_PWR_EN							,//o 		
	output	[ 3:0]						PWR_EN_ADC							,//o 		
// Debug Port Output
	output	[  3:0]						DB_CLK_PORT							,//o [  3:0]
// DAC Data IF
	input	[127:0]						DAC_DATA0							,//i [255:0]	
	input	[127:0]						DAC_DATA1							,//i [255:0]	
	input	[127:0]						DAC_DATA2							,//i [255:0]	
	input	[127:0]						DAC_DATA3							,//i [255:0]	
// DAC Config Interface
	DAC_CFG_BUS.master					DAC_CFG_IF0							,//
	DAC_CFG_BUS.master					DAC_CFG_IF1							,//
	DAC_CFG_BUS.master					DAC_CFG_IF2							,//
	DAC_CFG_BUS.master					DAC_CFG_IF3							,//
// DAC-JESD204B Interface
	DAC_204_BUS.master					DAC_204_IF0							,//
	DAC_204_BUS.master					DAC_204_IF1							,//
	DAC_204_BUS.master					DAC_204_IF2							,//
	DAC_204_BUS.master					DAC_204_IF3							 //
);

wire									w_TX0_SYSREF						;
wire									w_TX1_SYSREF						;
wire									w_TX0_SYNC							;
wire									w_TX1_SYNC							; 
wire									w_refclk0							;
wire									w_glbclk0							;
wire									w_glbclk0_i							;
wire									w_refclk1							;
wire									w_glbclk1							;
wire									w_glbclk1_i							;
wire									w_tx0_aresetn						;//          
wire	[  3:0]							w_tx0_start_of_frame				;//  [  3:0] 
wire	[  3:0]							w_tx0_start_of_multiframe			;//  [  3:0] 
wire									w_tx0_tready						;//          
wire									w_tx1_aresetn						;//          
wire	[  3:0]							w_tx1_start_of_frame				;//  [  3:0] 
wire	[  3:0]							w_tx1_start_of_multiframe			;//  [  3:0] 
wire									w_tx1_tready						;//          
wire									w_tx2_aresetn						;//          
wire	[  3:0]							w_tx2_start_of_frame				;//  [  3:0] 
wire	[  3:0]							w_tx2_start_of_multiframe			;//  [  3:0] 
wire									w_tx2_tready						;//          
wire									w_tx3_aresetn						;//          
wire	[  3:0]							w_tx3_start_of_frame				;//  [  3:0] 
wire	[  3:0]							w_tx3_start_of_multiframe			;//  [  3:0] 
wire									w_tx3_tready						;//          
wire									w_DAC_TST_SEL						;
wire	[127:0]							w_DAC_TST_DAT						;
reg		[127:0]							r_tx0_tdata							;
reg		[127:0]							r_tx1_tdata							;
reg		[127:0]							r_tx2_tdata							;
reg		[127:0]							r_tx3_tdata							;
wire	[127:0]							w_tx0_tdata							;
wire	[127:0]							w_tx1_tdata							;
wire	[127:0]							w_tx2_tdata							;
wire	[127:0]							w_tx3_tdata							;
wire									w_DAC_LMFC							;

assign DAC_LMFC = w_DAC_LMFC;
assign DAC_READY = w_tx3_tready & w_tx2_tready & w_tx1_tready & w_tx0_tready;
assign DAC_CLK = w_glbclk1;


SPI_LB_BUS # (
	.P_ADDR_WIDTH						( 7								),
	.P_DATA_WIDTH						( 16							)
)  SPI_LB_IF[3:0] () ;


(*keep="true"*)IBUFDS_GTE3 # (
	.REFCLK_HROW_CK_SEL					( 2'b00								)
) ibufds_refclk1 (
	.O    								( w_refclk1							),
	.ODIV2								( w_glbclk1_i						),
	.CEB  								( 1'b0								),
	.I    								( DAC1_REF_CLKP						),
	.IB   								( DAC1_REF_CLKN						)
);

(*keep="true"*)IBUFDS_GTE3 # (
	.REFCLK_HROW_CK_SEL					( 2'b00								)
) ibufds_refclk2 (
	.O    								( w_refclk2							),
	.ODIV2								( w_glbclk2_i						),
	.CEB  								( 1'b0								),
	.I    								( DAC2_REF_CLKP						),
	.IB   								( DAC2_REF_CLKN						)
);

IBUFDS U0_IBUFDS (
	.I									( DAC_204_IF0.SYSREF_P				),
	.IB									( DAC_204_IF0.SYSREF_N				),
	.O									( w_TX0_SYSREF						) 
);

IBUFDS U1_IBUFDS (
	.I									( DAC_204_IF1.SYSREF_P				),
	.IB									( DAC_204_IF1.SYSREF_N				),
	.O									( w_TX1_SYSREF						) 
);

IBUFDS U2_IBUFDS (
	.I									( DAC_204_IF2.SYSREF_P				),
	.IB									( DAC_204_IF2.SYSREF_N				),
	.O									( w_TX2_SYSREF						) 
);

IBUFDS U3_IBUFDS (
	.I									( DAC_204_IF3.SYSREF_P				),
	.IB									( DAC_204_IF3.SYSREF_N				),
	.O									( w_TX3_SYSREF						) 
);

IBUFDS U4_IBUFDS (
	.I									( DAC_204_IF0.SYNC_P				),
	.IB									( DAC_204_IF0.SYNC_N				),
	.O									( w_TX0_SYNC						) 
);

IBUFDS U5_IBUFDS (
	.I									( DAC_204_IF1.SYNC_P				),
	.IB									( DAC_204_IF1.SYNC_N				),
	.O									( w_TX1_SYNC						) 
);

IBUFDS U6_IBUFDS (
	.I									( DAC_204_IF2.SYNC_P				),
	.IB									( DAC_204_IF2.SYNC_N				),
	.O									( w_TX2_SYNC						) 
);

IBUFDS U7_IBUFDS (
	.I									( DAC_204_IF3.SYNC_P				),
	.IB									( DAC_204_IF3.SYNC_N				),
	.O									( w_TX3_SYNC						) 
);


(*keep="true"*)BUFG_GT U6_BUFG (
	.O									( w_glbclk1							),
	.CE									( 1'b1								),
	.CEMASK								( 1'b0								),
	.CLR								( 1'b0								),
	.CLRMASK							( 1'b0								),
	.DIV								( 3'b0								),
	.I									( w_glbclk1_i						)
);

(*keep="true"*)BUFG_GT U7_BUFG (
	.O									( w_glbclk2							),
	.CE									( 1'b1								),
	.CEMASK								( 1'b0								),
	.CLR								( 1'b0								),
	.CLRMASK							( 1'b0								),
	.DIV								( 3'b0								),
	.I									( w_glbclk2_i						)
);


assign	DB_CLK_PORT[0] = w_glbclk1;
assign	DB_CLK_PORT[1] = w_glbclk2;
assign	DB_CLK_PORT[2] = w_TX0_SYSREF;
assign	DB_CLK_PORT[3] = w_TX1_SYSREF; 

wire		[4:0]	w_txpostcursor			;
wire		[4:0]	w_txprecursor			;	
wire		[3:0]	w_txdiffctrl			;
wire		[3:0]	w_AXI_LITE_ADDR			;
wire		[3:0]	w_CSn					;	
wire		[3:0]	w_SCLK					;	
wire		[3:0]	w_SDO					;	
wire		[3:0]	w_SDO_t					;	
wire		[3:0]	w_SDI					;	

DAC_REG U00_DAC_REG (														 				
// Registers Access IF																		
	.REG_BUS_IF							( REG_BUS_IF						),//Slave		
// DAC Async Reset Interface																
	.SOFT_RST							( w_SOFT_RST						),//o 			
// DAC Test Interface	
	.DAC_CLK							( w_glbclk1							),//i 	
	.DAC_TST_SEL						( w_DAC_TST_SEL						),//o 	
	.DAC_TST_DAT						( w_DAC_TST_DAT						),//o [127:0]
	.DAC_LMFC							( w_DAC_LMFC						),//i 
	.txpostcursor						( w_txpostcursor					),//o [ 4:0] 
	.txprecursor						( w_txprecursor						),//o [ 4:0] 
	.txdiffctrl							( w_txdiffctrl						),//o [ 3:0] 
	.AXI_LITE_ADDR						( w_AXI_LITE_ADDR					),//o [ 3:0]
// AD9173-0/1 Control Interface															
	.ADC_PWR_EN							( ADC_PWR_EN						),//o 			 
	.PWR_EN_ADC							( PWR_EN_ADC						),//o 			 
	.DA0_RESETn							( DAC_CFG_IF0.RESETn				),//o 			
	.DA0_TXENABLE						( DAC_CFG_IF0.TXENABLE				),//o 			
	.DA1_RESETn							( DAC_CFG_IF1.RESETn				),//o 			
	.DA1_TXENABLE						( DAC_CFG_IF1.TXENABLE				),//o 			
	.DA2_RESETn							( DAC_CFG_IF2.RESETn				),//o 			
	.DA2_TXENABLE						( DAC_CFG_IF2.TXENABLE				),//o 			
	.DA3_RESETn							( DAC_CFG_IF3.RESETn				),//o 			
	.DA3_TXENABLE						( DAC_CFG_IF3.TXENABLE				),//o 			
// ADC0/1/2/3-SPI Control Interface												
	.SPI_LB_IF							( SPI_LB_IF							) //
);

genvar i ;
generate
for(i=0;i<4;i=i+1)begin:inst
SPI_MIF0 # ( 														
	.P_SCLK_WIDTH						( 4									),						
	.P_ADDR_WIDTH						( 7									),						
	.P_DATA_WIDTH						( 16								)						
) U01_SPI_MIF0 (																				
//Clock & Reset																				
	.CLK								( REG_BUS_IF.CLK					),//i 					
	.RST								( REG_BUS_IF.RST					),//i 					
//Local Bus 																			
	.LB_REQ								( SPI_LB_IF[i].REQ					),//i 					
	.LB_RNW								( SPI_LB_IF[i].RNW					),//i 					
	.LB_ADR								( SPI_LB_IF[i].ADR					),//i [14:0]			
	.LB_WDAT							( SPI_LB_IF[i].WDAT					),//i [ 7:0]			
	.LB_RDAT							( SPI_LB_IF[i].RDAT					),//o [ 7:0]		
	.LB_ACK								( SPI_LB_IF[i].ACK					),//o  					
//External Port															
	.SPI_CSN							( w_CSn[ i]							),//o 					
	.SPI_SCL							( w_SCLK[i]							),//o 					
	.SPI_SDO							( w_SDO[ i]							),//o 					
	.SPI_SDO_t							( w_SDO_t[ i]						),//o 					
	.SPI_SDI							( w_SDI[ i] 						) //i 					
);
end
endgenerate

assign	DAC_CFG_IF0.CSn  = w_CSn[ 0] ;
assign	DAC_CFG_IF0.SCLK = w_SCLK[0] ;
assign	DAC_CFG_IF0.SDO  = ( w_SDO_t[0] ) ? 1'bZ : w_SDO[ 0] ;
assign	DAC_CFG_IF1.CSn  = w_CSn[ 1] ;
assign	DAC_CFG_IF1.SCLK = w_SCLK[1] ;
assign	DAC_CFG_IF1.SDO  = ( w_SDO_t[1] ) ? 1'bZ : w_SDO[ 1] ;
assign	DAC_CFG_IF2.CSn  = w_CSn[ 2] ;
assign	DAC_CFG_IF2.SCLK = w_SCLK[2] ;
assign	DAC_CFG_IF2.SDO  = ( w_SDO_t[2] ) ? 1'bZ : w_SDO[ 2] ;
assign	DAC_CFG_IF3.CSn  = w_CSn[ 3] ;
assign	DAC_CFG_IF3.SCLK = w_SCLK[3] ;
assign	DAC_CFG_IF3.SDO  = ( w_SDO_t[3] ) ? 1'bZ : w_SDO[ 3] ;

assign	w_SDI[0] = DAC_CFG_IF0.SDI;
assign	w_SDI[1] = DAC_CFG_IF1.SDI;
assign	w_SDI[2] = DAC_CFG_IF2.SDI;
assign	w_SDI[3] = DAC_CFG_IF3.SDI;

reg						r_sysref_iob						;
always @ ( negedge w_glbclk1 ) begin
	r_sysref_iob <= w_TX0_SYSREF;
end

always @ ( posedge w_glbclk1 ) begin
	r_tx0_tdata <=  DAC_DATA0;
	r_tx1_tdata <=  DAC_DATA1;
	r_tx2_tdata <=  DAC_DATA2;
	r_tx3_tdata <=  DAC_DATA3;
end

DAC_MAP U00_DAC_MAP (
	.DATA_I								( r_tx0_tdata						),
	.DATA_O								( w_tx0_tdata						)
);
DAC_MAP U01_DAC_MAP (
	.DATA_I								( r_tx1_tdata						),
	.DATA_O								( w_tx1_tdata						)
);
DAC_MAP U02_DAC_MAP (
	.DATA_I								( r_tx2_tdata						),
	.DATA_O								( w_tx2_tdata						)
);
DAC_MAP U03_DAC_MAP (
	.DATA_I								( r_tx3_tdata						),
	.DATA_O								( w_tx3_tdata						)
);

assign	w_DAC_LMFC = | w_tx0_start_of_multiframe;

`ifndef SIM
jesd204_tx_support U05_jesd204_tx_support (
	.refclk								( w_refclk1							),//i 			 
	.glbclk								( w_glbclk1							),//i
	.drpclk								( REG_BUS_IF.CLK					),//i            
	.txpostcursor						( w_txpostcursor					),//i 
	.txprecursor						( w_txprecursor						),//i 
	.txdiffctrl							( w_txdiffctrl						),//i 
// GT Common Ports
	.common0_qpll0_lock_out				( 									),//output         
	.common0_qpll0_refclk_out			( 									),//output         
	.common0_qpll0_clk_out				( 									),//output         
	.common1_qpll0_lock_out				( 									),//output         
	.common1_qpll0_refclk_out			( 									),//output         
	.common1_qpll0_clk_out				( 									),//output         
//*******************************************
// Tx Ports
//*******************************************
	.tx_reset							( w_SOFT_RST						),//i        
	.tx_core_clk_out					( 									),//o        
	.tx_sysref							( r_sysref_iob						),//i        
	.tx_sync							( w_TX0_SYNC						),//i        
	.txp								( DAC_204_IF0.TX_P					),//o [7:0]  
	.txn								( DAC_204_IF0.TX_N					),//o [7:0]  
// Tx AXI-S interface
	.tx_aresetn							( w_tx0_aresetn						),//o         
	.tx_start_of_frame					( w_tx0_start_of_frame				),//o [  3:0]  
	.tx_start_of_multiframe				( w_tx0_start_of_multiframe			),//o [  3:0]  
	.tx_tready							( w_tx0_tready						),//o         
	.tx_tdata							( w_tx0_tdata						),//i [255:0] 
// AXI-Lite Control/Status
	.s_axi_aclk							( REG_BUS_IF.CLK					),//i         
	.s_axi_aresetn						(~REG_BUS_IF.RST					),//i         
	.s_axi_awaddr						( 12'b0								),//i [11:0]  
	.s_axi_awvalid						( 1'b0								),//i         
	.s_axi_awready						( 									),//o         
	.s_axi_wdata						( 32'b0								),//i [31:0]  
	.s_axi_wstrb						( 4'b0								),//i  [3:0]  
	.s_axi_wvalid						( 1'b0								),//i         
	.s_axi_wready						( 									),//o         
	.s_axi_bresp						( 									),//o  [1:0]  
	.s_axi_bvalid						( 									),//o         
	.s_axi_bready						( 1'b0								),//i         
	.s_axi_araddr						( 12'b0								),//i [11:0]  
	.s_axi_arvalid						( 1'b0								),//i         
	.s_axi_arready						( 									),//o         
	.s_axi_rdata						( 									),//o [31:0]  
	.s_axi_rresp						( 									),//o  [1:0]  
	.s_axi_rvalid						( 									),//o         
	.s_axi_rready						( 1'b0								) //i         
);

jesd204_tx_support U06_jesd204_tx_support (
	.refclk								( w_refclk1							),//i 			 
	.glbclk								( w_glbclk1							),//i
	.drpclk								( REG_BUS_IF.CLK					),//i            
	.txpostcursor						( w_txpostcursor					),//i 
	.txprecursor						( w_txprecursor						),//i 
	.txdiffctrl							( w_txdiffctrl						),//i 
// GT Common Ports
	.common0_qpll0_lock_out				( 									),//output         
	.common0_qpll0_refclk_out			( 									),//output         
	.common0_qpll0_clk_out				( 									),//output         
	.common1_qpll0_lock_out				( 									),//output         
	.common1_qpll0_refclk_out			( 									),//output         
	.common1_qpll0_clk_out				( 									),//output         
//*******************************************
// Tx Ports
//*******************************************
	.tx_reset							( w_SOFT_RST						),//i        
	.tx_core_clk_out					( 									),//o        
	.tx_sysref							( r_sysref_iob						),//i        
	.tx_sync							( w_TX1_SYNC						),//i        
	.txp								( DAC_204_IF1.TX_P					),//o [7:0]  
	.txn								( DAC_204_IF1.TX_N					),//o [7:0]  
// Tx AXI-S interface
	.tx_aresetn							( w_tx1_aresetn						),//o         
	.tx_start_of_frame					( w_tx1_start_of_frame				),//o [  3:0]  
	.tx_start_of_multiframe				( w_tx1_start_of_multiframe			),//o [  3:0]  
	.tx_tready							( w_tx1_tready						),//o         
	.tx_tdata							( w_tx1_tdata						),//i [255:0] 
// AXI-Lite Control/Status
	.s_axi_aclk							( REG_BUS_IF.CLK					),//i         
	.s_axi_aresetn						(~REG_BUS_IF.RST					),//i         
	.s_axi_awaddr						( 12'b0								),//i [11:0]  
	.s_axi_awvalid						( 1'b0								),//i         
	.s_axi_awready						( 									),//o         
	.s_axi_wdata						( 32'b0								),//i [31:0]  
	.s_axi_wstrb						( 4'b0								),//i  [3:0]  
	.s_axi_wvalid						( 1'b0								),//i         
	.s_axi_wready						( 									),//o         
	.s_axi_bresp						( 									),//o  [1:0]  
	.s_axi_bvalid						( 									),//o         
	.s_axi_bready						( 1'b0								),//i         
	.s_axi_araddr						( 12'b0								),//i [11:0]  
	.s_axi_arvalid						( 1'b0								),//i         
	.s_axi_arready						( 									),//o         
	.s_axi_rdata						( 									),//o [31:0]  
	.s_axi_rresp						( 									),//o  [1:0]  
	.s_axi_rvalid						( 									),//o         
	.s_axi_rready						( 1'b0								) //i         
);

jesd204_tx_support U07_jesd204_tx_support (
	.refclk								( w_refclk1							),//i 			 
	.glbclk								( w_glbclk1							),//i
	.drpclk								( REG_BUS_IF.CLK					),//i            
	.txpostcursor						( w_txpostcursor					),//i 
	.txprecursor						( w_txprecursor						),//i 
	.txdiffctrl							( w_txdiffctrl						),//i 
// GT Common Ports
	.common0_qpll0_lock_out				( 									),//output         
	.common0_qpll0_refclk_out			( 									),//output         
	.common0_qpll0_clk_out				( 									),//output         
	.common1_qpll0_lock_out				( 									),//output         
	.common1_qpll0_refclk_out			( 									),//output         
	.common1_qpll0_clk_out				( 									),//output         
//*******************************************
// Tx Ports
//*******************************************
	.tx_reset							( w_SOFT_RST						),//i        
	.tx_core_clk_out					( 									),//o        
	.tx_sysref							( r_sysref_iob						),//i        
	.tx_sync							( w_TX2_SYNC						),//i        
	.txp								( DAC_204_IF2.TX_P					),//o [7:0]  
	.txn								( DAC_204_IF2.TX_N					),//o [7:0]  
// Tx AXI-S interface
	.tx_aresetn							( w_tx2_aresetn						),//o         
	.tx_start_of_frame					( w_tx2_start_of_frame				),//o [  3:0]  
	.tx_start_of_multiframe				( w_tx2_start_of_multiframe			),//o [  3:0]  
	.tx_tready							( w_tx2_tready						),//o         
	.tx_tdata							( w_tx2_tdata						),//i [255:0] 
// AXI-Lite Control/Status
	.s_axi_aclk							( REG_BUS_IF.CLK					),//i         
	.s_axi_aresetn						(~REG_BUS_IF.RST					),//i         
	.s_axi_awaddr						( 12'b0								),//i [11:0]  
	.s_axi_awvalid						( 1'b0								),//i         
	.s_axi_awready						( 									),//o         
	.s_axi_wdata						( 32'b0								),//i [31:0]  
	.s_axi_wstrb						( 4'b0								),//i  [3:0]  
	.s_axi_wvalid						( 1'b0								),//i         
	.s_axi_wready						( 									),//o         
	.s_axi_bresp						( 									),//o  [1:0]  
	.s_axi_bvalid						( 									),//o         
	.s_axi_bready						( 1'b0								),//i         
	.s_axi_araddr						( 12'b0								),//i [11:0]  
	.s_axi_arvalid						( 1'b0								),//i         
	.s_axi_arready						( 									),//o         
	.s_axi_rdata						( 									),//o [31:0]  
	.s_axi_rresp						( 									),//o  [1:0]  
	.s_axi_rvalid						( 									),//o         
	.s_axi_rready						( 1'b0								) //i         
);

jesd204_tx_support U08_jesd204_tx_support (
	.refclk								( w_refclk1							),//i 			 
	.glbclk								( w_glbclk1							),//i
	.drpclk								( REG_BUS_IF.CLK					),//i            
	.txpostcursor						( w_txpostcursor					),//i 
	.txprecursor						( w_txprecursor						),//i 
	.txdiffctrl							( w_txdiffctrl						),//i 
// GT Common Ports
	.common0_qpll0_lock_out				( 									),//output         
	.common0_qpll0_refclk_out			( 									),//output         
	.common0_qpll0_clk_out				( 									),//output         
	.common1_qpll0_lock_out				( 									),//output         
	.common1_qpll0_refclk_out			( 									),//output         
	.common1_qpll0_clk_out				( 									),//output         
//*******************************************
// Tx Ports
//*******************************************
	.tx_reset							( w_SOFT_RST						),//i        
	.tx_core_clk_out					( 									),//o        
	.tx_sysref							( r_sysref_iob						),//i        
	.tx_sync							( w_TX3_SYNC						),//i        
	.txp								( DAC_204_IF3.TX_P					),//o [7:0]  
	.txn								( DAC_204_IF3.TX_N					),//o [7:0]  
// Tx AXI-S interface
	.tx_aresetn							( w_tx3_aresetn						),//o         
	.tx_start_of_frame					( w_tx3_start_of_frame				),//o [  3:0]  
	.tx_start_of_multiframe				( w_tx3_start_of_multiframe			),//o [  3:0]  
	.tx_tready							( w_tx3_tready						),//o         
	.tx_tdata							( w_tx3_tdata						),//i [255:0] 
// AXI-Lite Control/Status
	.s_axi_aclk							( REG_BUS_IF.CLK					),//i         
	.s_axi_aresetn						(~REG_BUS_IF.RST					),//i         
	.s_axi_awaddr						( 12'b0								),//i [11:0]  
	.s_axi_awvalid						( 1'b0								),//i         
	.s_axi_awready						( 									),//o         
	.s_axi_wdata						( 32'b0								),//i [31:0]  
	.s_axi_wstrb						( 4'b0								),//i  [3:0]  
	.s_axi_wvalid						( 1'b0								),//i         
	.s_axi_wready						( 									),//o         
	.s_axi_bresp						( 									),//o  [1:0]  
	.s_axi_bvalid						( 									),//o         
	.s_axi_bready						( 1'b0								),//i         
	.s_axi_araddr						( 12'b0								),//i [11:0]  
	.s_axi_arvalid						( 1'b0								),//i         
	.s_axi_arready						( 									),//o         
	.s_axi_rdata						( 									),//o [31:0]  
	.s_axi_rresp						( 									),//o  [1:0]  
	.s_axi_rvalid						( 									),//o         
	.s_axi_rready						( 1'b0								) //i         
);

ila_204b U07_ila_204b (
	.clk								( w_glbclk1							),
	.probe0								( w_tx0_tdata[127:0]				),
	.probe1								( w_tx0_aresetn						),
	.probe2								( w_tx0_start_of_frame				),
	.probe3								( w_tx0_start_of_multiframe			),
	.probe4								( w_tx0_tready						),
	.probe5								( w_tx1_aresetn						),
	.probe6								( w_tx1_start_of_frame				),
	.probe7								( w_tx1_start_of_multiframe			),
	.probe8								( w_tx1_tready						),
	.probe9								( w_tx2_aresetn						),
	.probe10							( w_tx2_start_of_frame				),
	.probe11							( w_tx2_start_of_multiframe			),
	.probe12							( w_tx2_tready						),
	.probe13							( w_tx3_aresetn						),
	.probe14							( w_tx3_start_of_frame				),
	.probe15							( w_tx3_start_of_multiframe			),
	.probe16							( w_tx3_tready						),
	.probe17							( w_TX0_SYSREF						),
	.probe18							( w_TX1_SYSREF						),
	.probe19							( w_TX2_SYSREF						),
	.probe20							( w_TX3_SYSREF						),
	.probe21							( w_TX0_SYNC						),
	.probe22							( w_TX1_SYNC						),
	.probe23							( w_TX2_SYNC						),
	.probe24							( w_TX3_SYNC						) 
);

`endif

endmodule