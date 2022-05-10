`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/20 18:27:01
// Design Name: 
// Module Name: waveform_output_top
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


module waveform_output_top(
    
    ///from vio//

    input i_trigger,
    input [15:0] i_valid_amp,
    input [15:0] i_zero_amp,
    input rst,
    input i_stop,
    input [31:0] i_data_duration, 
    input [31:0] i_zero_duration,

    input DAC_READY,
    input DAC_LMFC,

    output [63:0] o_data,
    input sys_clk,
    input dac_clk
   
    );
    

    wire [191:0] o_dac_data;
    

/*
    waveform_output_module1 u_waveform_output_module1
    ( 
        o_trigger,
        i_duration,
        amp,
        interval,
        o_data, 
        user_clk,
        rst
    );
*/

   
   	waveform_output_module1 inst_waveform_output_module1
		(
			.i_valid_amp     (i_valid_amp),
			.i_zero_amp      (i_zero_amp),
			.i_data_duration (i_data_duration),
			.i_zero_duration (i_zero_duration),
			.i_trigger       (i_trigger),
			.i_stop          (i_stop),
			.clk             (sys_clk),
			.rst             (rst),
			.out_data        (o_dac_data)
		);



     waveform_output u_waveform_output (
        
        o_dac_data,
        o_data,
        DAC_READY,
        DAC_LMFC,
        dac_clk,
        rst
        );
        
    

    
endmodule
