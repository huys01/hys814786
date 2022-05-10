module HMC7044_CFG (
// Registers Access IF																
	REG_BUS.slave						REG_BUS_IF							,//Slave		
//HMC7044 Config & Control Interface
	output								HMC7044_PWR_EN						,
	output								HMC7044_SYNC						,
	output								HMC7044_RESET						,
	output								HMC7044_SLENn						,//Enable
	output								HMC7044_SCLK						,//
	inout								HMC7044_SDATA						 //24bit
);

	wire								w_LB_REQ							;				
	wire								w_LB_RNW							;				
	wire	[14:0]						w_LB_ADR							;				
	wire	[ 7:0]						w_LB_WDAT							;				
	wire	[ 7:0]						w_LB_RDAT							;				
	wire								w_LB_ACK							;				

HMC7044_REG U00_HMC7044_REG (
// Registers Access IF
	.REG_BUS_IF							( REG_BUS_IF						),//Slave		
// HMC7044 Async Control Interface															
	.HMC7044_PWR_EN						( HMC7044_PWR_EN					),//o 			
	.HMC7044_SYNC						( HMC7044_SYNC						),//o [ 1:0]	
	.HMC7044_RESET						( HMC7044_RESET						),//o 			
// PLL Interface Check																		
	.LB_REQ								( w_LB_REQ							),//o 			
	.LB_RNW								( w_LB_RNW							),//o 			
	.LB_ADR								( w_LB_ADR							),//o [14:0]	
	.LB_WDAT							( w_LB_WDAT							),//o [ 7:0]	
	.LB_RDAT							( w_LB_RDAT							),//i [ 7:0]	
	.LB_ACK								( w_LB_ACK							) //i  			
);


SPI_MIF0 # ( 															
	.P_SCLK_WIDTH						( 4									),
	.P_ADDR_WIDTH						( 15								),				
	.P_DATA_WIDTH						( 8									)			
) U_SPI_MIF0 (																				
//Clock & Reset																	
	.CLK								( REG_BUS_IF.CLK					),//i 			
	.RST								( REG_BUS_IF.RST					),//i 			
//Local Bus 																	
	.LB_REQ								( w_LB_REQ							),//i 			
	.LB_RNW								( w_LB_RNW							),//i 			
	.LB_ADR								( w_LB_ADR[14:0]					),//i 			
	.LB_WDAT							( w_LB_WDAT							),//i 			
	.LB_RDAT							( w_LB_RDAT							),//o 			
	.LB_ACK								( w_LB_ACK							),//o  			
//External Port																	
	.SPI_CSN							( HMC7044_SLENn						),//o 			
	.SPI_SCL							( HMC7044_SCLK						),//o 			
	.SPI_SDO							( w_SPI_SDO							),//o 			
	.SPI_SDO_t							( w_SPI_SDO_t						),//o 			
	.SPI_SDI							( HMC7044_SDATA						) //i 			
);

assign	HMC7044_SDATA = ( w_SPI_SDO_t ) ? 1'bZ : w_SPI_SDO;

endmodule