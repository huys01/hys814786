`define TEMP_EN
//`define GPIO_EN
//`define LVDS_EN
`define VPX_EN

module IO_TST (
// CLock 
	input								CLK_250M							,//i 
//Register Bus
	REG_BUS.slave						REG_BUS_IF							,//slave		
// VPX-Interface
	output	[ 4:0]						VPX_GA								,//o [ 4:0]		
	output								VPX_GAP								,//o 			
// VPX-P2 Interface(Bank24)
	inout								VPX_DCO_CLKP						,//i 			
	inout								VPX_DCO_CLKN						,//i 			
	inout								VPX_ID_I_DVLD						,//i 			
	inout								VPX_ID_I_DATA						,//i 			
	inout								VPX_ID_O_DVLD						,//o 			
	inout								VPX_ID_O_DATA						,//o 			
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
	output [1:0]                       TRIGGER 			
//With FPGA2 Interface														
//	input								GPIO0_1V8_I							,//i Bank45
//	output								GPIO0_1V8_O							,//i Bank45
//	input	[ 3:0]						GPIO1_1V8_I							,//i Bank64
//	output	[ 3:0]						GPIO1_1V8_O							,//i Bank64
//	input								LVDS_I_CLKP							,//i 
//	input								LVDS_I_CLKN							,//i 
//	input	[ 4:0]						LVDS_I_P							,//i 
//	input	[ 4:0]						LVDS_I_N							,//i 
//	output								LVDS_O_CLKP							,//o 
//	output								LVDS_O_CLKN							,//o 
//	output	[ 4:0]						LVDS_O_P							,//o 
//	output	[ 4:0]						LVDS_O_N							 //o 
);

	wire	[31:0]						w_GPIO0_1V8_I_CNT					;
	wire	[31:0]						w_GPIO1_1V8_I_CNT0					;
	wire	[31:0]						w_GPIO1_1V8_I_CNT1					;
	wire	[31:0]						w_GPIO1_1V8_I_CNT2					;
	wire	[31:0]						w_GPIO1_1V8_I_CNT3					;
	wire	[31:0]						w_TEMP_DATA							;
	wire	[31:0]						w_DB_LVDS_CNT						;
	wire	[31:0]						w_DB_LVDS_CNT0						;
	wire	[31:0]						w_DB_LVDS_CNT1						;
	wire	[31:0]						w_DB_LVDS_CNT2						;
	wire	[31:0]						w_DB_LVDS_CNT3						;
	wire	[31:0]						w_DB_LVDS_CNT4						;
	wire								w_VPX_ID_DIR						;
	wire								w_VPX_CMD_DIR						;
	wire								w_VPX_DCO_DIR						;

IO_REG U_IO_REG (
// Registers Access IF
	.REG_BUS_IF							( REG_BUS_IF						),//Slave		
// VPX-Interface
	.VPX_GA								( VPX_GA							),//o [ 4:0]
	.VPX_GAP							( VPX_GAP							),//o 		
// T.emperature IO
	.TEMP_DATA							( w_TEMP_DATA						),//i [31:0]
// VPX-P2 Interface(Bank24)
	.VPX_ID_DIR							( w_VPX_ID_DIR						),//o 		
	.VPX_CMD_DIR						( w_VPX_CMD_DIR						),//o 		
	.VPX_DCO_DIR						( w_VPX_DCO_DIR						),//o 		
///With FPGA2 Interface					
	.GPIO0_1V8_I_CNT					( w_GPIO0_1V8_I_CNT					),//i [31:0]
	.GPIO1_1V8_I_CNT0					( w_GPIO1_1V8_I_CNT0				),//i [31:0]
	.GPIO1_1V8_I_CNT1					( w_GPIO1_1V8_I_CNT1				),//i [31:0]
	.GPIO1_1V8_I_CNT2					( w_GPIO1_1V8_I_CNT2				),//i [31:0]
	.GPIO1_1V8_I_CNT3					( w_GPIO1_1V8_I_CNT3				),//i [31:0]
	.LVDS_I_CNT							( w_DB_LVDS_CNT						),//i [31:0]
	.LVDS_I_CNT0						( w_DB_LVDS_CNT0					),//i [31:0]
	.LVDS_I_CNT1						( w_DB_LVDS_CNT1					),//i [31:0]
	.LVDS_I_CNT2						( w_DB_LVDS_CNT2					),//i [31:0]
	.LVDS_I_CNT3						( w_DB_LVDS_CNT3					),//i [31:0]
	.LVDS_I_CNT4						( w_DB_LVDS_CNT4					) //i [31:0]
);

`ifdef TEMP_EN
TEMP_DATA U_TEMP_DATA (
	.CLK								( REG_BUS_IF.CLK					),//i 
	.RST								( REG_BUS_IF.RST					),//i 
	.TEMP_DQ							( TEMP_DQ							),//i 
	.TEMP_DATA							( w_TEMP_DATA						) //o [31:0]
);
`else
	assign	w_TEMP_DATA = 32'h5A5AA5A5;
`endif

reg		[27:0]		r_timer_1s_cnt	=28'h0;
reg					r_timer_1s		=1'b0;
always @ ( posedge REG_BUS_IF.CLK ) begin
	if ( r_timer_1s_cnt ==28'd49999999 ) begin
		r_timer_1s_cnt <= 28'd0;
		r_timer_1s <= 1'b1;
	end else begin
		r_timer_1s_cnt <= r_timer_1s_cnt + 1'b1;
		r_timer_1s <= 1'b0;
	end
end 

`ifdef GPIO_EN
GPIO_TEST U_GPIO_TEST (
	.CLK								( REG_BUS_IF.CLK					),//i 
	.RST								( REG_BUS_IF.RST					),//i 
	.TIMER_1S							( r_timer_1s						),//i 	
	.GPIO0_1V8_I_CNT					( w_GPIO0_1V8_I_CNT					),//o [31:0]
	.GPIO1_1V8_I_CNT0					( w_GPIO1_1V8_I_CNT0				),//o [31:0]
	.GPIO1_1V8_I_CNT1					( w_GPIO1_1V8_I_CNT1				),//o [31:0]
	.GPIO1_1V8_I_CNT2					( w_GPIO1_1V8_I_CNT2				),//o [31:0]
	.GPIO1_1V8_I_CNT3					( w_GPIO1_1V8_I_CNT3				),//o [31:0]
	.GPIO0_1V8_I						( GPIO0_1V8_I						),//i 		Bank45
	.GPIO0_1V8_O						( GPIO0_1V8_O						),//o 		Bank45
	.GPIO1_1V8_I						( GPIO1_1V8_I						),//i [ 3:0]Bank64
	.GPIO1_1V8_O						( GPIO1_1V8_O						) //o [ 3:0]Bank64
);
`endif

`ifdef LVDS_EN
LVDS_TEST U_LVDS_TEST (
	.CLK_REG							( REG_BUS_IF.CLK					),//i 
	.CLK_250M							( CLK_250M							),//i 
	.RST								( REG_BUS_IF.RST					),//i 
	.DB_LVDS_CNT						( w_DB_LVDS_CNT						),//o [31:0]
	.DB_LVDS_CNT0						( w_DB_LVDS_CNT0					),//o [31:0]
	.DB_LVDS_CNT1						( w_DB_LVDS_CNT1					),//o [31:0]
	.DB_LVDS_CNT2						( w_DB_LVDS_CNT2					),//o [31:0]
	.DB_LVDS_CNT3						( w_DB_LVDS_CNT3					),//o [31:0]
	.DB_LVDS_CNT4						( w_DB_LVDS_CNT4					),//o [31:0]
	.LVDS_I_CLKP						( LVDS_I_CLKP						),//i 
	.LVDS_I_CLKN						( LVDS_I_CLKN						),//i 
	.LVDS_I_P							( LVDS_I_P							),//i [ 4:0]	
	.LVDS_I_N							( LVDS_I_N							),//i [ 4:0]	
	.LVDS_O_CLKP						( LVDS_O_CLKP						),//o 
	.LVDS_O_CLKN						( LVDS_O_CLKN						),//o 
	.LVDS_O_P							( LVDS_O_P							),//o [ 4:0]	
	.LVDS_O_N							( LVDS_O_N							) //o [ 4:0]	
);
`endif

VPX_TEST U_VPX_TEST (
	.CLK								( REG_BUS_IF.CLK					),
	.RST								( REG_BUS_IF.RST					),//
	.VPX_ID_DIR							( w_VPX_ID_DIR						),//i
	.VPX_CMD_DIR						( w_VPX_CMD_DIR						),//i
	.VPX_DCO_DIR						( w_VPX_DCO_DIR						),//i
	.VPX_DCO_CLKP						( VPX_DCO_CLKP						),//i 			
	.VPX_DCO_CLKN						( VPX_DCO_CLKN						),//i 			
	.VPX_ID_I_DVLD						( VPX_ID_I_DVLD						),//i 			
	.VPX_ID_I_DATA						( VPX_ID_I_DATA						),//i 			
	.VPX_ID_O_DVLD						( VPX_ID_O_DVLD						),//o 			
	.VPX_ID_O_DATA						( VPX_ID_O_DATA						),//o 			
	.VPX_CMD_I_DVLD						( VPX_CMD_I_DVLD					),//i 			
	.VPX_CMD_I_DATA						( VPX_CMD_I_DATA					),//i [ 1:0]	
	.VPX_CMD_O_DVLD						( VPX_CMD_O_DVLD					),//o 			
	.VPX_CMD_O_DATA						( VPX_CMD_O_DATA					),//o [ 1:0]	
	.VPX_TRIG_P							( VPX_TRIG_P						),//i [ 1:0]	
	.VPX_TRIG_N							( VPX_TRIG_N						),//i [ 1:0]	
	.TEST1_P							( TEST1_P							),//o 			
	.TEST1_N							( TEST1_N							), //o
	.TRIGGER                            ( TRIGGER                           ) 			
);

endmodule