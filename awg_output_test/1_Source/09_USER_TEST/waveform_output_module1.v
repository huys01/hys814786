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




module waveform_output_module1(
    
    input [15:0] i_valid_amp,
    input [15:0] i_zero_amp,
    
    input [31:0] i_data_duration,
    input [31:0] i_zero_duration,
    input i_trigger,
    input i_stop,
    
    input clk,
    input rst,
    
    output [191:0] out_data

    );

    localparam IDLE = 3'd0;
    localparam OUTPUT_DATA = 3'd1;
    localparam OUTPUT_ZERO = 3'd2;
    localparam STOP  = 3'd3;
    
    wire state_ena;
    wire [2:0] state_nxt;
    wire [2:0] state_r;
    sirv_gnrl_dfflr #(3) state_reg(state_ena,state_nxt,state_r,clk,rst);
    
    wire isidle = (state_r == IDLE);
    wire isoutput_data = (state_r == OUTPUT_DATA);
    wire isoutput_zero = (state_r == OUTPUT_ZERO);
    wire isstop = (state_r == STOP);
    
    wire trigger_nxt = i_trigger;                                                                                       
    wire trigger_ena = isidle | isstop;
    wire trigger_r;
    sirv_gnrl_dfflr #(1) trigger_reg (trigger_ena,trigger_nxt,trigger_r,clk,rst); 

    wire stop_nxt = i_stop;                                                
    wire stop_ena = isoutput_data | isoutput_zero;                                          
    wire stop_r;                                                              
    sirv_gnrl_dfflr #(1) stop_reg (stop_ena,stop_nxt,stop_r,clk,rst);
   
   
    wire mem_nxt = (output_zero2stop) ? 0 : 1;   
    wire mem_ena = (~stop_nxt & stop_r )| output_zero2stop;                        
    wire mem_r;                                                         
    sirv_gnrl_dfflr #(1) mem_reg (mem_ena,mem_nxt,mem_r,clk,rst);       
   
    wire data_counter_ena = isoutput_data | isoutput_zero;
    wire [31:0] data_counter_r;
    wire [31:0] data_counter_nxt = (isoutput_data & data_counter_r == i_data_duration - 32'd1 | isoutput_zero & data_counter_r == i_zero_duration - 32'd1) ? 32'b0 : data_counter_r + 32'b1;
    sirv_gnrl_dfflr #(32) data_counter_reg(data_counter_ena,data_counter_nxt,data_counter_r,clk,rst);
    
    
    wire idle2output_data = isidle & ~trigger_nxt & trigger_r;
    wire output_data2output_zero = isoutput_data & (data_counter_r == i_data_duration - 32'd1);
    wire output_zero2output_data = isoutput_zero & (data_counter_r == i_zero_duration - 32'd1) & (mem_r == 1'b0 );
    wire output_zero2stop = isoutput_zero & (data_counter_r == i_zero_duration - 32'd1) & (mem_r == 1'b1 );
    wire stop2output_data = isstop &  ~trigger_nxt & trigger_r;
    
    assign state_ena = idle2output_data | output_data2output_zero | output_zero2output_data | output_zero2stop | stop2output_data;
    assign state_nxt = ({3{idle2output_data | output_zero2output_data | stop2output_data}} & OUTPUT_DATA| {3{output_data2output_zero}} & OUTPUT_ZERO | {3{output_zero2stop}} & STOP);
    
    assign out_data = ( {12{i_zero_amp}} & {192{isidle}} | {12{i_valid_amp}} & {192{isoutput_data}} | {12{i_zero_amp}} & {192{isoutput_zero}} | {12{i_zero_amp}} & {192{isstop}});
    
    
	//ila_0 u_ila_0 (
	//.clk(clk), // input wire clk


	//.probe0(i_trigger), // input wire [0:0]  probe0  
	//.probe1(state_r), // input wire [2:0]  probe1 
	//.probe2(out_data), // input wire [191:0]  probe2 
	//.probe3(data_counter_r), // input wire [31:0]  probe3 
	//.probe4(i_stop), // input wire [0:0]  probe4 
	//.probe5(trigger_nxt), // input wire [0:0]  probe5 
	//.probe6(trigger_r), // input wire [0:0]  probe6 
	//.probe7(mem_nxt), // input wire [0:0]  probe7 
	//.probe8(mem_r) // input wire [0:0]  probe8
//);
  
endmodule

    

