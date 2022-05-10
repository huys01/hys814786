`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/30 12:15:25
// Design Name: 
// Module Name: U08_USER_TOP
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


module USER_TOP(


    input i_trigger,
    input [15:0] i_valid_amp,
    input [15:0] i_zero_amp,
    input i_rst,
    input i_stop,
    input [31:0] i_data_duration, 
    input [31:0] i_zero_duration,
   
    input DAC_CLK,
    input DAC_READY,
    input DAC_LMFC,
    output [127:0] DAC_DATA0,
    output [127:0] DAC_DATA1,
    output [127:0] DAC_DATA2,
    output [127:0] DAC_DATA3
   
    );

    ////////////////////clk and rst generate//////////

    wire user_clk;
    wire user_rst;
    wire locked;
    wire unlocked = ~locked;

      clk_wiz_0 u_clk_wiz_0
   (
    // Clock out ports
    .clk_out1(user_clk),     // output clk_out1
    // Status and control signals
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(DAC_CLK));  

    reg [7:0] user_rst_r;


	always @ ( posedge user_clk or posedge unlocked ) begin
		if ( unlocked ) begin
			user_rst_r <= 8'hFF;
		end else begin
			user_rst_r <= { user_rst_r[6:0],1'b0};
		end
	end
	assign user_rst = user_rst_r[7] | i_rst;

    


//////////////////////////////////////
///    waveform output module    ///   
//////////////////////////////////////

wire [63:0] user_o_data;

	waveform_output_top inst_waveform_output_top
		(
			.i_trigger       (i_trigger),
			.i_valid_amp     (i_valid_amp),
			.i_zero_amp      (i_zero_amp),
			.rst             (user_rst),
			.i_stop          (i_stop),
			.i_data_duration (i_data_duration),
			.i_zero_duration (i_zero_duration),
			
			
			.DAC_READY       (DAC_READY),
			.DAC_LMFC        (DAC_LMFC),
			.o_data          (user_o_data),
			.sys_clk         (user_clk),
			.dac_clk         (DAC_CLK)
		);

    
/////////////////////////////////////
///          assign output        ///
////////////////////////////////////
assign DAC_DATA0 = {user_o_data,user_o_data};
assign DAC_DATA1 = {user_o_data,user_o_data};
assign DAC_DATA2 = {user_o_data,user_o_data};
assign DAC_DATA3 = {user_o_data,user_o_data};

endmodule
