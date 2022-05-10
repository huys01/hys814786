module VPX_TEST (
	input								CLK									,//i 			
	input								RST									,//i 			
	input								VPX_ID_DIR							,//i
	input								VPX_CMD_DIR							,//i
	input								VPX_DCO_DIR							,//i
	inout								VPX_DCO_CLKP						,//i 			
	inout								VPX_DCO_CLKN						,//i 			
	inout								VPX_ID_I_DVLD						,//i 			
	inout								VPX_ID_I_DATA						,//i 			
	inout								VPX_ID_O_DVLD						,//i 			
	inout								VPX_ID_O_DATA						,//i 			
	inout								VPX_CMD_I_DVLD						,//i 			
	inout	[1:0]						VPX_CMD_I_DATA						,//i [ 1:0]		
	inout								VPX_CMD_O_DVLD						,//o 			
	inout	[1:0]						VPX_CMD_O_DATA						,//o [ 1:0]		
	input	[1:0]						VPX_TRIG_P							,//i [ 1:0]		
	input	[1:0]						VPX_TRIG_N							,//i [ 1:0]		
	output								TEST1_P								,//o 			
	output								TEST1_N								, //o
	output [1:0]                       TRIGGER 			
);

    
	reg									r_test_o=1'b0;
	always @ ( posedge CLK ) begin
		r_test_o <= ~r_test_o;
	end
	
	OBUFDS OBUFDS_LVDS_O_P0 (
		.O								( TEST1_P							),
		.OB								( TEST1_N							),
		.I								( r_test_o							) 
	);
	
	reg		[ 9:0]						r_cmd_o		;
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_cmd_o <= 10'b0;
		end else begin
			r_cmd_o <= r_cmd_o + 1'b1;
		end
	end
	
	assign	VPX_CMD_O_DATA = ( VPX_CMD_DIR ) ? 2'bzz: r_cmd_o[2:1];
	assign	VPX_CMD_O_DVLD = ( VPX_CMD_DIR ) ? 1'bz : r_cmd_o[0];

	assign	VPX_CMD_I_DATA = ( VPX_CMD_DIR ) ? 2'bzz: r_cmd_o[5:4];
	assign	VPX_CMD_I_DVLD = ( VPX_CMD_DIR ) ? 1'bz : r_cmd_o[3];

	assign	VPX_ID_O_DATA  = ( VPX_ID_DIR  ) ? 1'bz : r_cmd_o[7];
	assign	VPX_ID_O_DVLD  = ( VPX_ID_DIR  ) ? 1'bz : r_cmd_o[6];

	assign	VPX_ID_I_DATA  = ( VPX_ID_DIR  ) ? 1'bz : r_cmd_o[9];
	assign	VPX_ID_I_DVLD  = ( VPX_ID_DIR  ) ? 1'bz : r_cmd_o[8];
	
	wire								w_LVDS_CLK							;
	wire	[ 1:0]						w_VPX_TRIG							;
	assign TRIGGER = w_VPX_TRIG;
	
	IOBUFDS IBUFDS_LVDS_I_P0 (
		.O								( w_LVDS_CLK						),
		.I								( CLK								),
		.IO								( VPX_DCO_CLKP						),
		.IOB							( VPX_DCO_CLKN						),
		.T								( VPX_DCO_DIR						) 
	);
	
	IBUFDS IBUFDS_LVDS_I_P1 (
		.O								( w_VPX_TRIG[0]						),
		.I								( VPX_TRIG_P[0]						),
		.IB								( VPX_TRIG_N[0]						) 
	);
	
	IBUFDS IBUFDS_LVDS_I_P2 (
		.O								( w_VPX_TRIG[1]						),
		.I								( VPX_TRIG_P[1]						),
		.IB								( VPX_TRIG_N[1]						) 
	);
	
`ifndef SIM
	ila_vpx u_ila_vpx(
		.clk							( w_LVDS_CLK						),
		.probe0							( VPX_ID_I_DVLD		    			),
		.probe1							( VPX_ID_I_DATA		    			),
		.probe2							( VPX_CMD_I_DVLD					),
		.probe3							( VPX_CMD_I_DATA					),
		.probe4							( VPX_ID_O_DVLD		    			),
		.probe5							( VPX_ID_O_DATA		    			),
		.probe6							( VPX_CMD_O_DVLD					),
		.probe7							( VPX_CMD_O_DATA					),
		.probe8							( w_VPX_TRIG						) 
	);
`endif

endmodule