
`timescale 1 ps/1 ps

module I2C_master (
//system clock & reset
	input			CLK				,	//50MHz clock 
	input			RST				,	//Active high
//user interface 
	input			USR_trig		,	//I2C transmit trig pulse,Active High 
	input			USR_rnw			,	//I2C transmit direction, 1:Read/0:Write
	input	[ 7:0]	USR_wrcyc		,	//I2C Write cycle
	input	[ 7:0]	USR_rdcyc		,	//I2C Read cycle
	input	[ 7:0]	USR_deivce_id	,	//I2C transmit Device ID
	input	[ 7:0]	USR_reg_addr	,	//I2C transmit Register Address
	output			USR_wvld		,	//I2C transmit write fetch signal 
	input	[ 7:0]	USR_wdata		,	//I2C transmit write data
	output			USR_rvld		,	//I2C transmit read data valid pulse 
	output	[ 7:0]	USR_rdata		,	//I2C transmit read data
	output			USR_error		,	//I2C status feedback,1:No Ack(abnormal)/0:Ack(normal)
	output			USR_end			,	//I2C transmit end signal 
	//i2c interface 
	output			I2C_scl			,	//I2C clock pin
	input			I2C_sda_in		,	//I2C data line pin
	output			I2C_sda_out		
);	
	localparam		P_CLK_PERIOD	= 50_000_000;
	localparam		p_scl_pcnt		= P_CLK_PERIOD/100_000;
	localparam		p_ack_level		= 1'b0		;

	// internal signal defination 
	localparam 	st_IDLE		= 6'b00_0001	, // Idle
				st_START	= 6'b00_0010	, // Start
				st_RSTART	= 6'b00_0100	, // Re-Start
				st_TX		= 6'b00_1000	, // Transmit
				st_ACK		= 6'b01_0000	, // Ack
				st_STOP		= 6'b10_0000	; // Stop


	reg		[ 9:0]	r_scl_pcnt 			;
	reg				r_scl_rp 			;
	reg				r_scl_fp 			;
	reg				r_sda_lat			;
	reg				r_trig 				;
	reg				r_rnw 				;
	reg		[ 7:0]	r_device_id 		;
	reg		[ 7:0]	r_reg_addr 			;
	reg		[ 7:0]	r_wdata 			;
	reg				r_fsm_trig 			;
	reg		[ 5:0]	r_FSM 				;
	reg		[ 7:0]	r_phase_cnt 		;
	wire			s_phase_cnt_eq0 	;
	wire			s_phase_cnt_eq1		;
	reg		[ 2:0]	r_sdata_cnt 		;
	wire			s_sdata_cnt_eq0 	;
	reg				r_restart_flag		;
	reg				r_restart_period	;
	reg		[ 8:0]	r_sda_release_shf	;
	reg				r_1st_did_flag		;
	reg				r_2nd_did_flag      ;
	reg				r_wdata_fetch		;
	reg				r_rdata_valid		;
	wire			s_sda_in			;
	reg		[ 7:0] 	r_rdata				;
	reg				r_dev_nack			;
	reg				r_tx_end			;
	reg		[ 8:0]	r_sda_shf			;
	reg				r_int_scl			;
	wire			s_int_sda			;
	wire			s_int_sda_release	;
	reg				r_int_sda_o			;
	reg				r_int_sda_t         ;
	wire			s_ack_level			;

	//=======================================================
	// SCL cycle-period counter generation
	//=======================================================
	//SCL period counter 
	always @(posedge CLK ) begin
		if(RST) begin 
			r_scl_pcnt <= 10'b0;
		end else begin 
			if(r_scl_pcnt == p_scl_pcnt) begin 
				r_scl_pcnt <= 10'b0;
			end else begin 
				r_scl_pcnt <= r_scl_pcnt + 1;
			end 
		end 
	end
	
	//SCL rise edge and falling edge generate 
	always @(posedge CLK ) begin
		if(RST) begin 
			r_scl_rp <= 1'b0;
			r_scl_fp <= 1'b0;
			r_sda_lat <= 1'b0;
		end else begin 
			if(r_scl_pcnt == {1'b0,p_scl_pcnt[9:1]}) begin 
				r_scl_rp <= 1'b1;
			end else begin 
				r_scl_rp <= 1'b0;
			end 
			if(r_scl_pcnt == p_scl_pcnt) begin 
				r_scl_fp <= 1'b1;
			end else begin 
				r_scl_fp <= 1'b0;
			end 
//			if(r_scl_pcnt == {2'b00,p_scl_pcnt[9:2]}) begin 
			if(r_scl_pcnt == 10'H08) begin 						//Hold time = 5*tCLK
				r_sda_lat <= 1'b1;
			end else begin 
				r_sda_lat <= 1'b0;
			end 
		end 
	end

	//=======================================================
	// USER identification latch for transmit 
	//=======================================================
	always @(posedge CLK ) begin
		if(RST) begin 
			r_trig 		<= 1'b0;
			r_rnw 		<= 1'b0;
			r_device_id <= 8'b0;
			r_reg_addr 	<= 8'b0;
			r_wdata 	<= 8'b0;
		end else begin 
			if(USR_trig || r_scl_fp) begin 
				r_trig <= USR_trig;
			end 
			if(USR_trig && r_FSM == st_IDLE) begin 
				r_rnw 		<= USR_rnw		;
				r_device_id <= USR_deivce_id;
				r_reg_addr 	<= USR_reg_addr	;
			end
			if ( r_wdata_fetch ) begin
				r_wdata 	<= USR_wdata	;
			end
		end 
	end

	//=======================================================
	// I2C transmit state-machine
	//=======================================================
	always @(posedge CLK ) begin
		if(RST) begin 
			r_fsm_trig <= 1'b0;
		end else begin 
			r_fsm_trig <= r_trig & r_scl_fp;
		end 
	end

	always @(posedge CLK ) begin
		if (RST) begin
			r_FSM <= st_IDLE;
		end else begin
			case (r_FSM)
				st_IDLE 	: begin 
					if(r_fsm_trig) begin 
						r_FSM <= st_START;
					end else begin 
						r_FSM <= st_IDLE;
					end 
				end 
				
				st_START	: begin 
					if(r_scl_fp) begin 
						r_FSM <= st_TX;
					end else begin 
						r_FSM <= st_START;
					end 
				end
					
				st_RSTART	: begin 
					if(r_scl_fp && r_restart_period) begin 
						r_FSM <= st_TX;
					end else begin 
						r_FSM <= st_RSTART;
					end 
				end
				
				st_TX		: begin 
					if(r_scl_fp) begin  
						if(s_sdata_cnt_eq0) begin 
							r_FSM <= st_ACK;
						end else begin 
							r_FSM <= st_TX;
						end 
					end else begin 
						r_FSM <= st_TX;
					end 
				end 
				
				st_ACK		: begin 
					if(r_scl_fp) begin 
						if(s_phase_cnt_eq0) begin 
//							if(r_restart_flag) begin 
//								r_FSM <= st_RSTART;
//							end else begin 
								r_FSM <= st_STOP;
//							end 
						end else begin 
							r_FSM <= st_TX;
						end 
					end else begin 
						r_FSM <= st_ACK;
					end 
				end 
				
				st_STOP		:
					if(r_scl_fp) begin 
						if ( r_restart_flag ) begin
							r_FSM <= st_RSTART;
						end else begin
							r_FSM <= st_IDLE;
						end
					end else begin 
						r_FSM <= st_STOP;
					end 
					
				default		:
					r_FSM <= st_IDLE ;
					
			endcase
		end
	end

	// transmit phase counter
	always @(posedge CLK ) begin
		if(RST) begin 
			r_phase_cnt <= 8'b00;
		end else begin 
			if(r_FSM == st_START && r_scl_fp) begin 
				if(r_rnw) begin 
					r_phase_cnt <= 8'h01;
				end else begin 
					r_phase_cnt <= USR_wrcyc + 1;
				end 
			end else if(r_FSM == st_RSTART && r_scl_fp) begin 
				r_phase_cnt <= USR_rdcyc;
			end else if(r_FSM == st_ACK && r_scl_fp && !s_phase_cnt_eq0) begin 
				r_phase_cnt <= r_phase_cnt - 1;
			end 
		end 
	end

	assign s_phase_cnt_eq0 = ~|r_phase_cnt;
	assign s_phase_cnt_eq1 = ~|r_phase_cnt[7:1] & r_phase_cnt[0];

	// transmit data counter 
	always @(posedge CLK ) begin
		if(RST) begin 
			r_sdata_cnt <= 3'b000;
		end else begin 
			if(r_FSM == st_START && r_scl_fp) begin 
				r_sdata_cnt <= 3'b111;
			end else if(r_FSM == st_RSTART && r_scl_fp && r_restart_period) begin
				r_sdata_cnt <= 3'b111;
			end else if(r_FSM == st_ACK && r_scl_fp && !s_phase_cnt_eq0) begin 
				r_sdata_cnt <= 3'b111;
			end else if(r_FSM == st_TX && r_scl_fp) begin 
				r_sdata_cnt <= r_sdata_cnt - 1;
			end 
		end 
	end
	
	assign s_sdata_cnt_eq0 = ~|r_sdata_cnt; 
	
	// restart flag generate 
	always @(posedge CLK ) begin
		if(RST) begin 
			r_restart_flag <= 1'b0;
		end else begin 
			if(r_FSM == st_START && r_scl_fp) begin 
				r_restart_flag <= r_rnw;
			end else if(r_FSM == st_RSTART && r_scl_fp) begin 
				r_restart_flag <= 1'b0;
			end 
		end 
	end

	// restart period flag
	always @(posedge CLK ) begin
		if(RST) begin 
			r_restart_period <= 1'b0;
		end else begin 
			if(r_FSM == st_RSTART && r_scl_fp) begin 
				r_restart_period <= 1'b1;
			end else if(r_FSM == st_IDLE) begin 
				r_restart_period <= 1'b0;
			end 
		end 
	end

	// device id transmit flag generate 
	always @(posedge CLK ) begin
		if(RST) begin 
			r_1st_did_flag <= 1'b0;
			r_2nd_did_flag <= 1'b0;
		end else begin 
			if(r_FSM == st_START && r_scl_fp) begin 
				r_1st_did_flag <= 1'b1;
			end else if(r_FSM == st_ACK && r_scl_fp) begin 
				r_1st_did_flag <= 1'b0;
			end 
			if(r_FSM == st_RSTART && r_scl_fp && r_restart_period) begin 
				r_2nd_did_flag <= 1'b1;
			end else if(r_FSM == st_ACK && r_scl_fp) begin 
				r_2nd_did_flag <= 1'b0;
			end 
		end 
	end

	//=======================================================
	// Data fetch pulse@TX & data valid pulse@RX controller
	//=======================================================
	// data fetch pulse@TX generate 
	always @(posedge CLK ) begin
		if(RST) begin 
			r_wdata_fetch <= 1'b0;
		end else begin 
			if(r_FSM == st_ACK && r_scl_fp) begin 
				r_wdata_fetch <= ~r_rnw & ~s_phase_cnt_eq1 & ~s_phase_cnt_eq0;
			end else begin 
				r_wdata_fetch <= 1'b0;
			end 
		end 
	end

	assign USR_wvld = r_wdata_fetch;

	// data valid pulse@RX generate 
	always @(posedge CLK ) begin
		if(RST) begin 
			r_rdata_valid <= 1'b0;
		end else begin 
			if(r_FSM == st_ACK && r_scl_rp) begin 
				r_rdata_valid <= r_restart_period & ~r_2nd_did_flag;
			end else begin 
				r_rdata_valid <= 1'b0;
			end 
		end 
	end

//	assign s_sda_in = I2C_sda_in;			//Filter is needed perhaps!!!!
	filter u00(.clk(CLK),.rst(RST),.din(I2C_sda_in),.dout(s_sda_in));

	// data parallel@RX generate 
	always @(posedge CLK ) begin
		if(RST) begin
			r_rdata <= 8'b00;
		end else begin 
			if(r_scl_fp) begin 
				r_rdata <= {r_rdata[6:0],s_sda_in};
			end 
		end 
	end

	assign USR_rvld 	= r_rdata_valid;
	assign USR_rdata    = r_rdata;

	//=======================================================
	// Device Ack && end signal check
	//=======================================================
	always @(posedge CLK ) begin
		if(RST) begin 
			r_dev_nack <= 1'b0;
		end else begin 
			if(r_FSM == st_IDLE && r_fsm_trig) begin 
				r_dev_nack <= 1'b0;
			end else if(r_FSM == st_ACK && s_int_sda_release && r_scl_fp) begin 
				r_dev_nack <= s_sda_in;
			end 
		end 
	end

	always @(posedge CLK ) begin
		if(RST) begin 
			r_tx_end <= 1'b0;
		end else begin 
			if(r_FSM == st_STOP && r_scl_fp && ~r_restart_flag) begin 
				r_tx_end <= 1'b1;
			end else begin 
				r_tx_end <= 1'b0;
			end 
		end 
	end
	
	assign USR_error = r_dev_nack;
	assign USR_end   = r_tx_end;

	//=======================================================
	// SCL & SDA signal generate 
	//=======================================================
	// scl signal generate 
	always @(posedge CLK ) begin
		if(RST) begin 
			r_int_scl <= 1'b1;
		end else begin 
			if(r_scl_fp) begin 
				if(r_FSM == st_RSTART && !r_restart_period) begin 
					r_int_scl <= r_int_scl;
				end else if(r_FSM == st_IDLE ||r_FSM == st_STOP) begin 
					r_int_scl <= r_int_scl;
				end else begin 
					r_int_scl <= 1'b0;
				end 
			end else if(r_scl_rp) begin 
				r_int_scl <= 1'b1;
			end 
		end 
	end
	
	//sda bus release signal generate 
	always @(posedge CLK ) begin
		if(RST) begin 
			r_sda_release_shf <= 9'b0;
		end else begin 
			if(r_FSM == st_START && r_scl_fp) begin 
				r_sda_release_shf <= 9'b0_0000_0001;
			end else if(r_FSM == st_RSTART && r_scl_fp) begin 
				r_sda_release_shf <= 9'b0_0000_0001;
			end else if(r_FSM == st_ACK && r_scl_fp && !s_phase_cnt_eq0) begin
				if(r_restart_period) begin 
					r_sda_release_shf <= 9'b1_1111_1110;
				end else begin 
					r_sda_release_shf <= 9'b0_0000_0001;
				end 
			end else if(r_scl_fp)begin 
				r_sda_release_shf <= {r_sda_release_shf[7:0],1'b0};
			end 
		end 
	end
	
	assign s_int_sda_release = r_sda_release_shf[8];
	
	//sda bus data generate 
	assign s_ack_level = p_ack_level;
	
	always @(posedge CLK ) begin
		if(RST) begin 
			r_sda_shf <= 9'b1_1111_1111;
		end else begin 
			if(r_FSM == st_IDLE && r_fsm_trig) begin 
				r_sda_shf <= 9'b0;
			end else if(r_FSM == st_START && r_scl_fp) begin 
				r_sda_shf <= {r_device_id[6:0],1'b0,1'b1};
			end else if(r_FSM == st_RSTART && r_scl_fp) begin 
				if(r_restart_period) begin 
					r_sda_shf <= {r_device_id[6:0],1'b1,1'b1};
				end else begin 
					r_sda_shf <= 9'b0;
				end 
			end else if(r_FSM == st_ACK && r_scl_fp) begin 
				if(!s_phase_cnt_eq0) begin 
					if(r_1st_did_flag) begin 
						r_sda_shf <= {r_reg_addr,1'b1};
					end else begin 
						if(r_rnw) begin
							if(s_phase_cnt_eq1) begin 
								r_sda_shf <= {8'b0,~s_ack_level};
							end else begin 
								r_sda_shf <= {8'h0,s_ack_level};
							end 
						end else begin 
							r_sda_shf <= {r_wdata[7:0],1'b1};
						end 
					end 
				//end else if(!r_restart_flag) begin 
				end else begin 
					r_sda_shf <= 9'H0FF;
				end 
			end else if(r_scl_fp) begin 
				r_sda_shf <= {r_sda_shf[7:0],1'b1};
			end 
		end 
	end
	
	assign s_int_sda = r_sda_shf[8];
	
	always @(posedge CLK ) begin
		if(RST) begin 
			r_int_sda_o <= 1'b1;
			r_int_sda_t <= 1'b1;
		end else begin 
			if(r_sda_lat) begin 
				r_int_sda_o <= s_int_sda;
				r_int_sda_t <= s_int_sda_release | s_int_sda;
			end 
		end 
	end

	assign I2C_scl		= r_int_scl;
//	assign I2C_sda	    = r_int_sda_t ? 1'bz : 1'b0;
	assign I2C_sda_out	= r_int_sda_t;

	
//synopsys translate_off
	reg		[8*7:1]	FSM_monitor;
	
	always @(r_FSM) begin
		case (r_FSM) 
			st_IDLE		:	FSM_monitor = "IDLE	  "	;
			st_START    :   FSM_monitor = "START  "	;
			st_RSTART   :   FSM_monitor = "RSTART "	;
			st_TX       :   FSM_monitor = "TX     "	;
			st_ACK      :   FSM_monitor = "ACK    "	;
			st_STOP     :   FSM_monitor = "STOP   "	;
		endcase
	end
//synopsys translate_on
	
endmodule