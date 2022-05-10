//----------------------------------------------------------------------------
// Title : Transport Layer Mapper for the Example Design
// Project : JESD204
//----------------------------------------------------------------------------
// File : jesd204_tx_transport_layer_mapper.v
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

module jesd204_tx_transport_layer_mapper (
  input         clk,
  input         rst_n,

  //Channel 0
  input  [13:0]  signal0_sampl0,
  input  [13:0]  signal0_sampl1,
  input   [1:0]  signal0_cntrl0,
  input   [1:0]  signal0_cntrl1,
  //Channel 1
  input  [13:0]  signal1_sampl0,
  input  [13:0]  signal1_sampl1,
  input   [1:0]  signal1_cntrl0,
  input   [1:0]  signal1_cntrl1,
  //Channel 2
  input  [13:0]  signal2_sampl0,
  input  [13:0]  signal2_sampl1,
  input   [1:0]  signal2_cntrl0,
  input   [1:0]  signal2_cntrl1,
  //Channel 3
  input  [13:0]  signal3_sampl0,
  input  [13:0]  signal3_sampl1,
  input   [1:0]  signal3_cntrl0,
  input   [1:0]  signal3_cntrl1,
  //Channel 4
  input  [13:0]  signal4_sampl0,
  input  [13:0]  signal4_sampl1,
  input   [1:0]  signal4_cntrl0,
  input   [1:0]  signal4_cntrl1,
  //Channel 5
  input  [13:0]  signal5_sampl0,
  input  [13:0]  signal5_sampl1,
  input   [1:0]  signal5_cntrl0,
  input   [1:0]  signal5_cntrl1,
  //Channel 6
  input  [13:0]  signal6_sampl0,
  input  [13:0]  signal6_sampl1,
  input   [1:0]  signal6_cntrl0,
  input   [1:0]  signal6_cntrl1,
  //Channel 7
  input  [13:0]  signal7_sampl0,
  input  [13:0]  signal7_sampl1,
  input   [1:0]  signal7_cntrl0,
  input   [1:0]  signal7_cntrl1,

  output [255:0] tx_tdata,
  input         tx_tready,
  
  output        ready_out
);

reg [31:0] lane0_data_reg;
reg [31:0] lane1_data_reg;
reg [31:0] lane2_data_reg;
reg [31:0] lane3_data_reg;
reg [31:0] lane4_data_reg;
reg [31:0] lane5_data_reg;
reg [31:0] lane6_data_reg;
reg [31:0] lane7_data_reg;

reg [1:0] fill;

always @(posedge clk, negedge rst_n)
begin
  if(!rst_n)
  begin
    lane0_data_reg <= 0;
    lane1_data_reg <= 0;
    lane2_data_reg <= 0;
    lane3_data_reg <= 0;
    lane4_data_reg <= 0;
    lane5_data_reg <= 0;
    lane6_data_reg <= 0;
    lane7_data_reg <= 0;
    fill <= 2'b10;
  end
  else
  begin
    if(tx_tready | fill)
    begin
      //map the control words and sample data into lanes
      lane0_data_reg <= {signal0_cntrl1[1:0], signal0_sampl1[13:0], signal0_cntrl0[1:0], signal0_sampl0[13:0]};
      lane1_data_reg <= {signal1_cntrl1[1:0], signal1_sampl1[13:0], signal1_cntrl0[1:0], signal1_sampl0[13:0]};
      lane2_data_reg <= {signal2_cntrl1[1:0], signal2_sampl1[13:0], signal2_cntrl0[1:0], signal2_sampl0[13:0]};
      lane3_data_reg <= {signal3_cntrl1[1:0], signal3_sampl1[13:0], signal3_cntrl0[1:0], signal3_sampl0[13:0]};
      lane4_data_reg <= {signal4_cntrl1[1:0], signal4_sampl1[13:0], signal4_cntrl0[1:0], signal4_sampl0[13:0]};
      lane5_data_reg <= {signal5_cntrl1[1:0], signal5_sampl1[13:0], signal5_cntrl0[1:0], signal5_sampl0[13:0]};
      lane6_data_reg <= {signal6_cntrl1[1:0], signal6_sampl1[13:0], signal6_cntrl0[1:0], signal6_sampl0[13:0]};
      lane7_data_reg <= {signal7_cntrl1[1:0], signal7_sampl1[13:0], signal7_cntrl0[1:0], signal7_sampl0[13:0]};
    end
    fill <= fill >> 1;
  end
end//always

//concatenate the individaual lane busses into one vector
assign tx_tdata = { lane7_data_reg, lane6_data_reg, lane5_data_reg, lane4_data_reg, lane3_data_reg, lane2_data_reg, lane1_data_reg,  lane0_data_reg };

assign ready_out = tx_tready | (|fill);

endmodule
