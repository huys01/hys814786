// =============================================================================
// TOKYO ELECTRON DEVICE LIMITED.
// =============================================================================
// file name     : NOISE_DEL.v
// module        : NOISE_DEL
// =============================================================================
// function      : Dip-switch chattering filter(10 ms)
// -----------------------------------------------------------------------------
// updata history:
// -----------------------------------------------------------------------------
// rev.level  date        coded by         contents
// v0.0.1     2008/11/10  (TEDSH)Peng.sy   create new
// -----------------------------------------------------------------------------
// Update Details :
// -----------------------------------------------------------------------------
// Date       Contents Detail
// =============================================================================
// End revision
// =============================================================================
`timescale 1 ps	/ 1ps

module NOISE_DEL
    (
    // clock & reset
    SYS_CLK     , // (i) 66MHz
    SYS_xRST    , // (i) active low
    //
    DIN         , // (i)
    FILT_OUT      // (o)
    ) ;

    input       SYS_CLK             ; // (i) 66MHz
    input       SYS_xRST            ; // (i) active low
    //
    input       DIN                 ; // (i)
    output      FILT_OUT            ; // (o)

    // Internal Signal
    parameter   P_10MS = 20'hA121F  ; //10ms*66MHz = 660000
    reg         r_din_nsync         ;
    reg         r_din_sync          ;
    reg         r_din_cmp           ;
    reg [19:0]  r_filter_cnt        ;
    wire        s_10ms_flag         ;
    reg         r_filt_out          ;

    //DIN IFF
    always @(posedge SYS_CLK or negedge SYS_xRST) begin
        if (~SYS_xRST) begin
            r_din_nsync <= 1'b0 ;
            r_din_sync <= 1'b0 ;
        end else begin
            r_din_nsync <= DIN ;
            r_din_sync <= r_din_nsync ;
        end
    end

    //DIN compare
    always @(posedge SYS_CLK or negedge SYS_xRST) begin
        if (~SYS_xRST) begin
            r_din_cmp <= 1'b0 ;
        end else begin
            r_din_cmp <= r_din_sync ;
        end
    end

    //10 ms counter
    always @(posedge SYS_CLK or negedge SYS_xRST) begin
        if (~SYS_xRST) begin
            r_filter_cnt <= 20'b0 ;
        end else begin
            if ((r_din_cmp != r_din_sync) || (s_10ms_flag == 1'b1)) begin
                r_filter_cnt <= 20'b0 ;
            end else if (r_din_cmp == r_din_sync) begin
                r_filter_cnt <= r_filter_cnt + 1'b1 ;
            end
        end
    end

    assign s_10ms_flag = (r_filter_cnt == P_10MS) ? 1'b1 : 1'b0;

    always @(posedge SYS_CLK or negedge SYS_xRST) begin
        if (~SYS_xRST) begin
            r_filt_out <= 1'b0 ;
        end else begin
            if (s_10ms_flag == 1'b1) begin
                r_filt_out <= r_din_cmp ;
            end
        end
    end

    assign FILT_OUT = r_filt_out ;

endmodule
