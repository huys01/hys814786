module DAC_MAP (
	input	[127:0]		DATA_I		,
	output	[127:0]		DATA_O		
);
	
	wire	[15:0]		w_a0_data0		;
	wire	[15:0]		w_a0_data1		;
	wire	[15:0]		w_a0_data2		;
	wire	[15:0]		w_a0_data3		;

	wire	[15:0]		w_b0_data0		;
	wire	[15:0]		w_b0_data1		;
	wire	[15:0]		w_b0_data2		;
	wire	[15:0]		w_b0_data3		;

	wire	[31:0]		w_data0		;
	wire	[31:0]		w_data1		;
	wire	[31:0]		w_data2		;
	wire	[31:0]		w_data3		;

	assign	w_a0_data3	= DATA_I[0*16+15:0*16];
	assign	w_a0_data2	= DATA_I[1*16+15:1*16];
	assign	w_a0_data1	= DATA_I[2*16+15:2*16];
	assign	w_a0_data0	= DATA_I[3*16+15:3*16];
	
	assign	w_b0_data3	= DATA_I[4*16+15:4*16];
	assign	w_b0_data2	= DATA_I[5*16+15:5*16];
	assign	w_b0_data1	= DATA_I[6*16+15:6*16];
	assign	w_b0_data0	= DATA_I[7*16+15:7*16];
	
	assign	w_data0 = {	w_a0_data0[15:8],w_a0_data1[15:8],w_a0_data2[15:8],w_a0_data3[15:8]};
	assign	w_data1 = {	w_a0_data0[ 7:0],w_a0_data1[ 7:0],w_a0_data2[ 7:0],w_a0_data3[ 7:0]};
	assign	w_data2 = {	w_b0_data0[15:8],w_b0_data1[15:8],w_b0_data2[15:8],w_b0_data3[15:8]};
	assign	w_data3 = {	w_b0_data0[ 7:0],w_b0_data1[ 7:0],w_b0_data2[ 7:0],w_b0_data3[ 7:0]};

	assign	DATA_O = {w_data0,w_data1,w_data2,w_data3};

endmodule