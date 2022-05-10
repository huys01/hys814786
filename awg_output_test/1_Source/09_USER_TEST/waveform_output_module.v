`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/11 17:56:38
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




module waveform_output_module(
    
    input i_trigger,
    input [7:0] i_duration,
    input [15:0] amp,
    input [3:0] interval,
    
    output [191:0] o_data,
    
    input user_clk,
    input rst

    );

    parameter WAVE_LENGTH = 32'd100000000;
  //  parameter WAVE_LENGTH = 32'd1000;
    parameter IDLE = 1'd0;
    parameter WORK = 1'd1;


    wire state_ena;
    wire state_nxt;
    wire state_r;
    sirv_gnrl_dfflr #(1) state_reg(state_ena,state_nxt,state_r,user_clk,rst);  
    
    wire count_ena;
    wire [31:0] count_nxt;
    wire [31:0] count_r;
    sirv_gnrl_dfflr #(32) count_reg(count_ena,count_nxt,count_r,user_clk,rst); 

    
    wire duration_count_ena;
    wire [7:0] duration_count_nxt;
    wire [7:0] duration_count_r;
    sirv_gnrl_dfflr #(8) duration_count_reg(duration_count_ena,duration_count_nxt,duration_count_r,user_clk,rst); 

    wire isidle = (state_r == IDLE);
    wire iswork = (state_r == WORK);
    wire idle2work = (isidle & i_trigger); 
    wire work2idle = iswork & (duration_count_r == (i_duration - 1)) & (count_r == (WAVE_LENGTH - 1));

    
    assign state_ena = idle2work | work2idle;
    assign state_nxt =  ( idle2work & WORK) | ( work2idle & IDLE);


    assign count_ena = iswork;
    assign count_nxt = (count_r == (WAVE_LENGTH - 1))  ? 32'd0 : count_r + 1;

    assign duration_count_ena = iswork & (count_r == (WAVE_LENGTH - 1));
    assign duration_count_nxt = work2idle ? 8'd0 : duration_count_r + 1;

    wire [191:0] data;
    assign data = (interval == 0) ? {{11{16'hffff}},amp}  :
                  (interval == 1) ? {2{{5{16'hffff}},amp}}:
                  (interval == 2) ? {3{{3{16'hffff}},amp}}:
                  (interval == 3) ? {4{{2{16'hffff}},amp}}:
                  {12{16'hffff}};

    assign o_data = iswork ? data : {12{16'h7fff}};
    
    
endmodule
