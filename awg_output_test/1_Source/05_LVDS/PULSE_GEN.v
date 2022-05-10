// =================================================================================================
// Copyright(C) 2010- TOKYO ELECTRON DEVICE LIMITED. All rights reserved.
// =================================================================================================
//
// =================================================================================================
// File Name      : PULSE_GEN.v
// Module         : PULSE_GEN
// Function       : Synchronous. pulse from CLK_I to CLK_O
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by        Contents
// 0.1.0      xxxx/xx/xx   TEDSH)zhou.xm   Create new
//
//
// =================================================================================================
// End Revision
// =================================================================================================

// =============================================================================
// Timescale Define
// =============================================================================
`timescale 1 ps / 1 ps

// =============================================================================
// RTL Header
// =============================================================================
module PULSE_GEN (
    RST             ,   // (i) Reset Input ( Asynchronous )
    CLK_I           ,   // (i) clock at input side
    CLK_O           ,   // (i) clock at output side
    PULSE_I         ,   // (i) pulse input
    PULSE_O             // (o) pulse output
) ;


	//---------------------------------------------------------------------
	// Defination of Parameters
	//---------------------------------------------------------------------
    parameter               P_TYPE = 0              ;   //


	//---------------------------------------------------------------------
	// Defination of Port Signals
	//---------------------------------------------------------------------
    input               RST            ;   // Reset Input ( Asynchronous )
    input               CLK_I           ;   // clock at input side
    input               CLK_O           ;   // clock at output side
    input               PULSE_I         ;   // pulse input
    output              PULSE_O         ;   // pulse output


	//---------------------------------------------------------------------
	// Defination of Internal Signals
	//---------------------------------------------------------------------
    reg                         r_pulse_i   ;	//
    reg     [2:0]               r_pulse_o   /* synthesis syn_maxfan=9999 */; //r_pulse_o[0], r_pluse_o[1] should not be duplicated
    // synthesis attribute MAX_FANOUT of r_pulse_o is 9999;


// =============================================================================
// RTL Body
// =============================================================================

    generate
    if(P_TYPE == 0) begin :TYPE_0_PULSEGEN
	//---------------------------------------------------------------------
	// Input pulse keep									( CLK_I domain )
	//---------------------------------------------------------------------
        always @( posedge CLK_I ) begin
            if( RST ) begin
                r_pulse_i       <= 1'b0 ;
            end else begin
                if ( PULSE_I == 1'b1 ) begin
                    r_pulse_i   <= ~r_pulse_i ;
                end
            end
        end

	//---------------------------------------------------------------------
	// Output pulse sync. and generate					( CLK_O domain )
	//---------------------------------------------------------------------
        always @( posedge CLK_O ) begin
            if( RST ) begin
                r_pulse_o   <= 3'b000 ;
            end else begin
                r_pulse_o   <= { r_pulse_o[1:0] , r_pulse_i } ;
            end
        end

        assign PULSE_O = (r_pulse_o[2] != r_pulse_o[1] ) ;   // 0 -> 1

    end
    endgenerate

endmodule