`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/20 17:33:12
// Design Name: 
// Module Name: waveform_output_module
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


  module waveform_output(
    
    input [191:0] dac_i_data,
    output [63:0] dac_o_data,
    input DAC_READY,
    input DAC_LMFC,
    input dac_clk,
    input rst
    
    );
    
    parameter IDLE = 1'd0;
    parameter WORK = 1'd1;
    
    
    wire state_r;
    wire isidle = (state_r == IDLE);
    wire idle2work = isidle & DAC_READY & DAC_LMFC;
      

    wire iswork = (state_r == WORK);

    wire state_ena = idle2work;
    wire state_nxt = idle2work & WORK;
    
    sirv_gnrl_dfflr #(1) state_reg(state_ena,state_nxt,state_r,dac_clk,rst);  

  
    
    parameter OUTPUT_CYCLE = 2'd2;
     wire [1:0] output_count_r;

    wire output_count_ena = iswork | idle2work;
    wire [1:0] output_count_nxt = (output_count_r == (OUTPUT_CYCLE)) ? 2'd0 : output_count_r + 2'd1;
  
    sirv_gnrl_dfflr #(2) output_count_reg(output_count_ena,output_count_nxt,output_count_r,dac_clk,rst); 
    
    
    
    

    wire [191:0] i_data_nxt = dac_i_data;
    wire i_data_ena = (iswork | idle2work) & (output_count_r == 2'd0);
    wire [191:0] i_data_r;
    
    sirv_gnrl_dfflr #(192) i_data_reg(i_data_ena,i_data_nxt,i_data_r,dac_clk,rst);
    
    assign dac_o_data =     (output_count_r == 2'd0) ? dac_i_data[63:0] 
                        :   (output_count_r == 2'd1) ? i_data_r [127:64]
                        :    i_data_r [191:128];

 
endmodule
