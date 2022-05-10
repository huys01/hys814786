
`timescale 1ns/ 1ps

module filter #(
	parameter p_filter_width = 16		//Width=p_filter_width*tCLK
	)
	(
	clk				,
	rst				,

	din				,
	dout			
	);

	input			clk	 ;
	input			rst	 ;

	input			din	 ;
	output			dout ;
	
	reg		[p_filter_width-1:0]	r_filter;
	reg								r_dout;

	always @(posedge clk) begin
		if(rst) begin
			r_filter <= 'b1; 
		end else begin 
			r_filter <= {r_filter[p_filter_width-2:0],din};
		end 
	end

	always @(posedge clk) begin
		if(rst) begin
			r_dout <= 1'b1; 
		end else begin 
			if(~|r_filter[p_filter_width-1:0]) begin 
				r_dout <= 1'b0; 
			end else if(&r_filter[p_filter_width-1:0]) begin 
				r_dout <= 1'b1;
			end  
		end 
	end

	assign dout = r_dout;
	
endmodule