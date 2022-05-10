// =============================================================================
// Copyright(C)-INNORISE <HEFEI> TECH LIMITED.
// =============================================================================
// module name  : sync_fifo_mlab.v
// =============================================================================
// architecture : RTL
// function     : Sync FIFO with Write Clock & Read Clock
// -----------------------------------------------------------------------------
// updata history:
// -----------------------------------------------------------------------------
// rev.level  date           coded by          contents
// 0.0.1      04/22/2015     INNORISE)shen.h   create new
// -----------------------------------------------------------------------------
// Update Details :
// -----------------------------------------------------------------------------
// Date       Contents Detail
// =============================================================================
// End revision
// =============================================================================

//    `define SIM
    module sync_fifo_mlab # (
        parameter P_ADDRESS             = 4     	,
        parameter P_DATA_WIDE           = 8 		,
        parameter P_ALMOST_FULL_VLU		= 10	    ,
        parameter P_ALMOST_EMPTY_VLU	= 10	    
    ) (
        input                           rst   	,
        input                           wr_clk		,
        input                           wr_en   	,
        input     [P_DATA_WIDE-1:0]     wr_din  	,
        output                          almost_full	,
        output                          full    	,
        input                           rd_clk		,
        input                           rd_en   	,
        output    [P_DATA_WIDE-1:0]     rd_dout 	,
        output    [P_ADDRESS    :0]     rd_cnt  	,
        output                          almost_empty,
        output                          empty   	
    );
    
    reg     [P_ADDRESS  :0]      r_wbin          ;
    wire    [P_ADDRESS  :0]      w_wbnext        ;
    wire    [P_ADDRESS  :0]      w_wgnext        ;
    reg     [P_ADDRESS  :0]      r_wrptr2        ;
    reg     [P_ADDRESS  :0]      r_wrptr1        ;
    wire                         w_full_val      ;
    reg                          r_full          ;
    wire    [P_ADDRESS-1:0]      w_waddr         ;
    wire                         w_wren          ;
    reg     [P_ADDRESS  :0]      r_rbin          ;
    wire    [P_ADDRESS  :0]      w_rbnext        ;
    wire    [P_ADDRESS  :0]      w_rgnext        ;
    reg     [P_ADDRESS  :0]      r_rwptr2        ;
    reg     [P_ADDRESS  :0]      r_rwptr1        ;
    wire                         w_empty_val     ;
    wire    [P_ADDRESS  :0]      w_rwbnext       ;
    wire    [P_ADDRESS  :0]      w_rd_cnt        ;
    reg     [P_ADDRESS  :0]      r_rd_cnt        ;
    reg                          r_empty         ;
    wire    [P_ADDRESS-1:0]      w_raddr         ;
(* ramstyle = "MLAB,no_rw_check" *)    reg     [P_DATA_WIDE-1:0]    mem[0:(1<<P_ADDRESS)-1];
    
    ////////////////////////////////////////////////////////
    // Write Domain Handle
    always @ ( posedge wr_clk or posedge rst ) begin
        if ( rst ) begin
            r_wbin <= 'b0;
        end else begin
            r_wbin <= w_wbnext;
        end
    end
    
    assign w_wbnext = ( !r_full && wr_en ) ? ( r_wbin + 1'b1 ) : r_wbin;
    // Bin2Gray Exchange
    assign w_wgnext = ( w_wbnext>>1 ) ^ w_wbnext;
    

    //Almost full generate
    wire	[P_ADDRESS:0] w_almost_full_val;

	assign w_almost_full_val = ( r_rbin[P_ADDRESS] == r_wbin[P_ADDRESS] ) ? ( {1'b1,r_rbin[P_ADDRESS-1:0]}-{1'b0,r_wbin[P_ADDRESS-1:0]}) :
	                           ( {1'b0,r_rbin[P_ADDRESS-1:0]}-{1'b0,r_wbin[P_ADDRESS-1:0]});
	
	reg		r_almost_full;
	always @ ( posedge wr_clk or posedge rst ) begin
        if ( rst ) begin
            r_almost_full <= 1'b0;
        end else begin
            r_almost_full <= ( w_almost_full_val < P_ALMOST_FULL_VLU ) ? 1'b1:1'b0;
        end
    end
	
	assign almost_full = r_almost_full;
	                      
    // Full value generate
    assign w_full_val = ( w_wgnext[P_ADDRESS]     != w_rgnext[P_ADDRESS] ) &&
                        ( w_wgnext[P_ADDRESS-1]   != w_rgnext[P_ADDRESS-1] ) &&
                        ( w_wgnext[P_ADDRESS-2:0] == w_rgnext[P_ADDRESS-2:0] );
                      
    always @ ( posedge wr_clk or posedge rst ) begin
        if ( rst ) begin
            r_full <= 1'b0;
        end else begin
            r_full <= w_full_val;
        end
    end
    
    assign full = r_full;
    
    assign w_waddr  = r_wbin[P_ADDRESS-1:0];
    assign w_wren  = !r_full & wr_en;
    
    `ifdef SIM
    integer i;
    initial begin
        for (i=0;i < (1<<P_ADDRESS);i=i+1)
            mem[i]=0;
    end
    `endif
    always @ ( posedge wr_clk ) begin
        if ( w_wren ) begin
            mem[w_waddr] <= wr_din;
        end
    end
    
    ////////////////////////////////////////////////////////
    //Read Domain Handle
    always @ ( posedge rd_clk or posedge rst ) begin
        if ( rst ) begin
            r_rbin <= 'b0;
        end else begin
            r_rbin <= w_rbnext;
        end
    end
    
    assign w_rbnext = ( !r_empty && rd_en ) ? ( r_rbin + 1'b1 ) : r_rbin;
    //Bin2Gray Exchange
    assign w_rgnext = (w_rbnext>>1 ) ^ w_rbnext;
    
    // Empty value generate
    assign w_empty_val = ( w_rgnext == w_wgnext ) ? 1'b1:1'b0;
    
    always @ ( posedge rd_clk or posedge rst ) begin
        if ( rst ) begin
            r_empty <= 1'b1;
        end else begin
            r_empty <= w_empty_val;
        end
    end
    
    assign empty = r_empty;
 
    // Valid Data Counter on Read Clock Domain
    assign w_rd_cnt = (r_wbin[P_ADDRESS] >= r_rbin[P_ADDRESS]) ? (r_wbin - r_rbin) :
                      ({1'b1,r_wbin[P_ADDRESS-1:0]}-{1'b0,r_rbin[P_ADDRESS-1:0]});
    
    reg     r_almost_empty;
    always @ ( posedge rd_clk or posedge rst ) begin
        if ( rst ) begin
            r_almost_empty <= 'b0;
        end else begin
            if ( w_rd_cnt < P_ALMOST_EMPTY_VLU ) begin
                r_almost_empty <= 1'b1;
            end else begin
                r_almost_empty <= 1'b0;
            end
        end
    end
    
    assign almost_empty = r_almost_empty;
                      
    always @ ( posedge rd_clk or posedge rst ) begin
        if ( rst ) begin
            r_rd_cnt <= 'b0;
        end else begin
            r_rd_cnt <= w_rd_cnt;
        end
    end
    
    assign rd_cnt = r_rd_cnt;
    
    assign w_raddr = r_rbin[P_ADDRESS-1:0];
    
    assign rd_dout = mem[w_raddr];
    
endmodule
    