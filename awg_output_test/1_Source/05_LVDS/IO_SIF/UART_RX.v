`timescale 1 ns/1 ps
// =============================================================================
// TOKYO ELECTRON DEVICE LIMITED.
// =============================================================================
// file name    : UART_RX.v
// entity       : UART_RX
// =============================================================================
// architecture : RTL
// level        : 3
// function     : Uart Receive Module Control(Serial -> Parallel)
// type         : RTL
// -----------------------------------------------------------------------------
// updata history:
// -----------------------------------------------------------------------------
// rev.level  date           coded by        contents
// 0.0.1	  10/26/2007  	 TEDWX)Li.j		 create new
// 1.0.1	  10/29/2007  	 TEDWX)Li.j		 add data parity check and stop bit check
//                                           add RTS enable
// -----------------------------------------------------------------------------
// Update Details :
// -----------------------------------------------------------------------------
// Date         Contents Detail
// =============================================================================
// End revision
// =============================================================================

module UART_RX (

    // clock & reset
    FPGA_CLK		                            ,
    FPGA_RST		                            ,

    // uart
    IRXD			                            ,
    ORTS		                                ,
    IRTS_EN                                     ,
    IPARITY_EN		                            ,
    IODD_PARITY		                            ,

    // Baud Rate Generate
    IBAUD_RATE		                            ,

    // User Interface
    ORX_DVLD		                            ,
    ORX_ERR                                     ,
    ORX_DT

    )  ;

    // clock & reset
    input               FPGA_CLK		        ; // (i) System clk
    input               FPGA_RST		        ; // (i) system reset(active high)

    // uart
    input               IRXD			        ; // (i) Uart Rx Port
    output              ORTS		            ; // (o) Uart Request to send Port
    input               IRTS_EN                 ; // (i) Uart RTS enable (active high) -- v 1.0.1

    input               IPARITY_EN		        ; // (i)
    input               IODD_PARITY		        ; // (i)

    // Baud Rate Generate
    input               IBAUD_RATE		        ; // (i) Uart Baud Rate

    // User Interface
    output              ORX_DVLD				; // S (o) RX Data Valid
    output              ORX_ERR                 ; // S (o) RX parity check or stop bit check error  -- v 1.0.1
    output  [ 7 : 0]    ORX_DT				    ; // S (o) RX Data


    parameter           P_st_idle   = 3'b000 	; // idle
    parameter           P_st_start  = 3'b001	; // start
    parameter           P_st_shift  = 3'b010	; // data shift
    parameter           P_st_pari   = 3'b011	; // parity
    parameter           P_st_stop   = 3'b100	; // stop

    reg     [ 2 : 0]    r_rx_fsm                ;

    reg                 r_rxd                   ;
    reg                 r_rxd_d 	            ;
    reg                 r_rxd_d1 	            ;
    reg     [ 3 : 0]    r_flt_cnt               ;
    reg                 r_rxd_flt               ;
    reg                 r_rxd_flt_d             ;
    reg                 r_rxd_flt_d1            ;

    reg     [ 3 : 0]    r_cnt_16	            ;
    reg     [ 2 : 0]    r_cnt8		            ;
    reg                 r_rx_valid	            ;
    reg     [ 7 : 0]    r_rx_shift	            ;
    wire                s_state_chg		        ;
    wire                s_rxd_falledg           ;
    reg                 r_rts			        ;
    reg                 r_pari                  ;
    reg                 r_rx_err                ;

	// =====================================================
	// RXD Filter
	// =====================================================
    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_rxd   <= 1'b1 ;
            r_rxd_d <= 1'b1 ;
            r_rxd_d1<= 1'b1 ;
        end else begin
            r_rxd   <= IRXD ;
            r_rxd_d <= r_rxd ;
            r_rxd_d1<= r_rxd_d ;
        end
    end

    // filter cnt
    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_flt_cnt <= 4'b0;
        end else begin
            if (r_rxd_d1 == r_rxd_d) begin
                r_flt_cnt <= r_flt_cnt + 1;
            end else begin
                r_flt_cnt <= 4'b0;
            end
        end
    end

    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_rxd_flt <= 1'b1;
        end else begin
            if (r_flt_cnt == 4'hF) begin
                r_rxd_flt <= r_rxd_d1;
            end
        end
    end

	// RXD Falling Edge Detect
	always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_rxd_flt_d     <= 1'b1;
            r_rxd_flt_d1    <= 1'b1;
        end else begin
            if (IBAUD_RATE == 1'b1) begin
                r_rxd_flt_d     <= r_rxd_flt    ;
                r_rxd_flt_d1    <= r_rxd_flt_d  ;
            end
        end
    end

	assign s_rxd_falledg = (~ r_rxd_flt_d) && r_rxd_flt_d1 ;

	// =====================================================
	// Main Control
	// =====================================================
    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_rx_fsm  <= P_st_idle;
        end else begin
            case (r_rx_fsm)

                P_st_idle   :
                	if (s_rxd_falledg == 1'b1 && IBAUD_RATE == 1'b1) begin
                    	r_rx_fsm <= P_st_start ;
                    end else begin
                    	r_rx_fsm <= P_st_idle ;
                 	end

                P_st_start  :
                	if (s_state_chg == 1'b1) begin
                     	if(r_rxd_flt_d1 == 1'b0) begin
                        	r_rx_fsm <= P_st_shift ;
						end else begin
                        	r_rx_fsm <= P_st_idle ;
                     	end
					end

                P_st_shift  :
                	if (s_state_chg == 1'b1) begin
                		if (r_cnt8 == 3'b111) begin
                		    if (IPARITY_EN) begin
                   			    r_rx_fsm <= P_st_pari ;
                   			end else begin
                   			    r_rx_fsm <= P_st_stop ;
                   			end
                   		end else begin
                   			r_rx_fsm <= P_st_shift ;
                		end
                	end

                P_st_pari   :
                	if (s_state_chg ==  1'b1) begin
                  		r_rx_fsm <= P_st_stop ;
                  	end else begin
                  		r_rx_fsm <= P_st_pari ;
                 	end

                P_st_stop   :
                	if (s_state_chg == 1'b1) begin
                  		r_rx_fsm <= P_st_idle ;
                  	end else begin
                  		r_rx_fsm <= P_st_stop ;
                 	end

                default     :
                	r_rx_fsm <= P_st_idle;

            endcase
        end
    end

    // counter 16
    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_cnt_16 <= 4'h0 ;
        end else begin
        	if (r_rx_fsm == P_st_idle) begin
        	    r_cnt_16 <= 4'h0 ;
        	end else if (IBAUD_RATE == 1'b1) begin
        	    r_cnt_16 <= r_cnt_16 + 1'b1 ;
        	end
        end
    end

    // State change condition
    assign s_state_chg = (r_cnt_16 == 4'b1000 && IBAUD_RATE == 1'b1) ? 1'b1 : 1'b0 ;

    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_cnt8 <= 3'b000 ;
        end else begin
            if (r_rx_fsm == P_st_shift) begin
                if (s_state_chg == 1'b1) begin
                    r_cnt8 <= r_cnt8 + 1'b1 ;
                end
			end else begin
				r_cnt8 <= 3'b000 ;
            end
        end
    end

    // RX data
    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_rx_shift <= 8'h00 ;
        end else begin
            if (s_state_chg == 1'b1) begin
                if (r_rx_fsm == P_st_start) begin
                    r_rx_shift <= 8'h00 ;
                end else if (r_rx_fsm == P_st_shift) begin
                    r_rx_shift <= {r_rxd_flt_d1 , r_rx_shift[7 : 1]} ;
                end
            end
        end
    end

    // RX data valid
    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_rx_valid <= 1'b0 ;
        end else begin
            if (r_rx_fsm == P_st_stop && s_state_chg == 1'b1) begin
                r_rx_valid <= 1'b1 ;
            end else begin
                r_rx_valid <= 1'b0 ;
            end
        end
    end

	assign ORX_DVLD = r_rx_valid  ;
    assign ORX_DT = r_rx_shift ;

    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_pari <= 1'b0;
        end else begin
            if ((r_rx_fsm == P_st_shift || r_rx_fsm == P_st_pari ) && s_state_chg == 1'b1) begin
                r_pari <= r_pari ^ r_rxd_flt_d1;
            end else if (r_rx_fsm == P_st_idle) begin
                r_pari <= 1'b0;
            end
        end
    end

    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_rx_err <= 1'b0;
        end else begin
            if (IPARITY_EN) begin
                if (r_rx_fsm == P_st_stop && r_pari != IODD_PARITY) begin
                    r_rx_err <= 1'b1;
                end
            end else if (r_rx_fsm == P_st_stop && s_state_chg == 1'b1 && r_rxd_flt_d1 != 1'b1) begin
                r_rx_err <= 1'b1;
            end else begin
                r_rx_err <= 1'b0;
            end
        end
    end

    assign ORX_ERR = r_rx_err ;

	// =====================================================
	// RTS Control
	// =====================================================
    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_rts <= 1'b1 ;
        end else begin
            if (IRTS_EN == 1'b1) begin
                if (IBAUD_RATE == 1'b1) begin
			    	if (r_rx_fsm == P_st_idle) begin
                        r_rts <= 1'b0 ;
                    end else begin
                        r_rts <= 1'b1 ;
                    end
                end
            end else begin
                r_rts <= 1'bZ ;
            end
        end
    end

    assign ORTS = r_rts ;

endmodule