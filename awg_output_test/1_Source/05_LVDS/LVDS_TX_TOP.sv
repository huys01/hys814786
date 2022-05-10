module LVDS_TX_TOP (
// clock & reset													
	input								TX_CLK						,
	input								TX_CLKx4					,
	input								TX_RST						,
// LVDS Status
	output								LVDS_INIT_DONE				,
	input								LVDS_ERR_INSERT				,
	input		[ 3:0]					LVDS_ERR_INSERT_CHN			,
// LVDS Interface
	output								LVDS_CLK_P					,
	output								LVDS_CLK_N					,
	output		[ 9:0]					LVDS_DAT_P					,
	output		[ 9:0]					LVDS_DAT_N					,
	output								LVDS_SOUT					,
	input								LVDS_SIN				
);
	reg			[79:0]					r_lvds_tx_data				;
	wire		[79:0]					w_lvds_tx_data				;
	reg			[ 7:0]					r_err_insert_shf			;
	wire								w_err_insert				;

LVDS_TX_IF #(									
	.P_5MS 								( 20'h020					),
	.C_DATA_WIDTH						( 10						)	
) U_LVDS_TX_IF (													
// Clock & Reset												
	.CLK								( TX_CLK					),//125MHz Clock
	.CLK4X								( TX_CLKx4					),//500MHz Clock
	.RST								( TX_RST					),//Reset, Active Low
	.LVDS_INIT_DONE						( LVDS_INIT_DONE			),//LVDS Initial Done
//User Tx Data Port														
	.LVDS_TX_DATA						( w_lvds_tx_data			),//LVDS transmit Data
//LVDS Transfer IF																				
	.LVDS_TX_CLK_P						( LVDS_CLK_P				),//LVDS clock on FMC1
	.LVDS_TX_CLK_N						( LVDS_CLK_N				),//LVDS clock on FMC1
	.LVDS_TX_DAT_P						( LVDS_DAT_P				),//LVDS CH0 Lane0 FMC1
	.LVDS_TX_DAT_N						( LVDS_DAT_N				),//LVDS CH0 Lane0 FMC1
	.LVDS_TX_SOUT						( LVDS_SOUT					),//LVDS Serial TX
	.LVDS_TX_SIN						( LVDS_SIN					) //LVDS Serial RX
);

genvar i;
generate 
for(i=0;i<10;i=i+1)begin
	always @ ( posedge TX_CLK ) begin
		if ( TX_RST ) begin
			r_lvds_tx_data[i*8+7:i*8] <= 8'b0;
		end else if ( LVDS_INIT_DONE ) begin
			r_lvds_tx_data[i*8+7:i*8] <= r_lvds_tx_data[i*8+7:i*8] + 1'b1;
		end
	end
	
	assign	w_lvds_tx_data[i*8+7:i*8] = ( LVDS_ERR_INSERT_CHN != i ) ? r_lvds_tx_data[i*8+7:i*8]        : 
										( w_err_insert             ) ? r_lvds_tx_data[i*8+7:i*8] + 1'b1 : r_lvds_tx_data[i*8+7:i*8];
end
endgenerate

	always @ ( posedge TX_CLK ) begin
		if ( TX_RST ) begin
			r_err_insert_shf <= 8'b0;
		end else begin
			r_err_insert_shf <= {r_err_insert_shf[6:0],LVDS_ERR_INSERT};
		end 
	end
	
	assign	w_err_insert = ~r_err_insert_shf[7] & r_err_insert_shf[6];

endmodule