module SI5338_CFG (
//Register Bus
	REG_BUS.slave						REG_BUS_IF							,//slave		
// Si5338 Interface
	output								SI5338_SCL							,//o  Bank-25
	inout								SI5338_SDA							 //io Bank-25
);

	wire								w_USR_trig							;
	wire								w_USR_rnw							;
	wire	[ 7:0]						w_USR_wrcyc							;
	wire	[ 7:0]						w_USR_rdcyc							;
	wire	[ 7:0]						w_USR_deivce_id						;
	wire	[15:0]						w_USR_reg_addr						;
	wire								w_USR_wvld							;
	wire	[ 7:0]						w_USR_wdata							;
	wire								w_USR_rvld							;
	wire	[ 7:0]						w_USR_rdata							;
	wire								w_USR_error							;
	wire								w_USR_end							;
	wire								w_I2C_scl							;
	wire								w_I2C_sda_in						;
	wire								w_I2C_sda_out						;

Si5338_REG U_Si5338_REG (											 					
// Registers Access IF															
	.REG_BUS_IF							( REG_BUS_IF						),//Slave		
//user interface 
	.USR_trig							( w_USR_trig						),	//I2C transmit trig pulse,Active High 
	.USR_rnw							( w_USR_rnw							),	//I2C transmit direction, 1:Read/0:Write
	.USR_wrcyc							( w_USR_wrcyc						),	//I2C Write cycle
	.USR_rdcyc							( w_USR_rdcyc						),	//I2C Read cycle
	.USR_deivce_id						( w_USR_deivce_id					),	//I2C transmit Device ID
	.USR_reg_addr						( w_USR_reg_addr					),	//I2C transmit Register Address
	.USR_wvld							( w_USR_wvld						),	//I2C transmit write fetch signal 
	.USR_wdata							( w_USR_wdata						),	//I2C transmit write data
	.USR_rvld							( w_USR_rvld						),	//I2C transmit read data valid pulse 
	.USR_rdata							( w_USR_rdata						),	//I2C transmit read data
	.USR_error							( w_USR_error						),	//I2C status feedback,1:No Ack(abnormal)/0:Ack(normal)
	.USR_end							( w_USR_end							)		//I2C transmit end signal 
);

I2C_master U_I2C_master(
//system clock & reset
	.CLK								( REG_BUS_IF.CLK					),	//50MHz clock 
	.RST								( REG_BUS_IF.RST					),	//Active high
//user interface                    	
	.USR_trig							( w_USR_trig						),//I2C transmit trig pulse,Active High 
	.USR_rnw							( w_USR_rnw							),//I2C transmit direction, 1:Read/0:Write
	.USR_wrcyc							( w_USR_wrcyc						),//I2C Write cycle
	.USR_rdcyc							( w_USR_rdcyc						),//I2C Read cycle
	.USR_deivce_id						( w_USR_deivce_id					),//I2C transmit Device ID
	.USR_reg_addr						( w_USR_reg_addr[7:0]				),//I2C transmit Register Address
	.USR_wvld							( w_USR_wvld						),//I2C transmit write fetch signal 
	.USR_wdata							( w_USR_wdata						),//I2C transmit write data
	.USR_rvld							( w_USR_rvld						),//I2C transmit read data valid pulse 
	.USR_rdata							( w_USR_rdata						),//I2C transmit read data
	.USR_error							( w_USR_error						),//I2C status feedback,1:No Ack(abnormal)/0:Ack(normal)
	.USR_end							( w_USR_end							),//I2C transmit end signal 
//i2c interface                     	
	.I2C_scl							( w_I2C_scl							),	//I2C clock pin
	.I2C_sda_in							( w_I2C_sda_in						),	//I2C data line pin
	.I2C_sda_out						( w_I2C_sda_out						)
);

assign	SI5338_SCL = w_I2C_scl;
assign	SI5338_SDA = ( w_I2C_sda_out ) ? 1'bZ : 1'b0;
assign	w_I2C_sda_in = SI5338_SDA;

`ifndef SIM
//	ila_i2c u_ila_i2c(
//		.clk							( REG_BUS_IF.CLK					),
//		.probe0							( w_I2C_scl		    				),
//		.probe1							( w_I2C_sda_in		    			),
//		.probe2							( w_I2C_sda_out		    			) 
//	);
`endif

endmodule