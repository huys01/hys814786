`timescale 1 ns/1 ps
// =============================================================================
// TOKYO ELECTRON DEVICE LIMITED.
// =============================================================================
// file name    : UART_TOP.v
// entity       : UART_TOP
// =============================================================================
// architecture : RTL
// level        : 2
// function     : Uart Top Module
// type         : RTL
// -----------------------------------------------------------------------------
// updata history:
// -----------------------------------------------------------------------------
// rev.level    date            coded by        contents
// 0.0.1	    10/26/2007  	 TEDWX)Li.j		 create new
// 1.0.1        10/29/2007  	 TEDWX)Li.j		 add RX error
//                                               dip_sw add one bit to control cts/rts enable
// 1.0.2        2008/09/28       TEDSH)li.yx     1.Add Parity_Check_En
//                                               2.Add Odd/Even Parity Select
//                                               3.Add Stop2/Stop1 Bit Select
//                                               4.User_If Parameter (REG_DT_WIDTH,REG_AD_WIDTH)
// -----------------------------------------------------------------------------
// Update Details :
// -----------------------------------------------------------------------------
// Date         Contents Detail
// =============================================================================
// End revision
// =============================================================================

module UART_TOP #
    (
        // Simulation attributes
        parameter   NOISE_DEL_EN    = "1"           , // 0:Skip Uart Filter ;1: Filte Enable
        parameter   UART_ENABLE     = 1'b1          , // 0:SKIP UART,1: UART ENABLE

        // Uart Config Attributes
        parameter   REG_AD_WIDTH    =  8            , // REG ADDRESS WIDTH
        parameter   REG_DT_WIDTH    =  8              // REG DATA WIDTH
    )
    (
        // clock & reset
        FPGA_CLK		                            , // (i) System clk
        FPGA_RST		                            , // (i) system reset(active high)

        // synopsys translate_off
        // RS232 (uart disable)
        TST_REG_RDVLD		                        , // (o)
        TST_REG_RDT			                        , // (o) [31 : 0]
        TST_REG_REN   		                        , // (i)
        TST_REG_WEN   	                            , // (i)
        TST_REG_WDT			                        , // (i) [31 : 0]
        TST_REG_ADR    	                            , // (i) [ 3 : 0]
        // synopsys translate_on

        // uart
		UART_RXD		                            , // (i)
		CTS				                            , // (i)
		UART_TXD		                            , // (o)
		RTS				                            , // (o)

		// DIP Switch
        DIP_SW         	                            , // (i)// (i) [1:0]baud rate select
        								              // 		"00": 9600bps
        								              // 		"01": 19200bps
        								              // 		"10": 38400bps
        								              // 		"11": 115200bps
        								              //     [2]RTS/CTS enable(1: Enable/0:Disable )
        								              //     [3]Use Parity Enable(1:Use Parity/0: Not use)
        								              //     [4]"0": Even Parity
        								              //        "1": Odd Event Parity
        								              //     [5]Use 2bit Stop Enable(1:Use 2bit stop/0: use 1bit stop)

		// register
		TX_RDY										,
        TX_EN	                                	, // (i)
        TX_DAT			                            , // (i) [31 : 0]
        RX_EN     	                            	, // (o)
        RX_DAT			                              // (o) [31 : 0]
    );

    // clock & reset
    input                           FPGA_CLK		; // (i) System clk
    input                           FPGA_RST		; // (i) system reset(active high)

    // synopsys translate_off
    // RS232 (uart disable)
    output                          TST_REG_RDVLD   ; // (o) REG Read Data Valid
    output  [REG_DT_WIDTH-1 : 0]    TST_REG_RDT	    ; // (o) REG read Data Bus
    input                           TST_REG_REN   	; // (i) REG read enable
    input                           TST_REG_WEN   	; // (i) REG write enable
    input   [REG_DT_WIDTH-1 : 0]    TST_REG_WDT	    ; // (i) REG Write Data
    input   [REG_AD_WIDTH-1 : 0]    TST_REG_ADR     ; // (i) REG Address
    // synopsys translate_on

    // uart
    input                           UART_RXD		; // (i) Uart Rx Port
    input                           CTS				; // (i) Uart Clear to send  Port
    output                          UART_TXD		; // (o) Uart Tx Port
    output                          RTS				; // (o) Uart Request to send Port

    // DIP Switch
    input   [ 5 : 0]                DIP_SW          ; // (i) [1:0]baud rate select
        								              // 		"00": 9600bps
        								              // 		"01": 19200bps
        								              // 		"10": 38400bps
        								              // 		"11": 115200bps
        								              //     [2]RTS/CTS enable(1: Enable/0:Disable )
        								              //     [3]Use Parity Enable(1:Use Parity/0: Not use)
        								              //     [4]"0": Even Parity
        								              //        "1": Odd Event Parity
        								              //     [5]Use 2bit Stop Enable(1:Use 2bit stop/0: use 1bit stop)

    // register
    output							TX_RDY			;
    input                           TX_EN	    	; // (i) REG Read Data Valid
    input   [REG_DT_WIDTH-1 : 0]    TX_DAT			; // (i) REG read Data Bus
    output                          RX_EN     		; // (o) REG read enable
    output  [REG_DT_WIDTH-1 : 0]    RX_DAT			; // (o) REG Write Data

//    parameter   P_10ms_cnt 	= 18'b100111001111101111;
	localparam   P_10ms_cnt 	= 18'h0005;

    wire                            s_baud_rate	    ;
	wire                            s_rx_err        ; // v 1.0.1
	wire                            s_rx_dvld	    ;
	wire    [ 7 : 0]                s_rx_dt		    ;

	wire                            s_tx_ready	    ;
	wire                            s_tx_dvld	    ;
	wire    [ 7 : 0]                s_tx_dt		    ;

	reg     [17 : 0]                r_10ms_cnt	    ; // v 1.0.1
	reg     [ 3 : 0]                r_din_lat0	    ; // v 1.0.1
	reg     [ 3 : 0]                r_din_lat1	    ; // v 1.0.1
	reg     [ 3 : 0]                r_din_lat2	    ; // v 1.0.1
	reg     [ 3 : 0]                r_din_lat3	    ; // v 1.0.1
	reg     [ 3 : 0]                r_din_lat4	    ; // v 1.0.1
	reg     [ 3 : 0]                r_din_lat5	    ; // v 1.0.1

	reg                             r_dout0		    ; // v 1.0.1
	reg                             r_dout1		    ; // v 1.0.1
	reg                             r_dout2		    ; // v 1.0.1
	reg                             r_dout3		    ; // v 1.0.1
	reg                             r_dout4		    ; // v 1.0.1
	reg                             r_dout5		    ; // v 1.0.1

	wire    [ 1 : 0 ]               s_baud_ctrl	    ; // v 1.0.1
    wire                            s_pcctrl_en	    ; // v 1.0.1
    wire                            s_parity_en     ;
    wire                            s_odd_en        ;
    wire                            s_stop2_en      ;

    //=======================================         -- v 1.0.1
    // Dip Switch Noise Delete                        -- v 1.0.1
    //=======================================         -- v 1.0.1
	always @(posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_10ms_cnt <= 18'b0 ;
        end else begin
			if (r_10ms_cnt == P_10ms_cnt) begin
				r_10ms_cnt <= 18'b0 ;
			end else begin
				r_10ms_cnt <= r_10ms_cnt + 1'b1 ;
			end
		end
	end

	// Noise Delete
	always @(posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_din_lat0 <= 4'h0 ;
            r_din_lat1 <= 4'h0 ;
            r_din_lat2 <= 4'h0 ;
            r_din_lat3 <= 4'h0 ;
            r_din_lat4 <= 4'h0 ;
            r_din_lat5 <= 4'h0 ;
        end else begin
			if (r_10ms_cnt == P_10ms_cnt) begin
				r_din_lat0 <= {r_din_lat0[2 : 0] , DIP_SW[0]} ;
            	r_din_lat1 <= {r_din_lat1[2 : 0] , DIP_SW[1]} ;
            	r_din_lat2 <= {r_din_lat2[2 : 0] , DIP_SW[2]} ;
            	r_din_lat3 <= {r_din_lat3[2 : 0] , DIP_SW[3]} ;
            	r_din_lat4 <= {r_din_lat4[2 : 0] , DIP_SW[4]} ;
            	r_din_lat5 <= {r_din_lat5[2 : 0] , DIP_SW[5]} ;
			end
		end
	end

	always @(posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_dout0 <=  1'b0 ;
        end else begin
			if (r_din_lat0 == 4'b1111 || r_din_lat0 == 4'b0000) begin
				r_dout0 <= r_din_lat0[3] ;
			end
		end
	end

	always @(posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_dout1 <=  1'b0 ;
        end else begin
			if (r_din_lat1 == 4'b1111 || r_din_lat1 == 4'b0000) begin
				r_dout1 <= r_din_lat1[3] ;
			end
		end
	end

	always @(posedge FPGA_CLK ) begin
	    if ( FPGA_RST ) begin
	        r_dout2 <=  1'b0 ;
	    end else begin
			if (r_din_lat2 == 4'b1111 || r_din_lat2 == 4'b0000) begin
				r_dout2 <= r_din_lat2[3] ;
			end
		end
	end

	always @(posedge FPGA_CLK ) begin
	    if ( FPGA_RST ) begin
	        r_dout3 <=  1'b0 ;
	        r_dout4 <=  1'b0 ;
            r_dout5 <=  1'b0 ;
	    end else begin
			if (r_din_lat3 == 4'b1111 || r_din_lat3 == 4'b0000) begin
				r_dout3 <= r_din_lat3[3] ;
			end

			if (r_din_lat4 == 4'b1111 || r_din_lat4 == 4'b0000) begin
				r_dout4 <= r_din_lat4[3] ;
			end

			if (r_din_lat5 == 4'b1111 || r_din_lat5 == 4'b0000) begin
				r_dout5 <= r_din_lat5[3] ;
			end

		end
	end

    // synopsys translate_off
    generate
        if (NOISE_DEL_EN == "0") begin: u_del_noise_disable
            assign s_baud_ctrl = DIP_SW[1 : 0] ;
            assign s_pcctrl_en = DIP_SW[2];

            assign s_parity_en = DIP_SW[3];
            assign s_odd_en    = DIP_SW[4];
            assign s_stop2_en  = DIP_SW[5];

        end else begin : u_del_noise_enable
    // synopsys translate_on
            assign s_baud_ctrl = {r_dout1 , r_dout0} ;
    		assign s_pcctrl_en = r_dout2;

    		assign s_parity_en = r_dout3;
            assign s_odd_en    = r_dout4;
            assign s_stop2_en  = r_dout5;

    // synopsys translate_off
        end
    endgenerate
    // synopsys translate_on

	//=======================================
    // Uart Rx Module
    //=======================================
    UART_RX U_UART_RX (
        // clock & reset
        .FPGA_CLK           (FPGA_CLK           ),
        .FPGA_RST		    (FPGA_RST           ),

        // uart
        .IRXD			    (UART_RXD           ),
        .ORTS		        (RTS                ),
        .IRTS_EN            (s_pcctrl_en        ),
        .IPARITY_EN		    (s_parity_en        ),
		.IODD_PARITY		(s_odd_en	        ),

        // Baud Rate Generate
        .IBAUD_RATE		    (s_baud_rate        ),

        // User Interface
        .ORX_DVLD		    (RX_EN          	),
        .ORX_ERR            (s_rx_err           ),
        .ORX_DT			    (RX_DAT            	)

        )  ;

    //=======================================
    // Uart Tx Module
    //=======================================
    UART_TX U_UART_TX (
        // clock & reset
        .FPGA_CLK		    (FPGA_CLK           ),
        .FPGA_RST		    (FPGA_RST           ),

        // uart
    	.OTXD			    (UART_TXD           ),
    	.ICTS		        (CTS                ),
    	.ICTS_EN            (s_pcctrl_en        ),
    	.IPARITY_EN		    (s_parity_en		),
		.IODD_PARITY		(s_odd_en			),
		.ISTOP2_EN		    (s_stop2_en		    ),

        // Baud Rate Generate
    	.IBAUD_RATE		    (s_baud_rate        ),

        // User Interface
    	.OTX_READY			(TX_RDY             ),
    	.ITX_DVLD			(TX_EN          	),
        .ITX_DT				(TX_DAT            	)

        ) ;

    //=======================================
    // Uart Baud Rate Generate
    //=======================================
    UART_BAUDRATE U_UART_BAUDRATE (
        .FPGA_CLK		    (FPGA_CLK           ),
        .FPGA_RST		    (FPGA_RST          ),
        .BAUD_CTRL 		    (s_baud_ctrl        ),
    	.OBAUD_RATE		    (s_baud_rate        )

        ) ;

endmodule