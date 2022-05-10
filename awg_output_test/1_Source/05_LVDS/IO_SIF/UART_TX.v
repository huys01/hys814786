`timescale 1 ns/1 ps
// =============================================================================
// TOKYO ELECTRON DEVICE LIMITED.
// =============================================================================
// file name    : UART_TX.v
// entity       : UART_TX
// =============================================================================
// architecture : RTL
// level        : 3
// function     : Uart Transmit Control Module(Parallel -> Serial)
// type         : RTL
// -----------------------------------------------------------------------------
// updata history:
// -----------------------------------------------------------------------------
// rev.level  date           coded by        contents
// 0.0.1	  10/26/2007  	 TEDWX)Li.j		 create new
// 1.0.1	  10/29/2007  	 TEDWX)Li.j		 add tx parity bit
//                                           add wait state after stop state
//                                           add CTS enable
// -----------------------------------------------------------------------------
// Update Details :
// -----------------------------------------------------------------------------
// Date         Contents Detail
// =============================================================================
// End revision
// =============================================================================

module UART_TX  (

    // clock & reset
    FPGA_CLK		                            ,
     FPGA_RST		                            ,

    // uart
	OTXD			                            ,
	ICTS		                                ,
	ICTS_EN                                     ,
	IPARITY_EN		                            ,
    IODD_PARITY		                            ,
    ISTOP2_EN		                            ,

    // Baud Rate Generate
	IBAUD_RATE		                            ,

    // User Interface
	OTX_READY			                        ,
	ITX_DVLD			                        ,
    ITX_DT

    ) ;

    // clock & reset
    input               FPGA_CLK		        ; //(i) System clk
    input               FPGA_RST		        ; //(i) system reset(active high)

    // uart
	output              OTXD			        ; //(o) Uart Tx Port
	input               ICTS		            ; //(i) Uart Clear to send  Port
	input               ICTS_EN                 ; //(i) Uart CTS enable (active high) -- v 1.0.1

	input               IPARITY_EN		        ; //(i)
    input               IODD_PARITY		        ; //(i)
    input               ISTOP2_EN		        ; //(i)

    // Baud Rate Generate
	input               IBAUD_RATE		        ; //(i) Uart Baud Rate

    // User Interface
	output              OTX_READY		        ; //(o) TX module Ready
	input               ITX_DVLD		        ; //(i) TX Data Valid
    input   [ 7 : 0]    ITX_DT			        ; //(i) TX Data


    parameter           P_st_idle   = 3'b000    ;
    parameter           P_st_start  = 3'b001    ;
    parameter           P_st_shift  = 3'b010    ;
    parameter           P_st_pari   = 3'b011    ;
    parameter           P_st_stop   = 3'b100    ;
    parameter           P_st_stop2  = 3'b101    ;
    parameter           P_st_wait   = 3'b110    ;

    reg     [ 2 : 0]    r_tx_fsm                ;
    reg                 r_tx_rdy	            ;
    reg     [ 7 : 0]    r_tx_dt_lat	            ;
    reg     [ 3 : 0]    r_cnt16	    	        ;
    reg     [ 2 : 0]    r_cnt8			        ;
    wire                s_state_chg	            ;
    reg     [ 7 : 0]    r_tx_data	            ;
    reg                 r_txd		            ;
    reg                 r_pari                  ;

	assign OTX_READY = (r_tx_fsm == P_st_idle) ? 1'b1 : 1'b0;

	//=====================================================
	//Tx Control
	//=====================================================
    // Tx data Latch
//    always @ ( posedge FPGA_CLK ) begin
//        if ( FPGA_RST ) begin
//            r_tx_dt_lat <= 8'h0 ;
//        end else begin
//            if (ITX_DVLD == 1'b1) begin
//                r_tx_dt_lat <= ITX_DT ;
//            end
//        end
//    end

	// State Machine
    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_tx_fsm  <= P_st_idle;
        end else begin
            case (r_tx_fsm)

                P_st_idle	    :
                	if (ITX_DVLD == 1'b1) begin
                  		r_tx_fsm <= P_st_start ;
                  	end else begin
                  		r_tx_fsm  <= P_st_idle ;
                    end

                P_st_start	    :
                	if (s_state_chg == 1'b1) begin
                    	r_tx_fsm <= P_st_shift ;
                    end else begin
                    	r_tx_fsm <= P_st_start ;
                	end

                P_st_shift	    :
                	if (s_state_chg == 1'b1) begin
                		if (r_cnt8 == 3'b111) begin
                		    if (IPARITY_EN) begin
                        		r_tx_fsm <= P_st_pari ;
                        	end else begin
                        	    r_tx_fsm <= P_st_stop ;
                        	end
                    	end else begin
                    		r_tx_fsm <= P_st_shift ;
                   		end
                   	end

                P_st_pari	    :
                	if (s_state_chg == 1'b1) begin
                   		r_tx_fsm <= P_st_stop ;
                   	end else begin
                   		r_tx_fsm <= P_st_pari ;
                  	end

                P_st_stop	    :
                	if (s_state_chg == 1'b1) begin
                	    if ( ISTOP2_EN ) begin
							r_tx_fsm <= P_st_stop2 ;
						end else begin
						    r_tx_fsm <= P_st_wait ;
						end
                   	end else begin
                   		r_tx_fsm <= P_st_stop ;
                  	end

                P_st_stop2	   :
                	if (s_state_chg == 1'b1) begin
                	    r_tx_fsm <= P_st_wait ;
                   	end else begin
                   		r_tx_fsm <= P_st_stop2 ;
                  	end

                P_st_wait	    :
                	if (s_state_chg == 1'b1) begin
                   		r_tx_fsm <= P_st_idle ;
                   	end else begin
                   		r_tx_fsm <= P_st_wait ;
                  	end

                default		    :
                	r_tx_fsm    <= P_st_idle;

            endcase
        end
    end

    // baud rate counter
    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_cnt16 <= 4'h0 ;
        end else begin
        	if (r_tx_fsm == P_st_idle) begin
        	    r_cnt16 <= 4'h0 ;
        	end else if (IBAUD_RATE == 1'b1) begin
        	    r_cnt16 <= r_cnt16 + 1'b1 ;
        	end
        end
    end

    // State change condition
    assign s_state_chg = (r_cnt16 == 4'b1111 && IBAUD_RATE == 1'b1) ? 1'b1 : 1'b0 ;

    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_cnt8 <= 3'b000 ;
        end else begin
            if (r_tx_fsm == P_st_shift) begin
                if (s_state_chg == 1'b1) begin
                    r_cnt8 <= r_cnt8 + 1'b1 ;
                end
			end else begin
				r_cnt8 <= 3'b000 ;
            end
        end
    end

    // Tx data shifter
    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_tx_data <= 8'h0 ;
        end else begin
            if (r_tx_fsm == P_st_start) begin
//                r_tx_data <= r_tx_dt_lat ;
                r_tx_data <= ITX_DT ;
            end else if (r_tx_fsm == P_st_shift && s_state_chg == 1'b1) begin
                r_tx_data <= {1'b0 , r_tx_data[7 : 1]} ;
            end
        end
    end

    // Tx parity bit generate
    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_pari <= 1'b0;
        end else begin
            if (ITX_DVLD == 1'b1) begin
                if (IODD_PARITY) begin
                    r_pari <= ~(ITX_DT[0] ^ ITX_DT[1] ^ ITX_DT[2] ^ ITX_DT[3] ^
                                ITX_DT[4] ^ ITX_DT[5] ^ ITX_DT[6] ^ ITX_DT[7]);
                end else begin
                    r_pari <= (ITX_DT[0] ^ ITX_DT[1] ^ ITX_DT[2] ^ ITX_DT[3] ^
                               ITX_DT[4] ^ ITX_DT[5] ^ ITX_DT[6] ^ ITX_DT[7]);
                end
            end
        end
    end

    // Generate TXD
    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_txd <= 1'b1;
        end else begin
        	case (r_tx_fsm)
        		P_st_idle 	: r_txd <= 1'b1 ;
        		P_st_start	: r_txd <= 1'b0 ;
        		P_st_shift	: r_txd <= r_tx_data[0] ;
        		P_st_pari   : r_txd <= r_pari;
        		P_st_stop	: r_txd <= 1'b1 ;
        		P_st_stop2	: r_txd <= 1'b1 ;
        		P_st_wait	: r_txd <= 1'b1 ;
        		default     : r_txd <= 1'b1 ;
        	endcase
        end
	end

    assign OTXD =  r_txd ;

endmodule