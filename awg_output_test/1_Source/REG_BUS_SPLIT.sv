module REG_BUS_SPLIT (
// Registers Access IF																
	REG_BUS.slave				REG_BUS_I[0:1]				,//Slave				
// Registers IF output																
	REG_BUS.master				REG_BUS_O[0:7]				 //master				
);

	//--------------------------------------------------------------------------
	// Registers Signal name Declaration
	//--------------------------------------------------------------------------
(* dont_touch="true" *)	reg							r_reg_wren_o [0:7]			;
(* dont_touch="true" *)	reg							r_reg_rden_o [0:7]			;
(* dont_touch="true" *)	reg		[31:0]				r_reg_wadr_o [0:7]			;
(* dont_touch="true" *)	reg		[31:0]				r_reg_radr_o [0:7]			;
(* dont_touch="true" *)	reg		[31:0]				r_reg_wdat_o [0:7]			;
	
	wire	CLK =  REG_BUS_I[0].CLK	;
	wire	RST =  REG_BUS_I[0].RST	;
		
	//--------------------------------------------------------//
	// Write Registers Handle
	//--------------------------------------------------------//
genvar i;
generate
for(i=0;i<8;i=i+1) begin
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_wren_o[i] <=  1'b0;
			r_reg_rden_o[i] <=  1'b0;
			r_reg_wadr_o[i] <=  8'h0;
			r_reg_radr_o[i] <=  8'h0;
			r_reg_wdat_o[i] <= 32'h0;
		end else begin
			r_reg_wren_o[i] <= ( REG_BUS_I[0].WREN && ( REG_BUS_I[0].WADR[11:8] == i )) || 
							   ( REG_BUS_I[1].WREN && ( REG_BUS_I[1].WADR[11:8] == i )) ;
			r_reg_rden_o[i] <= ( REG_BUS_I[0].RDEN && ( REG_BUS_I[0].RADR[11:8] == i )) || 
							   ( REG_BUS_I[1].RDEN && ( REG_BUS_I[1].RADR[11:8] == i )) ;
			r_reg_wadr_o[i] <= ( REG_BUS_I[0].WREN ) ? REG_BUS_I[0].WADR : 
							   ( REG_BUS_I[1].WREN ) ? REG_BUS_I[1].WADR : r_reg_wadr_o[i];
			r_reg_radr_o[i] <= ( REG_BUS_I[0].RDEN ) ? REG_BUS_I[0].RADR : 
							   ( REG_BUS_I[1].RDEN ) ? REG_BUS_I[1].RADR : r_reg_radr_o[i];
			r_reg_wdat_o[i] <= ( REG_BUS_I[0].WREN ) ? REG_BUS_I[0].WDAT : 
							   ( REG_BUS_I[1].WREN ) ? REG_BUS_I[1].WDAT : r_reg_wdat_o[i] ;
		end
	end
	assign	REG_BUS_O[i].WREN = r_reg_wren_o[i];
	assign	REG_BUS_O[i].RDEN = r_reg_rden_o[i];
	assign	REG_BUS_O[i].WADR = r_reg_wadr_o[i];
	assign	REG_BUS_O[i].RADR = r_reg_radr_o[i];
	assign	REG_BUS_O[i].WDAT = r_reg_wdat_o[i];
end
endgenerate

//----------------------------------------------------------------------------//
//Registers Read Handle                                                       //
//----------------------------------------------------------------------------//		
	reg		[31:0]				r_reg_radr_shf	[0:1]			;
	reg		[31:0]				r_reg_rdat_d1	[0:1]			;
	reg							r_reg_rvld_d1	[0:1]			;
generate
for(i=0;i<2;i=i+1) begin
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_radr_shf[i] <= 32'h0;
		end else begin
			r_reg_radr_shf[i] <= REG_BUS_I[i].RADR;
		end
	end

	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_rdat_d1[i] <= 32'b0;
		end else begin
			case ( r_reg_radr_shf[i][10:8] )
				3'b000 : r_reg_rdat_d1[i] <= REG_BUS_O[0].RDAT;
				3'b001 : r_reg_rdat_d1[i] <= REG_BUS_O[1].RDAT;
				3'b010 : r_reg_rdat_d1[i] <= REG_BUS_O[2].RDAT;
				3'b011 : r_reg_rdat_d1[i] <= REG_BUS_O[3].RDAT;
				3'b100 : r_reg_rdat_d1[i] <= REG_BUS_O[4].RDAT;
				3'b101 : r_reg_rdat_d1[i] <= REG_BUS_O[5].RDAT;
				3'b110 : r_reg_rdat_d1[i] <= REG_BUS_O[6].RDAT;
				3'b111 : r_reg_rdat_d1[i] <= REG_BUS_O[7].RDAT;
				default : ;
			endcase
		end
	end
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_rvld_d1[i] <= 1'b0;
		end else begin
			case ( r_reg_radr_shf[i][10:8] )
				3'b000 : r_reg_rvld_d1[i] <= REG_BUS_O[0].RVLD;
				3'b001 : r_reg_rvld_d1[i] <= REG_BUS_O[1].RVLD;
				3'b010 : r_reg_rvld_d1[i] <= REG_BUS_O[2].RVLD;
				3'b011 : r_reg_rvld_d1[i] <= REG_BUS_O[3].RVLD;
				3'b100 : r_reg_rvld_d1[i] <= REG_BUS_O[4].RVLD;
				3'b101 : r_reg_rvld_d1[i] <= REG_BUS_O[5].RVLD;
				3'b110 : r_reg_rvld_d1[i] <= REG_BUS_O[6].RVLD;
				3'b111 : r_reg_rvld_d1[i] <= REG_BUS_O[7].RVLD;
				default : ;
			endcase
		end
	end
	
	assign	REG_BUS_I[i].RDAT = r_reg_rdat_d1[i];
	assign	REG_BUS_I[i].RVLD = r_reg_rvld_d1[i];
end
	
endgenerate

endmodule