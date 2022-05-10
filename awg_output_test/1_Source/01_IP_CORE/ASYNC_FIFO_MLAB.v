//    `define SIM
    module async_fifo_mlab # (
        parameter P_ADDRESS             = 4     	,
        parameter P_DATA_WIDE           = 8 		,
        parameter P_ALMOST_FULL_VLU		= 2		    ,
        parameter P_ALMOST_EMPTY_VLU	= 10	    
    ) (
        input                           rst  	 	,
        input                           wr_clk 		,
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
    reg     [P_ADDRESS  :0]      r_wptr          ;
    wire    [P_ADDRESS  :0]      w_wbnext        ;
    wire    [P_ADDRESS  :0]      w_wgnext        ;
    reg     [P_ADDRESS  :0]      r_wrptr2        ;
    reg     [P_ADDRESS  :0]      r_wrptr1        ;
    wire                         w_full_val      ;
    reg                          r_full          ;
    wire    [P_ADDRESS-1:0]      w_waddr         ;
    wire                         w_wren          ;
    reg     [P_ADDRESS  :0]      r_rbin          ;
    reg     [P_ADDRESS  :0]      r_rptr          ;
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
 (* ramstyle = "MLAB,no_rw_check" *)   reg      [P_DATA_WIDE-1:0]    mem[0:(1<<P_ADDRESS)-1];
    
    ////////////////////////////////////////////////////////
    // Write Domain Handle
    always @ ( posedge wr_clk ) begin
        if ( rst ) begin
            r_wbin <= 'b0;
            r_wptr <= 'b0;
        end else begin
            r_wbin <= w_wbnext;
            r_wptr <= w_wgnext;
        end
    end
    
    assign w_wbnext = ( !r_full && wr_en ) ? ( r_wbin + 1'b1 ) : r_wbin;
    // Bin2Gray Exchange
    assign w_wgnext = ( w_wbnext>>1 ) ^ w_wbnext;
    
    // Read Pointer to Write Domain transfer
    always @ ( posedge wr_clk ) begin
        if ( rst ) begin
            {r_wrptr2,r_wrptr1} <= 'b0;
        end else begin
            {r_wrptr2,r_wrptr1} <= {r_wrptr1,r_rptr};
        end
    end
    
    wire	[P_ADDRESS:0]	w_wrbnext;
    // Gray2Bin Exchange
    assign w_wrbnext[P_ADDRESS]  = r_wrptr2[P_ADDRESS];
    assign w_wrbnext[P_ADDRESS-1:0]= w_wrbnext[P_ADDRESS:1] ^ r_wrptr2[P_ADDRESS-1:0];
    
    //Almost full generate
    wire	[P_ADDRESS:0] w_almost_full_val;

	assign w_almost_full_val = ( w_wrbnext[P_ADDRESS] == w_wbnext[P_ADDRESS] ) ? ( {1'b1,w_wrbnext[P_ADDRESS-1:0]}-{1'b0,w_wbnext[P_ADDRESS-1:0]}) :
	                           ( {1'b0,w_wrbnext[P_ADDRESS-1:0]}-{1'b0,w_wbnext[P_ADDRESS-1:0]});
	
	reg 	[P_ADDRESS:0] r_almost_full_val;
	always @ ( posedge wr_clk ) begin
        if ( rst ) begin
            r_almost_full_val <= 'b0;
        end else begin
            r_almost_full_val <= w_almost_full_val;
        end
    end
	
	reg		r_almost_full;
	always @ ( posedge wr_clk ) begin
        if ( rst ) begin
            r_almost_full <= 1'b0;
        end else begin
            r_almost_full <= ( r_almost_full_val < P_ALMOST_FULL_VLU ) ? 1'b1:1'b0;
        end
    end
	
	assign almost_full = r_almost_full;
	                      
    // Full value generate
    assign w_full_val = ( w_wgnext[P_ADDRESS]     != r_wrptr2[P_ADDRESS] ) &&
                        ( w_wgnext[P_ADDRESS-1]   != r_wrptr2[P_ADDRESS-1] ) &&
                        ( w_wgnext[P_ADDRESS-2:0] == r_wrptr2[P_ADDRESS-2:0] );
                      
    always @ ( posedge wr_clk ) begin
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
    always @ ( posedge wr_clk) begin
        if ( w_wren ) begin
            mem[w_waddr] <= wr_din;
        end
    end
    
    ////////////////////////////////////////////////////////
    //Read Domain Handle
    always @ ( posedge rd_clk ) begin
        if ( rst ) begin
            r_rbin <= 'b0;
            r_rptr <= 'b0;
        end else begin
            r_rbin <= w_rbnext;
            r_rptr <= w_rgnext;
        end
    end
    
    assign w_rbnext = ( !r_empty && rd_en ) ? ( r_rbin + 1'b1 ) : r_rbin;
    //Bin2Gray Exchange
    assign w_rgnext = (w_rbnext>>1 ) ^ w_rbnext;
    
    // Write pointer to Read Clock Domain Transfer
    always @ ( posedge rd_clk ) begin
        if ( rst ) begin
            {r_rwptr2,r_rwptr1} <= 'b0;
        end else begin
            {r_rwptr2,r_rwptr1} <= {r_rwptr1,r_wptr};
        end
    end
    
    // Empty value generate
    assign w_empty_val = ( w_rgnext == r_rwptr2 ) ? 1'b1:1'b0;
    
    always @ ( posedge rd_clk ) begin
        if ( rst ) begin
            r_empty <= 1'b1;
        end else begin
            r_empty <= w_empty_val;
        end
    end
    
    assign empty = r_empty;
    
    // Gray2Bin Exchange
    assign w_rwbnext[P_ADDRESS]    = r_rwptr2[P_ADDRESS];
    assign w_rwbnext[P_ADDRESS-1:0]= w_rwbnext[P_ADDRESS:1] ^ r_rwptr2[P_ADDRESS-1:0];
    
    // Valid Data Counter on Read Clock Domain
    assign w_rd_cnt = (w_rwbnext[P_ADDRESS] >= w_rbnext[P_ADDRESS]) ? (w_rwbnext - w_rbnext) :
                      ({1'b1,w_rwbnext[P_ADDRESS-1:0]}-{1'b0,w_rbnext[P_ADDRESS-1:0]});
    
    reg     r_almost_empty;
    always @ ( posedge rd_clk ) begin
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
                      
    always @ ( posedge rd_clk ) begin
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
    