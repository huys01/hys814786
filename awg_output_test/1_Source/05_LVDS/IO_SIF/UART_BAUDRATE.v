`timescale 1 ns/1 ps

// =============================================================================
// TOKYO ELECTRON DEVICE LIMITED.
// =============================================================================
// file name    : UART_BAUDRATE.v
// entity       : UART_BAUDRATE
// =============================================================================
// architecture : RTL
// level        : 3
// function     : Uart Baud Rate Control
// type         : RTL
// -----------------------------------------------------------------------------
// updata history:
// -----------------------------------------------------------------------------
// rev.level  date           coded by        contents
// 0.0.1	  10/26/2007  	 TEDWX)Li.j		 create new
// 0.0.2	  11/06/2007  	 TEDWX)Li.j		 clk 62MHz->103.68MHz
// -----------------------------------------------------------------------------
// Update Details :
// -----------------------------------------------------------------------------
// Date         Contents Detail
// =============================================================================
// End revision
// =============================================================================

module UART_BAUDRATE
    (
        FPGA_CLK		    , //(i)
    	FPGA_RST		    , //(i)
    	BAUD_CTRL 		    , //(i)[1 : 0]
		OBAUD_RATE		      //(o)
    ) ;

    //===========================================
    // Input
    //===========================================
    input               FPGA_CLK		        ; //(i) System clk
    input               FPGA_RST		        ; //(i) system reset(active high)
    input   [ 1: 0]     BAUD_CTRL 		        ; //(i) baud rate select
    											  //    "00": 9600bps
    											  //    "01": 19200bps
    											  //    "10": 38400bps
    											  //    "11": 115200bps
    //===========================================
    // Output
    //===========================================
	output              OBAUD_RATE		        ; //(o) Baud Rate Pulse

    parameter       P_baud_cnt0 = 10'b0111100010    ;//Baut-Rate-Cnt(482) = (74.25MHz /(9600 Hz 	* 16)) - 1
    parameter       P_baud_cnt1 = 10'b0011110001    ;//Baut-Rate-Cnt(241) = (74.25MHz /(19200 Hz 	* 16)) - 1
    parameter       P_baud_cnt2 = 10'b0001111001    ;//Baut-Rate-Cnt(121) = (74.25MHz /(38400 Hz 	* 16)) - 1
    parameter       P_baud_cnt3 = 10'b0000000001    ;//Baut-Rate-Cnt(1)  = (125MHz /(3MHz	* 16)) - 1

    reg     [ 9:0]  r_baud_cnt	                    ;
    reg             r_baud_rate	                    ;

//	--=======================================
//    -- Baud Rate Control
//    --=======================================
	// baud rate counter
    always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_baud_cnt <= P_baud_cnt3 ;
        end else begin
            if (r_baud_cnt == 10'b0)  begin
                case (BAUD_CTRL)
                    2'b00	: r_baud_cnt <= P_baud_cnt0;
                    2'b01	: r_baud_cnt <= P_baud_cnt1;
                    2'b10	: r_baud_cnt <= P_baud_cnt2;
                    2'b11	: r_baud_cnt <= P_baud_cnt3;
                    default : r_baud_cnt <= P_baud_cnt0;
                endcase
            end else begin
                r_baud_cnt  <= r_baud_cnt - 1'b1;
            end
        end
    end

    // Baud Rate Control Pulse
	always @ ( posedge FPGA_CLK ) begin
        if ( FPGA_RST ) begin
            r_baud_rate <= 1'b0 ;
        end else begin
            if (r_baud_cnt == 10'b0)  begin
            	r_baud_rate <= 1'b1 ;
            end else begin
            	r_baud_rate <= 1'b0 ;
            end
		end
	end

    assign OBAUD_RATE   = r_baud_rate ;

endmodule
