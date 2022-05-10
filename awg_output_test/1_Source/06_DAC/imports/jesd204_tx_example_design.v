//----------------------------------------------------------------------------
// Title : Example Design Top Level
// Project : JESD204
//----------------------------------------------------------------------------
// File : jesd204_tx_example_design.v
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

(* DowngradeIPIdentifiedWarnings = "yes" *)
module jesd204_tx_example_design #(
  parameter               pLanes = 8 ) (
  input                   refclk0p,
  input                   refclk0n,

  input                   glblclkp,
  input                   glblclkn,
  
  input                   drpclk,

  input                   tx_reset,
  output [3:0]            tx_start_of_frame,
  output [3:0]            tx_start_of_multiframe,

  output [pLanes-1:0]     txp,
  output [pLanes-1:0]     txn,
  
  input                   s_axi_aclk,
  input                   s_axi_aresetn,
  input  [11:0]           s_axi_awaddr,
  input                   s_axi_awvalid,
  output                  s_axi_awready,
  input  [31:0]           s_axi_wdata,
  input  [3:0]            s_axi_wstrb,
  input                   s_axi_wvalid,
  output                  s_axi_wready,
  output [1:0]            s_axi_bresp,
  output                  s_axi_bvalid,
  input                   s_axi_bready,
  input  [11:0]           s_axi_araddr,
  input                   s_axi_arvalid,
  output                  s_axi_arready,
  output [31:0]           s_axi_rdata,
  output [1:0]            s_axi_rresp,
  output                  s_axi_rvalid,
  input                   s_axi_rready,


  // Tx AXI common signals
  output                  tx_aresetn,

  input                   tx_sysref,

  input                   tx_sync

);

  wire [13:0] sine_lut64_14bit [63:0];
 `include "sine_lut64_14bit.vh"
  wire       tx_core_clk;  
  
  //Channel 0
  wire[13:0] signal0_sampl0;
  wire[13:0] signal0_sampl1;
  wire [1:0] signal0_cntrl0;
  wire [1:0] signal0_cntrl1;
  //Channel 1
  wire[13:0] signal1_sampl0;
  wire[13:0] signal1_sampl1;
  wire [1:0] signal1_cntrl0;
  wire [1:0] signal1_cntrl1;
  //Channel 2
  wire[13:0] signal2_sampl0;
  wire[13:0] signal2_sampl1;
  wire [1:0] signal2_cntrl0;
  wire [1:0] signal2_cntrl1;
  //Channel 3
  wire[13:0] signal3_sampl0;
  wire[13:0] signal3_sampl1;
  wire [1:0] signal3_cntrl0;
  wire [1:0] signal3_cntrl1;
  //Channel 4
  wire[13:0] signal4_sampl0;
  wire[13:0] signal4_sampl1;
  wire [1:0] signal4_cntrl0;
  wire [1:0] signal4_cntrl1;
  //Channel 5
  wire[13:0] signal5_sampl0;
  wire[13:0] signal5_sampl1;
  wire [1:0] signal5_cntrl0;
  wire [1:0] signal5_cntrl1;
  //Channel 6
  wire[13:0] signal6_sampl0;
  wire[13:0] signal6_sampl1;
  wire [1:0] signal6_cntrl0;
  wire [1:0] signal6_cntrl1;
  //Channel 7
  wire[13:0] signal7_sampl0;
  wire[13:0] signal7_sampl1;
  wire [1:0] signal7_cntrl0;
  wire [1:0] signal7_cntrl1;

  wire tl_ready;


  wire                    txusrclk;

  wire                    tx_tready;
  wire   [(pLanes*32)-1:0]           tx_tdata;

  wire                    s_axi_aclk_i;
  wire                    drpclk_buf;

jesd204_tx_support i_jesd204_tx_support_block(

  // GT Reference Clock
  .refclk_p                 (refclk0p),
  .refclk_n                 (refclk0n),
  // Global Clock
  .glblclk_p                (glblclkp),
  .glblclk_n                (glblclkn),
  .drpclk                   (drpclk_buf),
  // GT Common I/O
  .common0_qpll0_lock_out   (common0_qpll0_lock_out),
  .common0_qpll0_refclk_out (common0_qpll0_refclk_out),
  .common0_qpll0_clk_out    (common0_qpll0_clk_out),
  .common1_qpll0_lock_out   (common1_qpll0_lock_out),
  .common1_qpll0_refclk_out (common1_qpll0_refclk_out),
  .common1_qpll0_clk_out    (common1_qpll0_clk_out),
  // Tx
  .tx_reset                 (tx_reset),

  .tx_core_clk_out          (tx_core_clk),

  .tx_sysref                (tx_sysref),
  .tx_sync                  (tx_sync),

  .txp                      (txp),
  .txn                      (txn),

  // Tx AXI interface for each lane
  .tx_aresetn               (tx_aresetn),

  .tx_start_of_frame        (tx_start_of_frame),
  .tx_start_of_multiframe   (tx_start_of_multiframe),
  // Lane Data
  .tx_tdata                 (tx_tdata),
  .tx_tready                (tx_tready),

  // AXI-Lite Control/Status
  .s_axi_aclk               (s_axi_aclk_i),
  .s_axi_aresetn            (s_axi_aresetn),
  .s_axi_awaddr             (s_axi_awaddr),
  .s_axi_awvalid            (s_axi_awvalid),
  .s_axi_awready            (s_axi_awready),
  .s_axi_wdata              (s_axi_wdata),
  .s_axi_wstrb              (s_axi_wstrb),
  .s_axi_wvalid             (s_axi_wvalid),
  .s_axi_wready             (s_axi_wready),
  .s_axi_bresp              (s_axi_bresp),
  .s_axi_bvalid             (s_axi_bvalid),
  .s_axi_bready             (s_axi_bready),
  .s_axi_araddr             (s_axi_araddr),
  .s_axi_arvalid            (s_axi_arvalid),
  .s_axi_arready            (s_axi_arready),
  .s_axi_rdata              (s_axi_rdata),
  .s_axi_rresp              (s_axi_rresp),
  .s_axi_rvalid             (s_axi_rvalid),
  .s_axi_rready             (s_axi_rready)
);

  BUFG axi_bufg_i (.I(s_axi_aclk), .O(s_axi_aclk_i));
  BUFG drp_bufg_i (.I(drpclk), .O(drpclk_buf));

jesd204_tx_sig_gen jesd204_tx_sig_gen_i (
  .clk(tx_core_clk),
  .rst_n(tx_aresetn),

  //Channel 0
  .signal0_sampl0(signal0_sampl0),
  .signal0_sampl1(signal0_sampl1),
  .signal0_cntrl0(signal0_cntrl0),
  .signal0_cntrl1(signal0_cntrl1),
  //Channel 1
  .signal1_sampl0(signal1_sampl0),
  .signal1_sampl1(signal1_sampl1),
  .signal1_cntrl0(signal1_cntrl0),
  .signal1_cntrl1(signal1_cntrl1),
  //Channel 2
  .signal2_sampl0(signal2_sampl0),
  .signal2_sampl1(signal2_sampl1),
  .signal2_cntrl0(signal2_cntrl0),
  .signal2_cntrl1(signal2_cntrl1),
  //Channel 3
  .signal3_sampl0(signal3_sampl0),
  .signal3_sampl1(signal3_sampl1),
  .signal3_cntrl0(signal3_cntrl0),
  .signal3_cntrl1(signal3_cntrl1),
  //Channel 4
  .signal4_sampl0(signal4_sampl0),
  .signal4_sampl1(signal4_sampl1),
  .signal4_cntrl0(signal4_cntrl0),
  .signal4_cntrl1(signal4_cntrl1),
  //Channel 5
  .signal5_sampl0(signal5_sampl0),
  .signal5_sampl1(signal5_sampl1),
  .signal5_cntrl0(signal5_cntrl0),
  .signal5_cntrl1(signal5_cntrl1),
  //Channel 6
  .signal6_sampl0(signal6_sampl0),
  .signal6_sampl1(signal6_sampl1),
  .signal6_cntrl0(signal6_cntrl0),
  .signal6_cntrl1(signal6_cntrl1),
  //Channel 7
  .signal7_sampl0(signal7_sampl0),
  .signal7_sampl1(signal7_sampl1),
  .signal7_cntrl0(signal7_cntrl0),
  .signal7_cntrl1(signal7_cntrl1),
  .ready_in(tl_ready)
);

jesd204_tx_transport_layer_mapper jesd204_tx_transport_layer_mapper_i (
  .clk(tx_core_clk),
  .rst_n(tx_aresetn),

  //Channel 0
  .signal0_sampl0(signal0_sampl0),
  .signal0_sampl1(signal0_sampl1),
  .signal0_cntrl0(signal0_cntrl0),
  .signal0_cntrl1(signal0_cntrl1),
  //Channel 1
  .signal1_sampl0(signal1_sampl0),
  .signal1_sampl1(signal1_sampl1),
  .signal1_cntrl0(signal1_cntrl0),
  .signal1_cntrl1(signal1_cntrl1),
  //Channel 2
  .signal2_sampl0(signal2_sampl0),
  .signal2_sampl1(signal2_sampl1),
  .signal2_cntrl0(signal2_cntrl0),
  .signal2_cntrl1(signal2_cntrl1),
  //Channel 3
  .signal3_sampl0(signal3_sampl0),
  .signal3_sampl1(signal3_sampl1),
  .signal3_cntrl0(signal3_cntrl0),
  .signal3_cntrl1(signal3_cntrl1),
  //Channel 4
  .signal4_sampl0(signal4_sampl0),
  .signal4_sampl1(signal4_sampl1),
  .signal4_cntrl0(signal4_cntrl0),
  .signal4_cntrl1(signal4_cntrl1),
  //Channel 5
  .signal5_sampl0(signal5_sampl0),
  .signal5_sampl1(signal5_sampl1),
  .signal5_cntrl0(signal5_cntrl0),
  .signal5_cntrl1(signal5_cntrl1),
  //Channel 6
  .signal6_sampl0(signal6_sampl0),
  .signal6_sampl1(signal6_sampl1),
  .signal6_cntrl0(signal6_cntrl0),
  .signal6_cntrl1(signal6_cntrl1),
  //Channel 7
  .signal7_sampl0(signal7_sampl0),
  .signal7_sampl1(signal7_sampl1),
  .signal7_cntrl0(signal7_cntrl0),
  .signal7_cntrl1(signal7_cntrl1),

  .tx_tdata(tx_tdata),

  .tx_tready(tx_tready),
  .ready_out(tl_ready)
);

endmodule


