`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/31 13:28:20
// Design Name: 
// Module Name: tb_awg_output
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_awg_output(

    );
    
 reg clk;
 reg dac_ready;
 reg trigger_out;
 wire dac_lmfc = lmfc_r[23];
 reg  [23:0] lmfc_r;
 reg   i_stop;
 reg  [15:0] i_valid_amp;
 reg  [15:0] i_zero_amp;
 reg  [31:0] i_data_duration;
 reg  [31:0] i_zero_duration;


  wire [127:0] DAC_DATA0;
  wire [127:0] DAC_DATA1;
  wire [127:0] DAC_DATA2;
  wire [127:0] DAC_DATA3;
 
 reg i_sync;
  reg i_trigger;
  reg i_rst;
 
  //reg [15:0] amp;
  //reg [3:0] interval;
  
  	USER_TOP inst_USER_TOP
		(
			.i_trigger       (i_trigger),
			.i_valid_amp     (i_valid_amp),
			.i_zero_amp      (i_zero_amp),
			.i_rst           (i_rst),
			.i_stop          (i_stop),
			.i_data_duration (i_data_duration),
			.i_zero_duration (i_zero_duration),
			.DAC_CLK         (DAC_CLK),
			.DAC_READY       (DAC_READY),
			.DAC_LMFC        (DAC_LMFC),
			.DAC_DATA0       (DAC_DATA0),
			.DAC_DATA1       (DAC_DATA1),
			.DAC_DATA2       (DAC_DATA2),
			.DAC_DATA3       (DAC_DATA3)
		);

 
 
 
    always @ (posedge clk)
    begin 
        lmfc_r <= {lmfc_r[22:0],lmfc_r[23]};
    end   
        
    
    always #1.667 clk = ~clk;
    initial
    begin 
        clk = 1'b0;
        lmfc_r = 24'b1;
        dac_ready = 1'b0;
        
      
        i_trigger = 1'b0;
        i_rst = 1'b0;
        i_valid_amp = 16'd10; 
        i_zero_amp = 16'd2;  

        i_data_duration = 32'd8;
        i_zero_duration = 32'd3;
       
        
    # 700
        dac_ready = 1'b1;
        
    #70
        i_sync = 1'b1;
        #100
        i_sync = 1'b0;
        
        #200
        i_trigger = 1'b1;
        #3000
        i_trigger = 0;
        
         #501
         i_stop = 1'b1;
         #10
         i_stop = 1'b0;
         
        #200
        i_rst = 1;
        #40
        i_rst = 0;
        
    end    
    

  
endmodule
