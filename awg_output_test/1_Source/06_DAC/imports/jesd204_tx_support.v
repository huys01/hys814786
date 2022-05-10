//----------------------------------------------------------------------------
// Title : Support Level Module
// Project : JESD204
//----------------------------------------------------------------------------
// File : jesd204_support.v
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
module jesd204_tx_support (
  // GT Reference Clock
//  input          refclk_p,
//  input          refclk_n,
  input			 refclk,
  input			 glbclk, 
  
  input	[4:0]	txpostcursor,
  input	[4:0]	txprecursor	,
  input	[3:0]	txdiffctrl	,

  // DRP Clock
  input          drpclk,

  // GT Common Ports
  output         common0_qpll0_lock_out,
  output         common0_qpll0_refclk_out,
  output         common0_qpll0_clk_out,
  output         common1_qpll0_lock_out,
  output         common1_qpll0_refclk_out,
  output         common1_qpll0_clk_out,
  //*******************************************
  // Tx Ports
  //*******************************************
  input          tx_reset,
  output         tx_core_clk_out,

  input          tx_sysref,
  input          tx_sync,

  output  [3:0]  txp,
  output  [3:0]  txn,

  // Tx AXI-S interface
  output         tx_aresetn,

  output  [3:0]  tx_start_of_frame,
  output  [3:0]  tx_start_of_multiframe,

  output         tx_tready,
  input  [127:0]  tx_tdata,


  // AXI-Lite Control/Status
  input          s_axi_aclk,
  input          s_axi_aresetn,
  input  [11:0]  s_axi_awaddr,
  input          s_axi_awvalid,
  output         s_axi_awready,
  input  [31:0]  s_axi_wdata,
  input   [3:0]  s_axi_wstrb,
  input          s_axi_wvalid,
  output         s_axi_wready,
  output  [1:0]  s_axi_bresp,
  output         s_axi_bvalid,
  input          s_axi_bready,
  input  [11:0]  s_axi_araddr,
  input          s_axi_arvalid,
  output         s_axi_arready,
  output [31:0]  s_axi_rdata,
  output  [1:0]  s_axi_rresp,
  output         s_axi_rvalid,
  input          s_axi_rready
);

//*******************************************
// Wire declaration
//*******************************************
//  wire         refclk;
  wire         tx_core_clk;

  wire         tx_reset_done;
  wire  [3:0]  gt_prbssel_i;



  wire         tx_reset_gt;
  wire [31:0]  gt0_txdata;
  wire [3:0]   gt0_txcharisk;

  wire [31:0]  gt0_rxdata;
  wire [3:0]   gt0_rxcharisk;
  wire [3:0]   gt0_rxdisperr;
  wire [3:0]   gt0_rxnotintable;

  wire [31:0]  gt1_txdata;
  wire [3:0]   gt1_txcharisk;

  wire [31:0]  gt1_rxdata;
  wire [3:0]   gt1_rxcharisk;
  wire [3:0]   gt1_rxdisperr;
  wire [3:0]   gt1_rxnotintable;

  wire [31:0]  gt2_txdata;
  wire [3:0]   gt2_txcharisk;

  wire [31:0]  gt2_rxdata;
  wire [3:0]   gt2_rxcharisk;
  wire [3:0]   gt2_rxdisperr;
  wire [3:0]   gt2_rxnotintable;

  wire [31:0]  gt3_txdata;
  wire [3:0]   gt3_txcharisk;

  wire [31:0]  gt3_rxdata;
  wire [3:0]   gt3_rxcharisk;
  wire [3:0]   gt3_rxdisperr;
  wire [3:0]   gt3_rxnotintable;

  wire [31:0]  gt4_txdata;
  wire [3:0]   gt4_txcharisk;

  wire [31:0]  gt4_rxdata;
  wire [3:0]   gt4_rxcharisk;
  wire [3:0]   gt4_rxdisperr;
  wire [3:0]   gt4_rxnotintable;

  wire [31:0]  gt5_txdata;
  wire [3:0]   gt5_txcharisk;

  wire [31:0]  gt5_rxdata;
  wire [3:0]   gt5_rxcharisk;
  wire [3:0]   gt5_rxdisperr;
  wire [3:0]   gt5_rxnotintable;

  wire [31:0]  gt6_txdata;
  wire [3:0]   gt6_txcharisk;

  wire [31:0]  gt6_rxdata;
  wire [3:0]   gt6_rxcharisk;
  wire [3:0]   gt6_rxdisperr;
  wire [3:0]   gt6_rxnotintable;

  wire [31:0]  gt7_txdata;
  wire [3:0]   gt7_txcharisk;

  wire [31:0]  gt7_rxdata;
  wire [3:0]   gt7_rxcharisk;
  wire [3:0]   gt7_rxdisperr;
  wire [3:0]   gt7_rxnotintable;



//*******************************************
// JESD204 Core
//*******************************************
jesd204_tx jesd204_i
 (
  // Tx
  .tx_reset               (tx_reset),
  .tx_core_clk            (tx_core_clk),

  .tx_sysref              (tx_sysref),
  .tx_sync                (tx_sync),

   // Ports Required for GT
  .tx_reset_gt           (tx_reset_gt),

  .tx_reset_done         (tx_reset_done),
  .gt_prbssel_out        (gt_prbssel_i),
  // Lane 0
  .gt0_txdata            (gt0_txdata),
  .gt0_txcharisk         (gt0_txcharisk),

  // Lane 1
  .gt1_txdata            (gt1_txdata),
  .gt1_txcharisk         (gt1_txcharisk),

  // Lane 2
  .gt2_txdata            (gt2_txdata),
  .gt2_txcharisk         (gt2_txcharisk),

  // Lane 3
  .gt3_txdata            (gt3_txdata),
  .gt3_txcharisk         (gt3_txcharisk),

//  // Lane 4
//  .gt4_txdata            (gt4_txdata),
//  .gt4_txcharisk         (gt4_txcharisk),
//
//  // Lane 5
//  .gt5_txdata            (gt5_txdata),
//  .gt5_txcharisk         (gt5_txcharisk),
//
//  // Lane 6
//  .gt6_txdata            (gt6_txdata),
//  .gt6_txcharisk         (gt6_txcharisk),
//
//  // Lane 7
//  .gt7_txdata            (gt7_txdata),
//  .gt7_txcharisk         (gt7_txcharisk),


  // Tx AXI interface for each lane
  .tx_aresetn             (tx_aresetn),

  .tx_start_of_frame      (tx_start_of_frame),
  .tx_start_of_multiframe (tx_start_of_multiframe),

  .tx_tdata               (tx_tdata),
  .tx_tready              (tx_tready),


  // AXI-Lite Control/Status
  .s_axi_aclk             (s_axi_aclk),
  .s_axi_aresetn          (s_axi_aresetn),
  .s_axi_awaddr           (s_axi_awaddr),
  .s_axi_awvalid          (s_axi_awvalid),
  .s_axi_awready          (s_axi_awready),
  .s_axi_wdata            (s_axi_wdata),
  .s_axi_wstrb            (s_axi_wstrb),
  .s_axi_wvalid           (s_axi_wvalid),
  .s_axi_wready           (s_axi_wready),
  .s_axi_bresp            (s_axi_bresp),
  .s_axi_bvalid           (s_axi_bvalid),
  .s_axi_bready           (s_axi_bready),
  .s_axi_araddr           (s_axi_araddr),
  .s_axi_arvalid          (s_axi_arvalid),
  .s_axi_arready          (s_axi_arready),
  .s_axi_rdata            (s_axi_rdata),
  .s_axi_rresp            (s_axi_rresp),
  .s_axi_rvalid           (s_axi_rvalid),
  .s_axi_rready           (s_axi_rready)
);

//*******************************************
// Shared Clocking Module
// Clocks from this module can be used to
// share with other CL modules
//*******************************************
/*jesd204_tx_clocking
i_shared_clocks(
  .refclk_pad_n         (refclk_n),
  .refclk_pad_p         (refclk_p),
  .refclk               (refclk),       //Used to drive GT Ref clock  

  .glblclk_pad_n        (glblclk_n),
  .glblclk_pad_p        (glblclk_p),

  .coreclk              (tx_core_clk)  //Clock used by JESD204 core and usrclk2 input for GT module
 );*/
  assign	tx_core_clk = glbclk;
// Assign values to output clocks
  assign tx_core_clk_out = tx_core_clk;
  
//*******************************************
// Instantiate JESD204 PHY Core
//*******************************************
  jesd204_tx_phy
  i_jesd204_phy (
  // Reset Done for each GT Channel
  .gt_txresetdone          (),
  .gt_rxresetdone          (),

  // CPLL Lock for each GT Channel
  .gt_cplllock             (),

  // Loopback
  .gt_loopback             (24'b0),

  .gt_txprbsforceerr       (8'b0),

  .gt_rxprbssel            (32'b0),
  .gt_rxprbscntreset       (8'b0),
  .gt_rxprbserr            (),

  // Transmit Control
  .gt_txpostcursor          ({8{txpostcursor}}),
  .gt_txprecursor           ({8{txprecursor}}),
  
  .gt_txdiffctrl            ({8{txdiffctrl}}),
  .gt_txpolarity            (8'b0),
  .gt_txinhibit             (8'b0),

  .gt_rxpolarity            (8'b0),

  // Power Down Ports
  .gt_rxpd                 ({8{2'b00}}),
  .gt_txpd                 ({8{2'b00}}),

  // TX Reset and Initialization
  .gt_txpcsreset           (8'b0),
  .gt_txpmareset           (8'b0),

  // RX Reset and Initialization
  .gt_rxpcsreset           (8'b0),
  .gt_rxpmareset           (8'b0),
  .gt_rxbufreset           (8'b0),
  .gt_rxpmaresetdone       (),

  // TX Buffer Ports
  .gt_txbufstatus          (),

  // RX Buffer Ports
  .gt_rxbufstatus          (),

  // PCI Express Ports
  .gt_rxrate               (24'b0),

  // RX Margin Analysis Ports
  .gt_eyescantrigger       (8'b0),
  .gt_eyescanreset         (8'b0),
  .gt_eyescandataerror     (),

  // RX Equalizer Ports
  .gt_rxdfelpmreset        (8'b0),
  .gt_rxlpmen              ({8{1'b1}}),

  // RX CDR Ports
  .gt_rxcdrhold            (8'b0),

  // RX Digital Monitor Ports
  .gt_dmonitorclk          (8'b0),
  .gt_dmonitorout          (),

  // RX Byte and Word Alignment Ports
  .gt_rxcommadet           (),

  .gt_pcsrsvdin            (128'b0),
  
  // Reset Inputs for each direction
  .tx_reset_gt             (tx_reset_gt),
  .rx_reset_gt             (tx_reset_gt),
  .tx_sys_reset            (tx_reset),
  .rx_sys_reset            (tx_reset),


  // GT Common I/O
  .qpll0_refclk             (refclk),
  .common0_qpll0_lock_out   (common0_qpll0_lock_out),
  .common0_qpll0_refclk_out (common0_qpll0_refclk_out),
  .common0_qpll0_clk_out    (common0_qpll0_clk_out),
//  .common1_qpll0_lock_out   (common1_qpll0_lock_out),
//  .common1_qpll0_refclk_out (common1_qpll0_refclk_out),
//  .common1_qpll0_clk_out    (common1_qpll0_clk_out),

  // Reset Done for each direction
  .tx_reset_done            (tx_reset_done),
  .rx_reset_done            (),

  .gt_powergood             (),

  .rxencommaalign           (1'b0),   //If connecting with RX core use signal from RX JESD204

  // Clocks
  .tx_core_clk              (tx_core_clk),
  .txoutclk                 (),

  .rx_core_clk              (tx_core_clk),
  .rxoutclk                 (),
  
  .drpclk                   (drpclk),

  //Tx PRBSSEL Pattern Generator
  .gt_prbssel               (gt_prbssel_i),

  // DRP Ports
  
  .gt0_drpaddr             (9'd0),
    
  .gt0_drpdi               (16'd0),
  .gt0_drpen               (1'b0),
  .gt0_drpwe               (1'b0),
  .gt0_drpdo               (),
  .gt0_drprdy              (),

  
  .gt1_drpaddr             (9'd0),
    
  .gt1_drpdi               (16'd0),
  .gt1_drpen               (1'b0),
  .gt1_drpwe               (1'b0),
  .gt1_drpdo               (),
  .gt1_drprdy              (),

  
  .gt2_drpaddr             (9'd0),
    
  .gt2_drpdi               (16'd0),
  .gt2_drpen               (1'b0),
  .gt2_drpwe               (1'b0),
  .gt2_drpdo               (),
  .gt2_drprdy              (),

  
  .gt3_drpaddr             (9'd0),
    
  .gt3_drpdi               (16'd0),
  .gt3_drpen               (1'b0),
  .gt3_drpwe               (1'b0),
  .gt3_drpdo               (),
  .gt3_drprdy              (),

  
//  .gt4_drpaddr             (9'd0),
//    
//  .gt4_drpdi               (16'd0),
//  .gt4_drpen               (1'b0),
//  .gt4_drpwe               (1'b0),
//  .gt4_drpdo               (),
//  .gt4_drprdy              (),
//
//  
//  .gt5_drpaddr             (9'd0),
//    
//  .gt5_drpdi               (16'd0),
//  .gt5_drpen               (1'b0),
//  .gt5_drpwe               (1'b0),
//  .gt5_drpdo               (),
//  .gt5_drprdy              (),
//
//  
//  .gt6_drpaddr             (9'd0),
//    
//  .gt6_drpdi               (16'd0),
//  .gt6_drpen               (1'b0),
//  .gt6_drpwe               (1'b0),
//  .gt6_drpdo               (),
//  .gt6_drprdy              (),
//
//  
//  .gt7_drpaddr             (9'd0),
//    
//  .gt7_drpdi               (16'd0),
//  .gt7_drpen               (1'b0),
//  .gt7_drpwe               (1'b0),
//  .gt7_drpdo               (),
//  .gt7_drprdy              (),

  // Tx Ports
  // Lane 0
  .gt0_txdata              (gt0_txdata),
  .gt0_txcharisk           (gt0_txcharisk),

  // Lane 1
  .gt1_txdata              (gt1_txdata),
  .gt1_txcharisk           (gt1_txcharisk),

  // Lane 2
  .gt2_txdata              (gt2_txdata),
  .gt2_txcharisk           (gt2_txcharisk),

  // Lane 3
  .gt3_txdata              (gt3_txdata),
  .gt3_txcharisk           (gt3_txcharisk),

//  // Lane 4
//  .gt4_txdata              (gt4_txdata),
//  .gt4_txcharisk           (gt4_txcharisk),
//
//  // Lane 5
//  .gt5_txdata              (gt5_txdata),
//  .gt5_txcharisk           (gt5_txcharisk),
//
//  // Lane 6
//  .gt6_txdata              (gt6_txdata),
//  .gt6_txcharisk           (gt6_txcharisk),
//
//  // Lane 7
//  .gt7_txdata              (gt7_txdata),
//  .gt7_txcharisk           (gt7_txcharisk),


 // Rx Ports
  // Lane 0
  .gt0_rxdata              (gt0_rxdata),
  .gt0_rxcharisk           (gt0_rxcharisk),
  .gt0_rxdisperr           (gt0_rxdisperr),
  .gt0_rxnotintable        (gt0_rxnotintable),

  // Lane 1
  .gt1_rxdata              (gt1_rxdata),
  .gt1_rxcharisk           (gt1_rxcharisk),
  .gt1_rxdisperr           (gt1_rxdisperr),
  .gt1_rxnotintable        (gt1_rxnotintable),

  // Lane 2
  .gt2_rxdata              (gt2_rxdata),
  .gt2_rxcharisk           (gt2_rxcharisk),
  .gt2_rxdisperr           (gt2_rxdisperr),
  .gt2_rxnotintable        (gt2_rxnotintable),

  // Lane 3
  .gt3_rxdata              (gt3_rxdata),
  .gt3_rxcharisk           (gt3_rxcharisk),
  .gt3_rxdisperr           (gt3_rxdisperr),
  .gt3_rxnotintable        (gt3_rxnotintable),

//  // Lane 4
//  .gt4_rxdata              (gt4_rxdata),
//  .gt4_rxcharisk           (gt4_rxcharisk),
//  .gt4_rxdisperr           (gt4_rxdisperr),
//  .gt4_rxnotintable        (gt4_rxnotintable),
//
//  // Lane 5
//  .gt5_rxdata              (gt5_rxdata),
//  .gt5_rxcharisk           (gt5_rxcharisk),
//  .gt5_rxdisperr           (gt5_rxdisperr),
//  .gt5_rxnotintable        (gt5_rxnotintable),
//
//  // Lane 6
//  .gt6_rxdata              (gt6_rxdata),
//  .gt6_rxcharisk           (gt6_rxcharisk),
//  .gt6_rxdisperr           (gt6_rxdisperr),
//  .gt6_rxnotintable        (gt6_rxnotintable),
//
//  // Lane 7
//  .gt7_rxdata              (gt7_rxdata),
//  .gt7_rxcharisk           (gt7_rxcharisk),
//  .gt7_rxdisperr           (gt7_rxdisperr),
//  .gt7_rxnotintable        (gt7_rxnotintable),

  // Serial ports
  .rxn_in                   (4'b0),
  .rxp_in                   (4'b0),
  .txn_out                  (txn),
  .txp_out                  (txp)
);
/*
ila_gth u_ila_gth (
	.clk								( tx_core_clk		),
	.probe0								( gt0_txdata		),
	.probe1								( gt0_txcharisk		),
	.probe2								( gt1_txdata		),
	.probe3								( gt1_txcharisk	 	)
);*/

endmodule
