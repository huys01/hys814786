
`define	DAC_ENABLE 
`define	MCU_ENABLE 
//`define	DDR_ENABLE 
//`define	IBERT_ENABLE 

module AWG_FPGA_TOP (
// Clock & Reset Interface
	input								SYSTEM_RSTn							,//
	input								FPGA_25M							,//From 25M Crystal 
	input								FPGA_DDR4_100M_CLK0P				,//From PLL-3
	input								FPGA_DDR4_100M_CLK0N				,//From PLL-3
	input								FPGA_DDR4_100M_CLK1P				,//From PLL-2
	input								FPGA_DDR4_100M_CLK1N				,//From PLL-2
	input								GTH_REF_CLKP						,//From PLL-1
	input								GTH_REF_CLKN						,//From PLL-1
	input								REFCLK_P							,//From PLL-0
	input								REFCLK_N							,//From PLL-0
	input								DAC1_REF_CLKP						,//From HMC7044
	input								DAC1_REF_CLKN						,//From HMC7044
	input								DAC2_REF_CLKP						,//From HMC7044
	input								DAC2_REF_CLKN						,//From HMC7044
//PLL Si5338 Config
	output								SI5338_SCL							,//Bank-25
	inout								SI5338_SDA							,//Bank-25
//HMC7044 Config & Control Interface
	output								HMC7044_PWR_EN						,
	output								HMC7044_SYNC						,
	output								HMC7044_RESET						,
	output								HMC7044_SLENn						,//Enable
	output								HMC7044_SCLK						,//
	inout								HMC7044_SDATA						,//24bit
// AD/DA Power Enable
	output								ADC_PWR_EN							,//o
	output								PWR_EN_ADC1							,//o
	output								PWR_EN_ADC2							,//o
	output								PWR_EN_ADC3							,//o
	output								PWR_EN_ADC4							,//o
// VPX-Interface
	output	[ 4:0]						VPX_GA								,//o [ 4:0]		
	output								VPX_GAP								,//o 			
// VPX-P2 Interface(Bank24)
	inout								VPX_DCO_CLKP						,//i 			
	inout								VPX_DCO_CLKN						,//i 			
	inout								VPX_ID_I_DVLD						,//i 			
	inout								VPX_ID_I_DATA						,//i 			
	inout								VPX_ID_O_DVLD						,//i 			
	inout								VPX_ID_O_DATA						,//i 			
	inout								VPX_CMD_I_DVLD						,//i 			
	inout	[ 1:0]						VPX_CMD_I_DATA						,//i [ 1:0]		
	inout								VPX_CMD_O_DVLD						,//o 			
	inout	[ 1:0]						VPX_CMD_O_DATA						,//o [ 1:0]		
	input	[ 1:0]						VPX_TRIG_P							,//i [ 1:0]		
	input	[ 1:0]						VPX_TRIG_N							,//i [ 1:0]		
	output								TEST1_P								,//o 			
	output								TEST1_N								,//o 			
// Temperature IO
	input								TEMP_DQ								,//i 			
	output								TEMP_DQ_O							,//o 			
// UART for debug
	input								UART_RX								,//i AU15		
	output								UART_TX								,//o AT15		
// DDR4-0/1 Interface
`ifdef DDR_ENABLE
	`ifndef SIM
	DDR4_BUS.master						DDR4_IF0							,//
	DDR4_BUS.master						DDR4_IF1							,//
	`endif
`endif
// DAC-JESD204B Interface														
`ifdef	DAC_ENABLE
	DAC_CFG_BUS.master					DAC_CFG_IF0							,
	DAC_204_BUS.master					DAC_204_IF0							,//QUAD224
	DAC_CFG_BUS.master					DAC_CFG_IF1							,
	DAC_204_BUS.master					DAC_204_IF1							,//QUAD226
	DAC_CFG_BUS.master					DAC_CFG_IF2							,
	DAC_204_BUS.master					DAC_204_IF2							,//QUAD225
	DAC_CFG_BUS.master					DAC_CFG_IF3							,
	DAC_204_BUS.master					DAC_204_IF3							,//QUAD227
`endif
`ifdef IBERT_ENABLE
	input	[ 3:0]						IBERT_RX_P							,
	input	[ 3:0]						IBERT_RX_N							,
	output	[ 3:0]						IBERT_TX_P							,
	output	[ 3:0]						IBERT_TX_N							,
`endif
// Debug Interface
	output								ADC1_LED							,
	output								ADC2_LED							,
	output								ADC3_LED							,
	output								ADC4_LED							,
	output								ALERT_LED							 
);
	
	assign	TEMP_DQ_O  = TEMP_DQ;
	
	wire								w_SOFT_RST							;
	wire								w_SYSCLK							;
	wire								w_clk_50m							;
	wire								w_clk_50m_en						;
	wire								w_clk_250m							;
	wire								w_clk_125m							;
	wire								w_clk_500m							;
	wire								w_REGRST							;
	wire								w_SYSRST							;
	wire	[ 7:0]						w_CLK_DET							;
	wire								w_DDR4_0_CLK_IN						;
	wire								w_DDR4_1_CLK_IN						;
	wire								w_Si5388_PLL0						;
	wire								w_SRIO_refclk						;
	wire								w_SRIO_glbclk						;
	wire								w_SRIO_glbclk_o						;
	wire	[ 3:0]						w_DB_CLK_PORT						;

	REG_BUS								REG_BUS_I[0:1]	 (.CLK(w_clk_50m),.RST(w_REGRST));
	REG_BUS								REG_BUS_O[0:7]	 (.CLK(w_clk_50m),.RST(w_REGRST));
	MEMW_BUS							MEMW_BUS_IF0[0:7](.CLK(w_MEM0_CLK),.RST(w_MEM0_RST));
	MEMR_BUS							MEMR_BUS_IF0[0:7](.CLK(w_MEM0_CLK),.RST(w_MEM0_RST));
	MEMW_BUS							MEMW_BUS_IF1[0:7](.CLK(w_MEM1_CLK),.RST(w_MEM1_RST));
	MEMR_BUS							MEMR_BUS_IF1[0:7](.CLK(w_MEM1_CLK),.RST(w_MEM1_RST));
	
IBUFDS # ( 
	.DQS_BIAS							( "FALSE"							) 	
) IBUFDS_inst1 (																
	.O									( w_DDR4_0_CLK_IN					),	
	.I									( FPGA_DDR4_100M_CLK0P				),	
	.IB									( FPGA_DDR4_100M_CLK0N				) 	
);

IBUFDS # ( 
	.DQS_BIAS							( "FALSE"							) 	
) IBUFDS_inst2 (																
	.O									( w_DDR4_1_CLK_IN					),	
	.I									( FPGA_DDR4_100M_CLK1P				),	
	.IB									( FPGA_DDR4_100M_CLK1N				) 	
);
	
IBUFDS # ( 
	.DQS_BIAS							( "FALSE"							) 	
) IBUFDS_inst3 (																
	.O									( w_Si5388_PLL0						),	
	.I									( REFCLK_P							),	
	.IB									( REFCLK_N							) 	
);
	
IBUFDS_GTE3 # (
	.REFCLK_HROW_CK_SEL					( 2'b00								)
) ibufds_refclk (
	.O    								( w_SRIO_refclk						),
	.ODIV2								( w_SRIO_glbclk_o					),
	.CEB  								( 1'b0								),
	.I    								( GTH_REF_CLKP						),
	.IB   								( GTH_REF_CLKN						)
);

(*keep="true"*)BUFG_GT U6_BUFG (
	.O									( w_SRIO_glbclk						),
	.CE									( 1'b1								),
	.CEMASK								( 1'b0								),
	.CLR								( 1'b0								),
	.CLRMASK							( 1'b0								),
	.DIV								( 3'b0								),
	.I									( w_SRIO_glbclk_o					)
);

//--------------------------------------------------------------------------------------//
// System Clock & Reset Generate Module													
//------------------------------------------  ------------------------------------------//
CLK_RST_GEN U00_CLK_RST_GEN (
// From Clock Input	
	.CLK25M_IN							( FPGA_25M							),//25Mhz	
	.RESETN_IN							( 1'b1								),//i		
//From Array Soft Reset																	
	.SOFT_RST							( w_SOFT_RST						),//i 		
// To System Clock																		
	.SYSCLK								( w_SYSCLK							),//200Mhz 	
	.CLK50M								( w_clk_50m							),//50Mhz	
	.CLK250M							( w_clk_250m						),//250Mhz	
	.CLK125M							( w_clk_125m						),//125Mhz	
	.CLK500M							( w_clk_500m						),//500Mhz	
	.REGRST								( w_REGRST							),// 		
	.SYSRST								( w_SYSRST							) //		
);

// MCU_TOP Module
`ifdef MCU_ENABLE
`ifndef SIM
MCU_DB_TOP U01_MCU_DB_TOP (
	.CLK								( w_clk_50m							),//i 		
	.RST								( w_REGRST							),//i 		
	.REG_BUS_IF							( REG_BUS_I[0]						),//master	
	.UART_TXD							( UART_TX							),//o 		
	.UART_RXD							( UART_RX							) //i 		
); 
`else
	assign	REG_BUS_I[0].WREN = 1'b0;
	assign	REG_BUS_I[0].WADR =  'b0;
	assign	REG_BUS_I[0].WDAT =  'b0;
	assign	REG_BUS_I[0].RDEN = 1'b0;
	assign	REG_BUS_I[0].RADR =  'b0;
`endif
`else
	assign	REG_BUS_I[0].WREN = 1'b0;
	assign	REG_BUS_I[0].WADR =  'b0;
	assign	REG_BUS_I[0].WDAT =  'b0;
	assign	REG_BUS_I[0].RDEN = 1'b0;
	assign	REG_BUS_I[0].RADR =  'b0;
`endif

REG_BUS_SPLIT U02_REG_BUS_SPLIT (
// Registers Access IF
	.REG_BUS_I							( REG_BUS_I							),//Slave	
// Registers IF output																
	.REG_BUS_O							( REG_BUS_O							) //master	
);

SYS_REG U02_SYS_REG (
// Registers Access IF
	.REG_BUS_IF							( REG_BUS_O[0]						),//Slave		
//Soft Reset Output																			
	.SOFT_RST							( w_SOFT_RST						),//o			
	.DB_CLK_EN							( w_clk_50m_en						),//o 
// Clock Form Board PLL input detect
	.CLK_DET							( w_CLK_DET							) //i[ 7:0]		
);

SI5338_CFG U03_SI5338_CFG (
//Register Bus
	.REG_BUS_IF							( REG_BUS_O[1]						),//slave		
// Si5338 Interface
	.SI5338_SCL							( SI5338_SCL						),//o  Bank-25
	.SI5338_SDA							( SI5338_SDA						) //io Bank-25
);

HMC7044_CFG U04_HMC7044_CFG (
//Register Bus
	.REG_BUS_IF							( REG_BUS_O[2]						),//slave		
// Si5338 Interface
	.HMC7044_PWR_EN						( HMC7044_PWR_EN					),//o 	
	.HMC7044_SYNC						( HMC7044_SYNC						),//o 	
	.HMC7044_RESET						( HMC7044_RESET						),//o 	
	.HMC7044_SLENn						( HMC7044_SLENn						),//o 	//Enable
	.HMC7044_SCLK						( HMC7044_SCLK						),//o 	//
	.HMC7044_SDATA						( HMC7044_SDATA						) //io	//24bit
);

wire [1:0] TRIGGER;

IO_TST U05_IO_TST ( 
// Clock 
	.CLK_250M							( w_clk_250m						),//i 		
//Register Bus
	.REG_BUS_IF							( REG_BUS_O[3]						),//slave		
// VPX-Interface
	.VPX_GA								( VPX_GA							),//o [ 4:0]
	.VPX_GAP							( VPX_GAP							),//o 		
// T.emperature IO
	.TEMP_DQ							( TEMP_DQ							),//i
// VPX-P2 Interface(Bank24)
	.VPX_DCO_CLKP						( VPX_DCO_CLKP						),//io 			
	.VPX_DCO_CLKN						( VPX_DCO_CLKN						),//io 			
	.VPX_ID_I_DVLD						( VPX_ID_I_DVLD						),//io 			
	.VPX_ID_I_DATA						( VPX_ID_I_DATA						),//io 			
	.VPX_ID_O_DVLD						( VPX_ID_O_DVLD						),//io 			
	.VPX_ID_O_DATA						( VPX_ID_O_DATA						),//io 			
	.VPX_CMD_I_DVLD						( VPX_CMD_I_DVLD					),//io 			
	.VPX_CMD_I_DATA						( VPX_CMD_I_DATA					),//io[ 1:0]	
	.VPX_CMD_O_DVLD						( VPX_CMD_O_DVLD					),//io			
	.VPX_CMD_O_DATA						( VPX_CMD_O_DATA					),//io[ 1:0]	
	.VPX_TRIG_P							( VPX_TRIG_P						),//i [ 1:0]	
	.VPX_TRIG_N							( VPX_TRIG_N						),//i [ 1:0]	
	.TEST1_P							( TEST1_P							),//o 			
	.TEST1_N							( TEST1_N							),//o
	.TRIGGER                            ( TRIGGER                           )  			
///With FPGA2 Interface					
);

//--------------------------------------------------------------------------------------//
// Memory Test Module													
//------------------------------------------  ------------------------------------------//
// DDR4_0/1_Test Module
`ifdef DDR_ENABLE
MEM_TOP U06_MEM_TOP (																		
// Memory Access Clock & Reset														
	.MEM0_CLK							( w_MEM0_CLK						),//o 			
	.MEM0_RST							( w_MEM0_RST						),//o 			
	.MEM1_CLK							( w_MEM1_CLK						),//o 			
	.MEM1_RST							( w_MEM1_RST						),//o 			
// DDR4-0/1 Interface
`ifndef SIM
	.DDR4_BUS_IF0						( DDR4_IF0							),//master	
	.DDR4_BUS_IF1						( DDR4_IF1							),//master	
`endif
// DDR4 Test Interface																
	.REG_BUS_IF							( REG_BUS_O[4]						),//slave		
//DDR3_0-Write Port0~7																
	.MEMW_BUS_00						( MEMW_BUS_IF0[0]					),//Slave 		
	.MEMW_BUS_01						( MEMW_BUS_IF0[1]					),//Slave 		
	.MEMW_BUS_02						( MEMW_BUS_IF0[2]					),//Slave 		
	.MEMW_BUS_03						( MEMW_BUS_IF0[3]					),//Slave 		
	.MEMW_BUS_04						( MEMW_BUS_IF0[4]					),//Slave 		
	.MEMW_BUS_05						( MEMW_BUS_IF0[5]					),//Slave 		
	.MEMW_BUS_06						( MEMW_BUS_IF0[6]					),//Slave 		
	.MEMW_BUS_07						( MEMW_BUS_IF0[7]					),//Slave 		
//DDR3_0-Read Port0~7																
	.MEMR_BUS_00						( MEMR_BUS_IF0[0]					),//Slave		
	.MEMR_BUS_01						( MEMR_BUS_IF0[1]					),//Slave		
	.MEMR_BUS_02						( MEMR_BUS_IF0[2]					),//Slave		
	.MEMR_BUS_03						( MEMR_BUS_IF0[3]					),//Slave		
	.MEMR_BUS_04						( MEMR_BUS_IF0[4]					),//Slave		
	.MEMR_BUS_05						( MEMR_BUS_IF0[5]					),//Slave		
	.MEMR_BUS_06						( MEMR_BUS_IF0[6]					),//Slave		
	.MEMR_BUS_07						( MEMR_BUS_IF0[7]					),//Slave		
//DDR3_1-Write Port0~7																
	.MEMW_BUS_10						( MEMW_BUS_IF1[0]					),//Slave 		
	.MEMW_BUS_11						( MEMW_BUS_IF1[1]					),//Slave 		
	.MEMW_BUS_12						( MEMW_BUS_IF1[2]					),//Slave 		
	.MEMW_BUS_13						( MEMW_BUS_IF1[3]					),//Slave 		
	.MEMW_BUS_14						( MEMW_BUS_IF1[4]					),//Slave 		
	.MEMW_BUS_15						( MEMW_BUS_IF1[5]					),//Slave 		
	.MEMW_BUS_16						( MEMW_BUS_IF1[6]					),//Slave 		
	.MEMW_BUS_17						( MEMW_BUS_IF1[7]					),//Slave 		
//DDR3_1-Read Port0~7																
	.MEMR_BUS_10						( MEMR_BUS_IF1[0]					),//Slave		
	.MEMR_BUS_11						( MEMR_BUS_IF1[1]					),//Slave		
	.MEMR_BUS_12						( MEMR_BUS_IF1[2]					),//Slave		
	.MEMR_BUS_13						( MEMR_BUS_IF1[3]					),//Slave		
	.MEMR_BUS_14						( MEMR_BUS_IF1[4]					),//Slave		
	.MEMR_BUS_15						( MEMR_BUS_IF1[5]					),//Slave		
	.MEMR_BUS_16						( MEMR_BUS_IF1[6]					),//Slave		
	.MEMR_BUS_17						( MEMR_BUS_IF1[7]					),//Slave		
// DDR3-0/1 Outside Interface														
	.DDR4_RST_IN						( w_SYSRST							),//i 			
	.DDR4_0_CLK_IN						( w_DDR4_0_CLK_IN					),//i 			
	.DDR4_1_CLK_IN						( w_DDR4_1_CLK_IN					) //i 			
);
`else
	assign	REG_BUS_O[4].RVLD =  1'b0;   
	assign	REG_BUS_O[4].RDAT = 32'b0;   
`endif

wire	[ 3:0]	w_PWR_EN_ADC;


wire DAC_CLK;
wire DAC_READY;
wire DAC_LMFC;
wire [127:0] DAC_DATA0;
wire [127:0] DAC_DATA1;
wire [127:0] DAC_DATA2;
wire [127:0] DAC_DATA3;

`ifdef DAC_ENABLE
//--------------------------------------------------------------------------------------//
// DAC JESD204B-RX Module													
//------------------------------------------  ------------------------------------------//
DAC_TOP U07_DAC_TOP (
// Reference Clock
	.DAC1_REF_CLKP						( DAC1_REF_CLKP						),
	.DAC1_REF_CLKN						( DAC1_REF_CLKN						),
	.DAC2_REF_CLKP						( DAC2_REF_CLKP						),
	.DAC2_REF_CLKN						( DAC2_REF_CLKN						),
	
	.DAC_CLK                            (DAC_CLK),
    .DAC_READY                          (DAC_READY),	
    .DAC_LMFC                           (DAC_LMFC),
	
// Registers Access IF																			
	.REG_BUS_IF							( REG_BUS_O[5]						),//Slave			
// DAC Power On
	.ADC_PWR_EN							( ADC_PWR_EN						),//o  
	.PWR_EN_ADC							( w_PWR_EN_ADC						),//o  
// Debug Port Output																		
	.DB_CLK_PORT						( w_DB_CLK_PORT						),//o [  3:0]	
// DAC0-JESD204B Receive Bus																	
	.DAC_DATA0							( DAC_DATA0							),//i [255:0]		
	.DAC_DATA1							( DAC_DATA1							),//i [255:0]		
	.DAC_DATA2							( DAC_DATA2							),//i [255:0]		
	.DAC_DATA3							( DAC_DATA3							),//i [255:0]		
// DAC_9173 Config Interface																	
	.DAC_CFG_IF0						( DAC_CFG_IF0						),//Master		
	.DAC_CFG_IF1						( DAC_CFG_IF1						),//Master		
	.DAC_CFG_IF2						( DAC_CFG_IF2						),//Master		
	.DAC_CFG_IF3						( DAC_CFG_IF3						),//Master		
// DAC-9173-GTH Interface																	
	.DAC_204_IF0						( DAC_204_IF0						),//QUAD215/216[7:0]
	.DAC_204_IF1						( DAC_204_IF1						),//QUAD215/216[7:0]
	.DAC_204_IF2						( DAC_204_IF2						),//QUAD215/216[7:0]
	.DAC_204_IF3						( DAC_204_IF3						) //QUAD215/216[7:0]
);

assign	PWR_EN_ADC1 = w_PWR_EN_ADC[0];
assign	PWR_EN_ADC2 = w_PWR_EN_ADC[1];
assign	PWR_EN_ADC3 = w_PWR_EN_ADC[2];
assign	PWR_EN_ADC4 = w_PWR_EN_ADC[3];
`else
	assign	REG_BUS_O[5].RVLD =  1'b0;
	assign	REG_BUS_O[5].RDAT = 32'b0;
`endif

`ifndef SIM
	assign	REG_BUS_I[1].WREN = 1'b0;
	assign	REG_BUS_I[1].WADR =  'b0;
	assign	REG_BUS_I[1].WDAT =  'b0;
	assign	REG_BUS_I[1].RDEN = 1'b0;
	assign	REG_BUS_I[1].RADR =  'b0;
`endif

	assign	REG_BUS_O[6].RVLD =  1'b0;
	assign	REG_BUS_O[6].RDAT = 32'b0;	
	assign	REG_BUS_O[7].RVLD =  1'b0;
	assign	REG_BUS_O[7].RDAT = 32'b0;

//	assign	REG_BUS_O[0].RVLD =  1'b0;
//	assign	REG_BUS_O[0].RDAT = 32'b0;
//	assign	REG_BUS_O[2].RVLD =  1'b0;
//	assign	REG_BUS_O[2].RDAT = 32'b0;
//	assign	REG_BUS_O[3].RVLD =  1'b0;
//	assign	REG_BUS_O[3].RDAT = 32'b0;
//	assign	REG_BUS_O[4].RVLD =  1'b0;
//	assign	REG_BUS_O[4].RDAT = 32'b0;
//	assign	REG_BUS_O[5].RVLD =  1'b0;
//	assign	REG_BUS_O[5].RDAT = 32'b0;
//	assign	REG_BUS_O[6].RVLD =  1'b0;
//	assign	REG_BUS_O[6].RDAT = 32'b0;
//	assign	REG_BUS_O[7].RVLD =  1'b0;
//	assign	REG_BUS_O[7].RDAT = 32'b0;
	
    wire [15:0] i_valid_amp;
    wire [15:0] i_zero_amp;
    
    wire [31:0] i_data_duration;
    wire [31:0] i_zero_duration;
    wire i_trigger;
    wire i_stop;
    
   /// wire [7:0] i_duration;
    wire i_rst;
    //wire [15:0] amp;
   // wire [3:0] interval;
    
    vio_0 u_vio_o 
    (
       .clk(DAC_CLK),                // input wire clk
       .probe_out0(i_trigger),  // output wire [0 : 0] probe_out0
       .probe_out1(i_stop),  // output wire [0 : 0] probe_out1
       .probe_out2(i_rst),  // output wire [0 : 0] probe_out2
       .probe_out3(i_valid_amp),  // output wire [15 : 0] probe_out3
       .probe_out4(i_zero_amp),  // output wire [15 : 0] probe_out4
       .probe_out5(i_data_duration),  // output wire [31 : 0] probe_out5
       .probe_out6(i_zero_duration)  // output wire [31 : 0] probe_out6
    );	
        
	
		 USER_TOP U08_USER_TOP
	 ( 
        .i_stop(i_stop),
        .i_trigger(i_trigger),
        .i_rst(i_rst),
	    .i_valid_amp(i_valid_amp),
	    .i_zero_amp(i_zero_amp),
	    .i_data_duration(i_data_duration),
	    .i_zero_duration(i_zero_duration),
	    
	    
        .DAC_CLK(DAC_CLK),
        .DAC_READY(DAC_READY),
        .DAC_LMFC(DAC_LMFC),
        
        .DAC_DATA0(DAC_DATA0),
        .DAC_DATA1(DAC_DATA1),
        .DAC_DATA2(DAC_DATA2),
        .DAC_DATA3(DAC_DATA3)
    );
	
		
	
	
	wire	w_DDR4_0_CLK_IN_bufg;
	wire	w_DDR4_1_CLK_IN_bufg;
	wire	w_Si5388_PLL0_bufg	;
	BUFG BUFG_inst0 ( .O(w_DDR4_0_CLK_IN_bufg),.I(w_DDR4_0_CLK_IN) );
	BUFG BUFG_inst1 ( .O(w_DDR4_1_CLK_IN_bufg),.I(w_DDR4_1_CLK_IN) );
	BUFG BUFG_inst2 ( .O(w_Si5388_PLL0_bufg),.I(w_Si5388_PLL0) );
	
	assign	w_CLK_DET[0] = w_DDR4_0_CLK_IN_bufg	;
	assign	w_CLK_DET[1] = w_DDR4_1_CLK_IN_bufg	;
	assign	w_CLK_DET[2] = w_Si5388_PLL0_bufg	;
	assign	w_CLK_DET[3] = w_SRIO_glbclk	;
	assign	w_CLK_DET[7:4] = w_DB_CLK_PORT	;
	
	
	reg		[ 31:0]			r_timer_1s		=32'h0;
	wire					w_timer_1s_pl	;
	reg						r_timer_1s_tg	=1'b0;
	always @ ( posedge w_clk_50m ) begin
		if ( w_timer_1s_pl ) begin
			r_timer_1s <= 32'h0;
		end else begin
			r_timer_1s <= r_timer_1s + 1'b1;
		end
	end
	
	assign	w_timer_1s_pl = ( r_timer_1s == 25000000 ) ? 1'b1:1'b0;
	
	always @ ( posedge w_clk_50m ) begin
		if ( w_timer_1s_pl ) begin
			r_timer_1s_tg <=  ~r_timer_1s_tg ;
		end
	end
	
	assign	ADC1_LED  =  r_timer_1s_tg;
	assign	ADC2_LED  = ~r_timer_1s_tg;
	assign	ADC3_LED  =  r_timer_1s_tg;
	assign	ADC4_LED  = ~r_timer_1s_tg;
	assign	ALERT_LED =  r_timer_1s_tg;
	
genvar i;
generate 
for(i=0;i<8;i=i+1)begin : MEMW_BUS_Initial	
	assign	MEMW_BUS_IF0[i].MEMW_REQ  =   1'b0;
	assign	MEMW_BUS_IF0[i].MEMW_ADR  =  32'b0;
	assign	MEMW_BUS_IF0[i].MEMW_LEN  =   8'b0;
	assign	MEMW_BUS_IF0[i].MEMW_RDAT = 512'b0;
	assign	MEMR_BUS_IF0[i].MEMR_REQ  =   1'b0;
	assign	MEMR_BUS_IF0[i].MEMR_ADR  =  32'b0;
	assign	MEMR_BUS_IF0[i].MEMR_LEN  =   8'b0;
	assign	MEMW_BUS_IF1[i].MEMW_REQ  =   1'b0;
	assign	MEMW_BUS_IF1[i].MEMW_ADR  =  32'b0;
	assign	MEMW_BUS_IF1[i].MEMW_LEN  =   8'b0;
	assign	MEMW_BUS_IF1[i].MEMW_RDAT = 512'b0;
	assign	MEMR_BUS_IF1[i].MEMR_REQ  =   1'b0;
	assign	MEMR_BUS_IF1[i].MEMR_ADR  =  32'b0;
	assign	MEMR_BUS_IF1[i].MEMR_LEN  =   8'b0;
end
endgenerate	

(* keep="true" *)wire	w_clk_50m_o;
	BUFGCE # (
		.CE_TYPE		( "SYNC"			),
		.IS_CE_INVERTED	( 1'b0				),
		.IS_I_INVERTED	( 1'b0				) 
	) BUFGCE_inst (
		.O				( w_clk_50m_o		),
		.CE				( w_clk_50m_en		),
		.I				( w_clk_50m			) 
	); 
	
	assign gth_sysclk_i  = w_clk_50m_o;

`ifdef IBERT_ENABLE
ibert_test_6_25G u_ibert_gth_core (
	.txn_o				( IBERT_TX_N				),  // output wire [3 : 0] txn_o
	.txp_o				( IBERT_TX_P				),  // output wire [3 : 0] txp_o
	.rxoutclk_o			( 							),  // output wire [3 : 0] rxoutclk_o
	.rxn_i				( IBERT_RX_N				),  // input wire [3 : 0] rxn_i
	.rxp_i				( IBERT_RX_P				),  // input wire [3 : 0] rxp_i
	.gtrefclk0_i		( w_SRIO_refclk				),  // input wire [0 : 0] gtrefclk0_i
	.gtrefclk1_i		( 1'b0						),  // input wire [0 : 0] gtrefclk1_i
	.gtnorthrefclk0_i	( 1'b0						),  // input wire [0 : 0] gtnorthrefclk0_i
	.gtnorthrefclk1_i	( 1'b0						),  // input wire [0 : 0] gtnorthrefclk1_i
	.gtsouthrefclk0_i	( 1'b0						),  // input wire [0 : 0] gtsouthrefclk0_i
	.gtsouthrefclk1_i	( 1'b0						),  // input wire [0 : 0] gtsouthrefclk1_i
	.gtrefclk00_i		( w_SRIO_refclk				),  // input wire [0 : 0] gtrefclk00_i
	.gtrefclk10_i		( 1'b0						),  // input wire [0 : 0] gtrefclk10_i
	.gtrefclk01_i		( 1'b0						),  // input wire [0 : 0] gtrefclk01_i
	.gtrefclk11_i		( 1'b0						),  // input wire [0 : 0] gtrefclk11_i
	.gtnorthrefclk00_i	( 1'b0						),  // input wire [0 : 0] gtnorthrefclk00_i
	.gtnorthrefclk10_i	( 1'b0						),  // input wire [0 : 0] gtnorthrefclk10_i
	.gtnorthrefclk01_i	( 1'b0						),  // input wire [0 : 0] gtnorthrefclk01_i
	.gtnorthrefclk11_i	( 1'b0						),  // input wire [0 : 0] gtnorthrefclk11_i
	.gtsouthrefclk00_i	( 1'b0						),  // input wire [0 : 0] gtsouthrefclk00_i
	.gtsouthrefclk10_i	( 1'b0						),  // input wire [0 : 0] gtsouthrefclk10_i
	.gtsouthrefclk01_i	( 1'b0						),  // input wire [0 : 0] gtsouthrefclk01_i
	.gtsouthrefclk11_i	( 1'b0						),  // input wire [0 : 0] gtsouthrefclk11_i
	.clk				( gth_sysclk_i				)   // input wire clk
);
`endif

endmodule