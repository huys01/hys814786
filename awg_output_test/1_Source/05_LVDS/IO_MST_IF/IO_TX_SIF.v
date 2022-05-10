
`timescale 1ns/ 1ps

module IO_TX_SIF # (
	parameter   P_5MS 			= 20'hf4240	,
	parameter 	C_DATA_WIDTH	= 59
) (
	// Clock & Reset
	input							CLK			,
	input							RST			,
	// Serial Interface
	input							IO_RX		,
	output							IO_TX       ,
	// Train Signal
	output	[C_DATA_WIDTH*8-1:0]	TRAIN_DAT   ,
	output							TRAIN_DONE	
);

	// ============================================
    // Internal Signal Define
    // ============================================
	localparam	C_DATA_WIDTH_x8	= C_DATA_WIDTH*8			;

	reg		[ 3:0]					r_m_fsm					;
    localparam						st_m_idle		= 4'h0	;
    localparam						st_m_init		= 4'h1	;
    localparam						st_m_start  	= 4'h2	;
    localparam						st_m_wait   	= 4'h3	;
    localparam						st_m_step1  	= 4'h4	;
    localparam						st_m_step2  	= 4'h5	;
    localparam						st_m_step3  	= 4'h6	;
    localparam						st_m_end    	= 4'h7	;
    localparam						st_m_train_done = 4'h8	;

	wire							s_tx_rdy				;
    wire							s_tx_en 				;
    wire	[ 7:0]					s_tx_dat            	;
    wire							s_rx_en             	;
    wire	[ 7:0]					s_rx_dat            	;
	reg								r_mst_start_ack			;
	reg								r_mst_step1_ack 		;
	reg								r_mst_step2_ack 		;
	reg								r_mst_step3_ack 		;
	reg		[19:0]					r_ms_cnt				;
	wire							s_ms_cnt_eq0			;
	reg		[ 5:0]					r_200ms_cnt				;
	wire							s_200ms_cnt_eq0			;
	reg		[ 1:0]					r_m_cnt					;
	wire							s_m_cnt_eq0				;
	reg	    [C_DATA_WIDTH_x8-1:0]	r_wdata         		;
	reg								r_mst_start_req 		;
	reg								r_mst_tx				;
	reg		[ 1:0]					r_mst_tdat				;
	reg								r_m_init_done			;
	reg								r_tx_en             	;
    reg		[ 7:0]					r_tx_dat            	;

	///////////////////////////////////////////////////
	// Serial Module
	///////////////////////////////////////////////////
	UART_TOP # (
        // Simulation attributes
    	.NOISE_DEL_EN			("0" 			),
    	.UART_ENABLE 			(1'b1       	),

    	// Uart Config Attributes
    	.REG_AD_WIDTH    		(8          	),
    	.REG_DT_WIDTH    		(8          	)
    	)
    io_rx_tx (
        // clock & reset
        .FPGA_CLK				(CLK			),
        .FPGA_RST          		(RST      		),

        // synopsys translate_off
        // RS232 (uart disable)
        .TST_REG_RDVLD			(           	),
        .TST_REG_RDT            (           	),
        .TST_REG_REN            (1'b0       	),
        .TST_REG_WEN            (1'b0       	),
        .TST_REG_WDT            (8'h0       	),
        .TST_REG_ADR            (8'h0       	),
        // synopsys translate_on

        // uart
		.UART_RXD               (IO_RX      	),
		.CTS                    (1'b0       	),
		.UART_TXD               (IO_TX      	),
		.RTS                    (           	),
		// DIP Switch
        .DIP_SW                 (6'h3      		),
		// register

		.TX_RDY					(s_tx_rdy		),
		.TX_EN                  (s_tx_en    	),
		.TX_DAT                 (s_tx_dat   	),
		.RX_EN                  (s_rx_en    	),
		.RX_DAT                 (s_rx_dat   	)
    );

    // ############### Master Control #################
	always @ ( posedge CLK ) begin
        if ( RST ) begin
			r_mst_start_ack	<= 1'b0;
			r_mst_step1_ack <= 1'b0;
			r_mst_step2_ack <= 1'b0;
			r_mst_step3_ack <= 1'b0;
		end else begin
			if (s_rx_en) begin
				case (s_rx_dat)
					8'h58		:	begin
									r_mst_start_ack	<= 1'b1;
									r_mst_step1_ack <= 1'b0;
									r_mst_step2_ack <= 1'b0;
									r_mst_step3_ack <= 1'b0;
									end

					8'h59		:	begin
									r_mst_start_ack	<= 1'b0;
									r_mst_step1_ack <= 1'b1;
									r_mst_step2_ack <= 1'b0;
									r_mst_step3_ack <= 1'b0;
									end

					8'h5a		:	begin
									r_mst_start_ack	<= 1'b0;
									r_mst_step1_ack <= 1'b0;
									r_mst_step2_ack <= 1'b1;
									r_mst_step3_ack <= 1'b0;
									end

					8'h5b		:	begin
									r_mst_start_ack	<= 1'b0;
									r_mst_step1_ack <= 1'b0;
									r_mst_step2_ack <= 1'b0;
									r_mst_step3_ack <= 1'b1;
									end

					default		:	begin
									r_mst_start_ack	<= 1'b0;
									r_mst_step1_ack <= 1'b0;
									r_mst_step2_ack <= 1'b0;
									r_mst_step3_ack <= 1'b0;
									end
				endcase
			end else begin
				r_mst_start_ack	<= 1'b0;
				r_mst_step1_ack <= 1'b0;
				r_mst_step2_ack <= 1'b0;
				r_mst_step3_ack <= 1'b0;
			end
		end
	end

	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_m_fsm <= st_m_idle;
		end else begin
			case (r_m_fsm)
				st_m_idle		:	r_m_fsm <= st_m_init;

				st_m_init		:	if (s_200ms_cnt_eq0 & s_ms_cnt_eq0) begin
										r_m_fsm <= st_m_start;
									end

				st_m_start		:	r_m_fsm <= st_m_wait;

				st_m_wait		:	if (r_mst_start_ack) begin
										r_m_fsm <= st_m_step1;
									end else if (s_200ms_cnt_eq0 & s_ms_cnt_eq0) begin
										r_m_fsm <= st_m_start;
									end

				st_m_step1		:	if (r_mst_step1_ack) begin
										r_m_fsm <= st_m_step2;
									end

				st_m_step2		:	if (r_mst_step2_ack) begin
										r_m_fsm <= st_m_step3;
									end

				st_m_step3		:	if (r_mst_step3_ack) begin
										r_m_fsm <= st_m_end;
									end

				st_m_end		:	if (s_200ms_cnt_eq0) begin
										r_m_fsm <= st_m_train_done;
									end

//				st_m_train_done	:	r_m_fsm <= st_m_idle;
				st_m_train_done	:	r_m_fsm <= st_m_train_done;

				default			:	r_m_fsm <= st_m_idle;
			endcase
		end
	end

	// 5 ms
	always @(posedge CLK ) begin
		if( RST ) begin
			r_ms_cnt <= P_5MS;
		end else begin
			if (r_m_fsm != st_m_idle) begin
				if (s_ms_cnt_eq0) begin
					r_ms_cnt <= P_5MS;
				end else begin
					r_ms_cnt <= r_ms_cnt - 1'b1;
				end
			end
		end
	end
	
	assign s_ms_cnt_eq0 = ~|r_ms_cnt;
	
	// 200 ms
	always @(posedge CLK ) begin
		if( RST ) begin
			r_200ms_cnt <= 6'h28;
		end else begin
			if (r_m_fsm == st_m_step3) begin
				r_200ms_cnt <= 6'h28;
			end else if (r_m_fsm != st_m_idle)begin
				if (s_ms_cnt_eq0) begin
					if (s_200ms_cnt_eq0) begin
						r_200ms_cnt <= 6'h28;
					end else begin
						r_200ms_cnt <= r_200ms_cnt - 1'b1;
					end
				end
			end
		end
	end
	
	assign s_200ms_cnt_eq0 = ~|r_200ms_cnt;
	
	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_m_cnt <= 2'b0;
		end else begin
			if (r_m_fsm == st_m_step2) begin
				r_m_cnt <= 20'h3;
			end else if (r_m_fsm == st_m_step3 && s_m_cnt_eq0 == 1'b1) begin
				r_m_cnt <= 20'h3;
			end else begin
				r_m_cnt <= r_m_cnt - 1'b1;
			end
		end
	end

	assign s_m_cnt_eq0 = ~|r_m_cnt;

	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_wdata <= {C_DATA_WIDTH_x8{1'b0}};
		end else begin
			case (r_m_fsm)
				st_m_step1	:	r_wdata <= {C_DATA_WIDTH{8'H55}};	// 5

				st_m_step2	:	r_wdata <= {C_DATA_WIDTH{8'H82}};	// 9

				st_m_step3	:	if (r_m_cnt[1:0] == 2'b11) begin
									r_wdata <= {C_DATA_WIDTH{8'H55}};	// 5
								end else if (r_m_cnt[1:0] == 2'b10) begin
									r_wdata <= {C_DATA_WIDTH{8'HAA}};	// a
								end else if (r_m_cnt[1:0] == 2'b01) begin
									r_wdata <= {C_DATA_WIDTH{8'H99}};	// 9
								end else begin
									r_wdata <= {C_DATA_WIDTH{8'H66}};	// 6
								end

				default		:	r_wdata <= {C_DATA_WIDTH{1'b0}};
			endcase
		end
	end

	always @ ( posedge CLK ) begin
		if ( RST ) begin
			r_mst_start_req <= 1'b0;
		end else begin
			if (r_m_fsm == st_m_start) begin
				r_mst_start_req <= 1'b1;
			end else begin
				r_mst_start_req <= 1'b0;
			end
        end
    end

	assign TRAIN_DAT = r_wdata;

	always @ ( posedge CLK ) begin
        if ( RST ) begin
			r_mst_tx	<= 1'b0;
			r_mst_tdat  <= 2'b0;
		end else begin
			if (r_mst_start_req | r_mst_start_ack | r_mst_step1_ack | r_mst_step2_ack) begin
				r_mst_tx	<= 1'b1;
			end else begin
				r_mst_tx	<= 1'b0;
			end

			if (r_mst_start_req) begin
				r_mst_tdat	<= 2'b00;
			end else if (r_mst_start_ack) begin
				r_mst_tdat	<= 2'b01;
			end else if (r_mst_step1_ack) begin
				r_mst_tdat	<= 2'b10;
			end else begin
				r_mst_tdat	<= 2'b11;
			end
        end
    end

    always @ ( posedge CLK ) begin
        if ( RST ) begin
			r_m_init_done <= 1'b0;
		end else begin
			if (r_m_fsm ==  st_m_train_done) begin
				r_m_init_done <= 1'b1;
			end
        end
    end

    assign TRAIN_DONE = r_m_init_done;

    always @ ( posedge CLK ) begin
        if ( RST ) begin
			r_tx_en	<= 1'b0;
			r_tx_dat<= 8'b0;
		end else begin
			r_tx_en <= r_mst_tx;

			if (r_mst_tx) begin
				r_tx_dat<= {4'h5, 2'b01,r_mst_tdat};
			end

        end
    end

    assign s_tx_en 	= r_tx_en;
    assign s_tx_dat	= r_tx_dat;

endmodule