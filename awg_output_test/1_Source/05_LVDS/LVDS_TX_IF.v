														
`timescale 1ns/ 1ps										
														
module LVDS_TX_IF #(									
	parameter	P_5MS 				= 20'h98968			,
	parameter	C_DATA_WIDTH		= 16				
)(														
// Clock & Reset										
	input							CLK					,//125MHz Clock
	input							CLK4X				,//500MHz Clock
	input							RST					,//Reset, Active High
	output							LVDS_INIT_DONE		,//LVDS Initial Done
//User Tx Data Port															
	input	[C_DATA_WIDTH*8-1:0]	LVDS_TX_DATA		,//LVDS transmit Data
																			
//LVDS Transfer IF															
	output							LVDS_TX_CLK_P		,//LVDS clock on FMC1
	output							LVDS_TX_CLK_N		,//LVDS clock on FMC1
	output	[C_DATA_WIDTH  -1:0]	LVDS_TX_DAT_P		,//LVDS CH0 Lane0 FMC1
	output	[C_DATA_WIDTH  -1:0]	LVDS_TX_DAT_N		,//LVDS CH0 Lane0 FMC1
	output							LVDS_TX_SOUT		,//LVDS Serial TX
	input							LVDS_TX_SIN			 //LVDS Serial RX
);															
															
// io-transmit module										
IO_MST_IF #( 												
	.P_5MS 							( P_5MS				),	
	.C_DATA_WIDTH 					( C_DATA_WIDTH		)	
) u_IO_MST_IF (												
// Clock & Reset											
	.mCLK							( CLK				),	
	.mx4CLK							( CLK4X				),	
	.RST							( RST				),	
// Internal interface										
	.TX_DAT							( LVDS_TX_DATA		),	
// External Interface										
	.EXT_CLK_P						( LVDS_TX_CLK_P		),	
	.EXT_CLK_N						( LVDS_TX_CLK_N		),	
	.EXT_DAT_P						( LVDS_TX_DAT_P		),	
	.EXT_DAT_N						( LVDS_TX_DAT_N		),	
// Serial Interface											
	.IO_RX							( LVDS_TX_SIN		),	
	.IO_TX							( LVDS_TX_SOUT		),	
// Result Information										
	.TRAIN_DONE						( LVDS_INIT_DONE	)	
);															
															
endmodule