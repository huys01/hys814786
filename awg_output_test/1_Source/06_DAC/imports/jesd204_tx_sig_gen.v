//----------------------------------------------------------------------------
// Title : Signal Generator for the Example Design
// Project : JESD204
//----------------------------------------------------------------------------
// File : jesd204_tx_sig_gen.v
//----------------------------------------------------------------------------
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 
//
//----------------------------------------------------------------------------

`timescale 1ns / 1ps

module jesd204_tx_sig_gen (
  input         clk,
  input         rst_n,

  //Channel 0
  output [13:0] signal0_sampl0,
  output [13:0] signal0_sampl1,
  output  [1:0] signal0_cntrl0,
  output  [1:0] signal0_cntrl1,
  //Channel 1
  output [13:0] signal1_sampl0,
  output [13:0] signal1_sampl1,
  output  [1:0] signal1_cntrl0,
  output  [1:0] signal1_cntrl1,
  //Channel 2
  output [13:0] signal2_sampl0,
  output [13:0] signal2_sampl1,
  output  [1:0] signal2_cntrl0,
  output  [1:0] signal2_cntrl1,
  //Channel 3
  output [13:0] signal3_sampl0,
  output [13:0] signal3_sampl1,
  output  [1:0] signal3_cntrl0,
  output  [1:0] signal3_cntrl1,
  //Channel 4
  output [13:0] signal4_sampl0,
  output [13:0] signal4_sampl1,
  output  [1:0] signal4_cntrl0,
  output  [1:0] signal4_cntrl1,
  //Channel 5
  output [13:0] signal5_sampl0,
  output [13:0] signal5_sampl1,
  output  [1:0] signal5_cntrl0,
  output  [1:0] signal5_cntrl1,
  //Channel 6
  output [13:0] signal6_sampl0,
  output [13:0] signal6_sampl1,
  output  [1:0] signal6_cntrl0,
  output  [1:0] signal6_cntrl1,
  //Channel 7
  output [13:0] signal7_sampl0,
  output [13:0] signal7_sampl1,
  output  [1:0] signal7_cntrl0,
  output  [1:0] signal7_cntrl1,
  input         ready_in
);

wire [13:0] sine_lut64_14bit [63:0];
`include "sine_lut64_14bit.vh"

//Channel 0
reg [13:0] signal0_sampl0_reg;
reg [13:0] signal0_sampl1_reg;
reg  [1:0] signal0_cntrl0_reg;
reg  [1:0] signal0_cntrl1_reg;
reg  [5:0] index0;
//Channel 1
reg [13:0] signal1_sampl0_reg;
reg [13:0] signal1_sampl1_reg;
reg  [1:0] signal1_cntrl0_reg;
reg  [1:0] signal1_cntrl1_reg;
reg  [5:0] index1;
//Channel 2
reg [13:0] signal2_sampl0_reg;
reg [13:0] signal2_sampl1_reg;
reg  [1:0] signal2_cntrl0_reg;
reg  [1:0] signal2_cntrl1_reg;
reg  [5:0] index2;
//Channel 3
reg [13:0] signal3_sampl0_reg;
reg [13:0] signal3_sampl1_reg;
reg  [1:0] signal3_cntrl0_reg;
reg  [1:0] signal3_cntrl1_reg;
reg  [5:0] index3;
//Channel 4
reg [13:0] signal4_sampl0_reg;
reg [13:0] signal4_sampl1_reg;
reg  [1:0] signal4_cntrl0_reg;
reg  [1:0] signal4_cntrl1_reg;
reg  [5:0] index4;
//Channel 5
reg [13:0] signal5_sampl0_reg;
reg [13:0] signal5_sampl1_reg;
reg  [1:0] signal5_cntrl0_reg;
reg  [1:0] signal5_cntrl1_reg;
reg  [5:0] index5;
//Channel 6
reg [13:0] signal6_sampl0_reg;
reg [13:0] signal6_sampl1_reg;
reg  [1:0] signal6_cntrl0_reg;
reg  [1:0] signal6_cntrl1_reg;
reg  [5:0] index6;
//Channel 7
reg [13:0] signal7_sampl0_reg;
reg [13:0] signal7_sampl1_reg;
reg  [1:0] signal7_cntrl0_reg;
reg  [1:0] signal7_cntrl1_reg;
reg  [5:0] index7;

//Create samples and pseudo control bits
//The samples a created from a sine wave LUT
//each lane has different sample data created by simply offsetting into the LUT
//the control bits are just a simple counter clipped to two bits.
always @(posedge clk, negedge rst_n)
begin
  if(!rst_n)
  begin
    //Channel 0
    signal0_sampl0_reg <= sine_lut64_14bit[0];
    signal0_sampl1_reg <= sine_lut64_14bit[1];
    signal0_cntrl0_reg <= 2'd0;  //clipped to two bits
    signal0_cntrl1_reg <= 2'd1;  //clipped to two bits
    index0 <= 0;
    //Channel 1
    signal1_sampl0_reg <= sine_lut64_14bit[2];
    signal1_sampl1_reg <= sine_lut64_14bit[3];
    signal1_cntrl0_reg <= 2'd2;  //clipped to two bits
    signal1_cntrl1_reg <= 2'd3;  //clipped to two bits
    index1 <= 2;
    //Channel 2
    signal2_sampl0_reg <= sine_lut64_14bit[4];
    signal2_sampl1_reg <= sine_lut64_14bit[5];
    signal2_cntrl0_reg <= 2'd4;  //clipped to two bits
    signal2_cntrl1_reg <= 2'd5;  //clipped to two bits
    index2 <= 4;
    //Channel 3
    signal3_sampl0_reg <= sine_lut64_14bit[6];
    signal3_sampl1_reg <= sine_lut64_14bit[7];
    signal3_cntrl0_reg <= 2'd6;  //clipped to two bits
    signal3_cntrl1_reg <= 2'd7;  //clipped to two bits
    index3 <= 6;
    //Channel 4
    signal4_sampl0_reg <= sine_lut64_14bit[8];
    signal4_sampl1_reg <= sine_lut64_14bit[9];
    signal4_cntrl0_reg <= 2'd8;  //clipped to two bits
    signal4_cntrl1_reg <= 2'd9;  //clipped to two bits
    index4 <= 8;
    //Channel 5
    signal5_sampl0_reg <= sine_lut64_14bit[10];
    signal5_sampl1_reg <= sine_lut64_14bit[11];
    signal5_cntrl0_reg <= 2'd10;  //clipped to two bits
    signal5_cntrl1_reg <= 2'd11;  //clipped to two bits
    index5 <= 10;
    //Channel 6
    signal6_sampl0_reg <= sine_lut64_14bit[12];
    signal6_sampl1_reg <= sine_lut64_14bit[13];
    signal6_cntrl0_reg <= 2'd12;  //clipped to two bits
    signal6_cntrl1_reg <= 2'd13;  //clipped to two bits
    index6 <= 12;
    //Channel 7
    signal7_sampl0_reg <= sine_lut64_14bit[14];
    signal7_sampl1_reg <= sine_lut64_14bit[15];
    signal7_cntrl0_reg <= 2'd14;  //clipped to two bits
    signal7_cntrl1_reg <= 2'd15;  //clipped to two bits
    index7 <= 14;
  end
  else
  begin
    if(ready_in)
    begin
      //Channel 0
      signal0_sampl0_reg <= sine_lut64_14bit[index0];
      signal0_sampl1_reg <= sine_lut64_14bit[index0+1];
      signal0_cntrl0_reg <= index0;  //clipped to two bits
      signal0_cntrl1_reg <= index0+1;  //clipped to two bits
      index0 <= index0+2;
      //Channel 1
      signal1_sampl0_reg <= sine_lut64_14bit[index1];
      signal1_sampl1_reg <= sine_lut64_14bit[index1+1];
      signal1_cntrl0_reg <= index1;  //clipped to two bits
      signal1_cntrl1_reg <= index1+1;  //clipped to two bits
      index1 <= index1+2;
      //Channel 2
      signal2_sampl0_reg <= sine_lut64_14bit[index2];
      signal2_sampl1_reg <= sine_lut64_14bit[index2+1];
      signal2_cntrl0_reg <= index2;  //clipped to two bits
      signal2_cntrl1_reg <= index2+1;  //clipped to two bits
      index2 <= index2+2;
      //Channel 3
      signal3_sampl0_reg <= sine_lut64_14bit[index3];
      signal3_sampl1_reg <= sine_lut64_14bit[index3+1];
      signal3_cntrl0_reg <= index3;  //clipped to two bits
      signal3_cntrl1_reg <= index3+1;  //clipped to two bits
      index3 <= index3+2;
      //Channel 4
      signal4_sampl0_reg <= sine_lut64_14bit[index4];
      signal4_sampl1_reg <= sine_lut64_14bit[index4+1];
      signal4_cntrl0_reg <= index4;  //clipped to two bits
      signal4_cntrl1_reg <= index4+1;  //clipped to two bits
      index4 <= index4+2;
      //Channel 5
      signal5_sampl0_reg <= sine_lut64_14bit[index5];
      signal5_sampl1_reg <= sine_lut64_14bit[index5+1];
      signal5_cntrl0_reg <= index5;  //clipped to two bits
      signal5_cntrl1_reg <= index5+1;  //clipped to two bits
      index5 <= index5+2;
      //Channel 6
      signal6_sampl0_reg <= sine_lut64_14bit[index6];
      signal6_sampl1_reg <= sine_lut64_14bit[index6+1];
      signal6_cntrl0_reg <= index6;  //clipped to two bits
      signal6_cntrl1_reg <= index6+1;  //clipped to two bits
      index6 <= index6+2;
      //Channel 7
      signal7_sampl0_reg <= sine_lut64_14bit[index7];
      signal7_sampl1_reg <= sine_lut64_14bit[index7+1];
      signal7_cntrl0_reg <= index7;  //clipped to two bits
      signal7_cntrl1_reg <= index7+1;  //clipped to two bits
      index7 <= index7+2;
    end
  end
end//always

//assign the registered samples and control bits to the outputs
//Channel 0
assign signal0_sampl0 = signal0_sampl0_reg;
assign signal0_sampl1 = signal0_sampl1_reg;
assign signal0_cntrl0 = signal0_cntrl0_reg;
assign signal0_cntrl1 = signal0_cntrl1_reg;
//Channel 1
assign signal1_sampl0 = signal1_sampl0_reg;
assign signal1_sampl1 = signal1_sampl1_reg;
assign signal1_cntrl0 = signal1_cntrl0_reg;
assign signal1_cntrl1 = signal1_cntrl1_reg;
//Channel 2
assign signal2_sampl0 = signal2_sampl0_reg;
assign signal2_sampl1 = signal2_sampl1_reg;
assign signal2_cntrl0 = signal2_cntrl0_reg;
assign signal2_cntrl1 = signal2_cntrl1_reg;
//Channel 3
assign signal3_sampl0 = signal3_sampl0_reg;
assign signal3_sampl1 = signal3_sampl1_reg;
assign signal3_cntrl0 = signal3_cntrl0_reg;
assign signal3_cntrl1 = signal3_cntrl1_reg;
//Channel 4
assign signal4_sampl0 = signal4_sampl0_reg;
assign signal4_sampl1 = signal4_sampl1_reg;
assign signal4_cntrl0 = signal4_cntrl0_reg;
assign signal4_cntrl1 = signal4_cntrl1_reg;
//Channel 5
assign signal5_sampl0 = signal5_sampl0_reg;
assign signal5_sampl1 = signal5_sampl1_reg;
assign signal5_cntrl0 = signal5_cntrl0_reg;
assign signal5_cntrl1 = signal5_cntrl1_reg;
//Channel 6
assign signal6_sampl0 = signal6_sampl0_reg;
assign signal6_sampl1 = signal6_sampl1_reg;
assign signal6_cntrl0 = signal6_cntrl0_reg;
assign signal6_cntrl1 = signal6_cntrl1_reg;
//Channel 7
assign signal7_sampl0 = signal7_sampl0_reg;
assign signal7_sampl1 = signal7_sampl1_reg;
assign signal7_cntrl0 = signal7_cntrl0_reg;
assign signal7_cntrl1 = signal7_cntrl1_reg;

endmodule
