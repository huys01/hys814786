`timescale 1ns/ 1ps

module RR_ARB10 ( 
	input					CLK					,
	input					RST					,
	input	[ 9:0]			REQ					,
	input					ACK					,
	output	[ 9:0]			GNT					 
);	
	
	reg		[ 3:0]			r_reg_pointer		; // arbiter round pointer
	reg		[ 9:0]			r_mask				; // arbiter input mask
	wire					s_mask_all			; // all arbter input mask
	wire	[ 9:0]			s_mask_req			; // masked request
	wire					s_int_mask			; // internal mask
	wire	[ 9:0]			s_msk_pre_req		; // pre masked request
	wire	[ 9:0]			s_mak_gnt			; // grant mask
	wire	[ 9:0]			s_umak_req			; // unmasked request
	wire	[ 9:0]			s_umak_pre_req		; // pre-unmasked request
	wire	[ 9:0]			s_umak_gnt			; // no Grant mask
	wire	[ 9:0]			s_gnt				; // grant signal bus
	reg		[ 9:0]			r_gnt				; // grant signal bus
	
	// request pointer generation
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_reg_pointer <= 4'b0;
		end else begin
			if ( s_gnt[0] ) begin
				r_reg_pointer <= 4'b0001;
			end else if ( s_gnt[1] ) begin
				r_reg_pointer <= 4'b0010;
			end else if ( s_gnt[2] ) begin
				r_reg_pointer <= 4'b0011;
			end else if ( s_gnt[3] ) begin
				r_reg_pointer <= 4'b0100;
			end else if ( s_gnt[4] ) begin
				r_reg_pointer <= 4'b0101;
			end else if ( s_gnt[5] ) begin
				r_reg_pointer <= 4'b0110;
			end else if ( s_gnt[6] ) begin
				r_reg_pointer <= 4'b0111;
			end else if ( s_gnt[7] ) begin
				r_reg_pointer <= 4'b1000;
			end else if ( s_gnt[8] ) begin
				r_reg_pointer <= 4'b1001;
			end else if ( s_gnt[9] ) begin
				r_reg_pointer <= 4'b0000;
			end
		end
	end

	// request mask signal generation
	
	always @ ( r_reg_pointer ) begin
		case ( r_reg_pointer )
			4'b0000		: r_mask = 10'b1111111111;
			4'b0001		: r_mask = 10'b1111111110;
			4'b0010		: r_mask = 10'b1111111100;
			4'b0011		: r_mask = 10'b1111111000;
			4'b0100		: r_mask = 10'b1111110000;
			4'b0101		: r_mask = 10'b1111100000;
			4'b0110		: r_mask = 10'b1111000000;
			4'b0111		: r_mask = 10'b1110000000;
			4'b1000		: r_mask = 10'b1100000000;
			4'b1001		: r_mask = 10'b1000000000;
			default 	: r_mask = 10'b1111111111;
		endcase
	end

	assign s_mask_all = |r_gnt;

	// masked request generation

	assign s_mask_req[0] = s_mask_all ? 1'b0 : (r_mask[0] & REQ[0]);
	assign s_mask_req[1] = s_mask_all ? 1'b0 : (r_mask[1] & REQ[1]);
	assign s_mask_req[2] = s_mask_all ? 1'b0 : (r_mask[2] & REQ[2]);
	assign s_mask_req[3] = s_mask_all ? 1'b0 : (r_mask[3] & REQ[3]);
	assign s_mask_req[4] = s_mask_all ? 1'b0 : (r_mask[4] & REQ[4]);
	assign s_mask_req[5] = s_mask_all ? 1'b0 : (r_mask[5] & REQ[5]);
	assign s_mask_req[6] = s_mask_all ? 1'b0 : (r_mask[6] & REQ[6]);
	assign s_mask_req[7] = s_mask_all ? 1'b0 : (r_mask[7] & REQ[7]);
	assign s_mask_req[8] = s_mask_all ? 1'b0 : (r_mask[8] & REQ[8]);
	assign s_mask_req[9] = s_mask_all ? 1'b0 : (r_mask[9] & REQ[9]);

	assign s_int_mask	= ~((r_mask[0] & REQ[0]) |
							(r_mask[1] & REQ[1]) |
							(r_mask[2] & REQ[2]) |
							(r_mask[3] & REQ[3]) |
							(r_mask[4] & REQ[4]) |
							(r_mask[5] & REQ[5]) |
							(r_mask[6] & REQ[6]) |
							(r_mask[7] & REQ[7]) |
							(r_mask[8] & REQ[8]) |
							(r_mask[9] & REQ[9]) );

	// masked simple priority arbiter

	assign s_msk_pre_req[9] = s_msk_pre_req[8] | s_mask_req[8];
	assign s_msk_pre_req[8] = s_msk_pre_req[7] | s_mask_req[7];
	assign s_msk_pre_req[7] = s_msk_pre_req[6] | s_mask_req[6];
	assign s_msk_pre_req[6] = s_msk_pre_req[5] | s_mask_req[5];
	assign s_msk_pre_req[5] = s_msk_pre_req[4] | s_mask_req[4];
	assign s_msk_pre_req[4] = s_msk_pre_req[3] | s_mask_req[3];
	assign s_msk_pre_req[3] = s_msk_pre_req[2] | s_mask_req[2];
	assign s_msk_pre_req[2] = s_msk_pre_req[1] | s_mask_req[1];
	assign s_msk_pre_req[1] = s_msk_pre_req[0] | s_mask_req[0];
	assign s_msk_pre_req[0] = 1'b0;

	assign s_mak_gnt[0] = ~s_msk_pre_req[0] & s_mask_req[0] ;
	assign s_mak_gnt[1] = ~s_msk_pre_req[1] & s_mask_req[1] ;
	assign s_mak_gnt[2] = ~s_msk_pre_req[2] & s_mask_req[2] ;
	assign s_mak_gnt[3] = ~s_msk_pre_req[3] & s_mask_req[3] ;
	assign s_mak_gnt[4] = ~s_msk_pre_req[4] & s_mask_req[4] ;
	assign s_mak_gnt[5] = ~s_msk_pre_req[5] & s_mask_req[5] ;
	assign s_mak_gnt[6] = ~s_msk_pre_req[6] & s_mask_req[6] ;
	assign s_mak_gnt[7] = ~s_msk_pre_req[7] & s_mask_req[7] ;
	assign s_mak_gnt[8] = ~s_msk_pre_req[8] & s_mask_req[8] ;
	assign s_mak_gnt[9] = ~s_msk_pre_req[9] & s_mask_req[9] ;

	// unmasked Request generation
	assign s_umak_req[0] = s_mask_all ? 1'b0 : REQ[0];
	assign s_umak_req[1] = s_mask_all ? 1'b0 : REQ[1];
	assign s_umak_req[2] = s_mask_all ? 1'b0 : REQ[2];
	assign s_umak_req[3] = s_mask_all ? 1'b0 : REQ[3];
	assign s_umak_req[4] = s_mask_all ? 1'b0 : REQ[4];
	assign s_umak_req[5] = s_mask_all ? 1'b0 : REQ[5];
	assign s_umak_req[6] = s_mask_all ? 1'b0 : REQ[6];
	assign s_umak_req[7] = s_mask_all ? 1'b0 : REQ[7];
	assign s_umak_req[8] = s_mask_all ? 1'b0 : REQ[8];
	assign s_umak_req[9] = s_mask_all ? 1'b0 : REQ[9];

	// unmasked simple priority arbiter
	assign s_umak_pre_req[9] = s_umak_pre_req[8] | s_umak_req[8];
	assign s_umak_pre_req[8] = s_umak_pre_req[7] | s_umak_req[7];
	assign s_umak_pre_req[7] = s_umak_pre_req[6] | s_umak_req[6];
	assign s_umak_pre_req[6] = s_umak_pre_req[5] | s_umak_req[5];
	assign s_umak_pre_req[5] = s_umak_pre_req[4] | s_umak_req[4];
	assign s_umak_pre_req[4] = s_umak_pre_req[3] | s_umak_req[3];
	assign s_umak_pre_req[3] = s_umak_pre_req[2] | s_umak_req[2];
	assign s_umak_pre_req[2] = s_umak_pre_req[1] | s_umak_req[1];
	assign s_umak_pre_req[1] = s_umak_pre_req[0] | s_umak_req[0];
	assign s_umak_pre_req[0] = 1'b0;
	
	assign s_umak_gnt[0] = ~s_umak_pre_req[0] & s_umak_req[0];
	assign s_umak_gnt[1] = ~s_umak_pre_req[1] & s_umak_req[1];
	assign s_umak_gnt[2] = ~s_umak_pre_req[2] & s_umak_req[2];
	assign s_umak_gnt[3] = ~s_umak_pre_req[3] & s_umak_req[3];
	assign s_umak_gnt[4] = ~s_umak_pre_req[4] & s_umak_req[4];
	assign s_umak_gnt[5] = ~s_umak_pre_req[5] & s_umak_req[5];
	assign s_umak_gnt[6] = ~s_umak_pre_req[6] & s_umak_req[6];
	assign s_umak_gnt[7] = ~s_umak_pre_req[7] & s_umak_req[7];
	assign s_umak_gnt[8] = ~s_umak_pre_req[8] & s_umak_req[8];
	assign s_umak_gnt[9] = ~s_umak_pre_req[9] & s_umak_req[9];
	
	assign s_gnt[0] = s_mak_gnt[0] | (s_int_mask & s_umak_gnt[0]);
	assign s_gnt[1] = s_mak_gnt[1] | (s_int_mask & s_umak_gnt[1]);
	assign s_gnt[2] = s_mak_gnt[2] | (s_int_mask & s_umak_gnt[2]);
	assign s_gnt[3] = s_mak_gnt[3] | (s_int_mask & s_umak_gnt[3]);
	assign s_gnt[4] = s_mak_gnt[4] | (s_int_mask & s_umak_gnt[4]);
	assign s_gnt[5] = s_mak_gnt[5] | (s_int_mask & s_umak_gnt[5]);
	assign s_gnt[6] = s_mak_gnt[6] | (s_int_mask & s_umak_gnt[6]);
	assign s_gnt[7] = s_mak_gnt[7] | (s_int_mask & s_umak_gnt[7]);
	assign s_gnt[8] = s_mak_gnt[8] | (s_int_mask & s_umak_gnt[8]);
	assign s_gnt[9] = s_mak_gnt[9] | (s_int_mask & s_umak_gnt[9]);
	
	// registered grant signal
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_gnt <= 10'b0;
		end else begin
			if(|s_gnt) begin
				r_gnt <= s_gnt;
			end else if(ACK) begin
				r_gnt <= 10'b0;
			end
		end
	end
	
	assign GNT = r_gnt;
	
endmodule