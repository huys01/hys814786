
`timescale 1ns/ 1ps

module RR_ARB5 (
	CLK				,
	XRST			,

	REQ				,
	ACK				,

	GNT
	);

	input			CLK		;
	input			XRST	;

	input	[ 4:0]	REQ		;
	input			ACK		;

	output	[ 4:0]	GNT		;

	reg		[ 2:0] 	r_reg_pointer		; // arbiter round pointer
	reg		[ 4:0] 	r_mask				; // arbiter input mask
	wire			s_mask_all			; // all arbter input mask
	wire	[ 4:0] 	s_mask_req			; // masked request
	wire		 	s_int_mask			; // internal mask
	wire	[ 4:0] 	s_msk_pre_req		; // pre masked request
	wire	[ 4:0] 	s_mak_gnt			; // grant mask
	wire	[ 4:0] 	s_umak_req			; // unmasked request
	wire	[ 4:0] 	s_umak_pre_req		; // pre-unmasked request
	wire	[ 4:0] 	s_umak_gnt			; // no Grant mask
	wire	[ 4:0] 	s_gnt				; // grant signal bus
	reg		[ 4:0] 	r_gnt				; // grant signal bus


    // request pointer generation
     always @( posedge CLK ) begin
    	if (XRST) begin
    		r_reg_pointer <= 3'b0;
    	end else begin
    		if(s_gnt[0]) begin
    			r_reg_pointer <= 3'b001;
    		end else if(s_gnt[1]) begin
    			r_reg_pointer <= 3'b010;
    		end else if(s_gnt[2]) begin
    			r_reg_pointer <= 3'b011;
    		end else if(s_gnt[3]) begin
    			r_reg_pointer <= 3'b100;
    		end else if(s_gnt[4]) begin
    			r_reg_pointer <= 3'b000;
    		end
		end
	end

    // request mask signal generation

     always @(r_reg_pointer) begin
     	case (r_reg_pointer)
     		3'b000		: r_mask = 5'b11111;
     		3'b001		: r_mask = 5'b11110;
     		3'b010		: r_mask = 5'b11100;
     		3'b011		: r_mask = 5'b11000;
     		3'b100		: r_mask = 5'b10000;
     		default 	: r_mask = 5'b11111;
    	endcase
	end

	assign s_mask_all = |r_gnt;

	// masked request generation

	assign s_mask_req[0] = s_mask_all ? 1'b0 : (r_mask[0] & REQ[0]);
	assign s_mask_req[1] = s_mask_all ? 1'b0 : (r_mask[1] & REQ[1]);
	assign s_mask_req[2] = s_mask_all ? 1'b0 : (r_mask[2] & REQ[2]);
	assign s_mask_req[3] = s_mask_all ? 1'b0 : (r_mask[3] & REQ[3]);
	assign s_mask_req[4] = s_mask_all ? 1'b0 : (r_mask[4] & REQ[4]);

	assign s_int_mask	= ~((r_mask[0] & REQ[0]) |
	                        (r_mask[1] & REQ[1]) |
	                        (r_mask[2] & REQ[2]) |
	                        (r_mask[3] & REQ[3]) |
	                        (r_mask[4] & REQ[4]));

	// masked simple priority arbiter

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

	// unmasked Request generation
	assign s_umak_req[0] = s_mask_all ? 1'b0 : REQ[0];
	assign s_umak_req[1] = s_mask_all ? 1'b0 : REQ[1];
	assign s_umak_req[2] = s_mask_all ? 1'b0 : REQ[2];
	assign s_umak_req[3] = s_mask_all ? 1'b0 : REQ[3];
	assign s_umak_req[4] = s_mask_all ? 1'b0 : REQ[4];

	// unmasked simple priority arbiter
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

	assign s_gnt[0] = s_mak_gnt[0] | (s_int_mask & s_umak_gnt[0]);
	assign s_gnt[1] = s_mak_gnt[1] | (s_int_mask & s_umak_gnt[1]);
	assign s_gnt[2] = s_mak_gnt[2] | (s_int_mask & s_umak_gnt[2]);
	assign s_gnt[3] = s_mak_gnt[3] | (s_int_mask & s_umak_gnt[3]);
	assign s_gnt[4] = s_mak_gnt[4] | (s_int_mask & s_umak_gnt[4]);

 	// registered grant signal

     always @( posedge CLK ) begin
    	if (XRST) begin
    		r_gnt <= 5'b0;
    	end else begin
    		if(|s_gnt) begin
    			r_gnt <= s_gnt;
    		end else if(ACK) begin
    			r_gnt <= 5'b0;
    		end
		end
	end

	assign GNT = r_gnt;

endmodule