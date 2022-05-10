//----------------------------------------------------------------------------
// Title : Demo Testbench
// Project : JESD204
//----------------------------------------------------------------------------
// File : demo_tb.v
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
// Description :
// TX description
//
//----------------------------------------------------------------------------

`timescale 1ps / 1ps

module demo_tb ;
  wire [13:0] sine_lut64_14bit [63:0];
 `include "sine_lut64_14bit.vh"
 
  localparam  pSimtimeout_count         = 40;   
  localparam  simtimeout                = 100000000;

  localparam pLanes = 8;
  localparam pAlign_buf_size = 64;
  // F = 2 K = 32
  localparam pF        = 2;
  localparam pK        = 32;

  // Setup the link configuration parameters.
  localparam [7:0] pDID      = 8'h55;
  localparam [3:0] pADJCNT   = 4'h0;
  localparam [3:0] pBID      = 4'hA;
  localparam       pADJDIR   = 1'b0;
  localparam       pPHADJ    = 1'b0;
  localparam       pSCR      = 1'b0;
  localparam [4:0] pL        = (pLanes-1);
  localparam [7:0] pM        = (pLanes-1);
  localparam [1:0] pCS       = 2'd2;
  localparam [4:0] pN        = 5'd13;
  localparam [4:0] pNt       = 5'd15;
  localparam [2:0] pSUBCV    = 3'b001;
  localparam [2:0] pJESDV    = 3'b001;
  localparam [4:0] pS        = 5'd0;
  localparam       pHD       = 1'b0;
  localparam [4:0] pCF       = 5'd1;
  localparam [7:0] pRES1     = 8'h5A;
  localparam [7:0] pRES2     = 8'hA5;

  localparam pInit_len = pF*pK*4;

  // Fixed symbols
  localparam pK_is_r = 8'h1C; // K28_0
  localparam pK_is_a = 8'h7C; // K28_3
  localparam pK_is_q = 8'h9C; // K28_4
  localparam pK_is_k = 8'hBC; // K28_5


  reg            reset;
  reg            refclk0p;
  reg            refclk0n;

  reg            glblclkp;
  reg            glblclkn;
  reg            drpclk;

  wire [pLanes-1:0]     txn;
  wire [pLanes-1:0]     txp;
  reg  [(pLanes*8)-1:0] tx_decoded_data;
  reg  [pLanes-1:0]     tx_decoded_is_k;
  reg                   bc_ok;

  reg            tx_sync;

  // Lane 0
  wire           tx_aresetn;

  reg            tx_bitclock;

  reg [2:0]      counter;
  reg            tx_octet_clock;
  reg            all_lanes_synced;

  reg            tx_sysref;

  wire           tx_aclk;

  reg            s_axi_aclk;
  reg            s_axi_aresetn;
  reg  [11:0]    s_axi_awaddr = 0;
  reg            s_axi_awvalid = 0;
  wire           s_axi_awready;
  reg  [31:0]    s_axi_wdata = 0;
  reg            s_axi_wvalid = 0;
  wire           s_axi_wready;
  wire [ 1:0]    s_axi_bresp;
  wire           s_axi_bvalid;
  reg            s_axi_bready = 0;
  reg  [11:0]    s_axi_araddr = 0;
  reg            s_axi_arvalid = 0;
  wire           s_axi_arready;
  wire [31:0]    s_axi_rdata;
  wire [ 1:0]    s_axi_rresp;
  wire           s_axi_rvalid;
  reg            s_axi_rready = 0;

  reg            axiReset_done = 1'b0;

  reg  [31:0]    simtimeout_count;

  //-----------------------------------------------------------------------------
  // Connect the Design Under Test
  //-----------------------------------------------------------------------------
  jesd204_tx_example_design DUT(
    .refclk0p               (refclk0p),
    .refclk0n               (refclk0n),

    .glblclkp               (glblclkp),
    .glblclkn               (glblclkn),

   .drpclk                   (drpclk),

    .tx_reset               (reset),
    .tx_start_of_frame      (),
    .tx_start_of_multiframe (),
    .txp                    (txp),
    .txn                    (txn),

    .s_axi_aclk             (s_axi_aclk),
    .s_axi_aresetn          (s_axi_aresetn),
    .s_axi_awaddr           (s_axi_awaddr),
    .s_axi_awvalid          (s_axi_awvalid),
    .s_axi_awready          (s_axi_awready),
    .s_axi_wdata            (s_axi_wdata),
    .s_axi_wstrb            (4'hF),
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
    .s_axi_rready           (s_axi_rready),


    // Tx AXI common signals
    .tx_aresetn             (tx_aresetn),
    .tx_sysref              (tx_sysref),
    .tx_sync                (tx_sync)
  );

  assign tx_aclk = glblclkp;


  // Generate the 400MHz GTHE3 refclk
  initial
  begin
     refclk0p <= 1'b0;
     refclk0n <= 1'b1;
     forever
     begin
        refclk0p <= 1'b0;
        refclk0n <= 1'b1;
        #1240;
        refclk0p <= 1'b1;
        refclk0n <= 1'b0;
        #1240;
     end
  end

  // Generate the 400.0MHz Device Clock
  initial
  begin
     glblclkp <= 1'b0;
     glblclkn <= 1'b1;
     forever
     begin
        glblclkp <= 1'b0;
        glblclkn <= 1'b1;
        #1240;
        glblclkp <= 1'b1;
        glblclkn <= 1'b0;
        #1240;
     end
  end
  // Generate the 200.0MHz DRP Clock
  initial
  begin
     drpclk <= 1'b0;
     forever
     begin
        drpclk <= 1'b0;
        #2500;
        drpclk <= 1'b1;
        #2500;
     end
  end
  // Generate the 100.0MHz CPU/AXI clk
  initial
  begin
     s_axi_aclk <= 1'b0;
     forever
     begin
        s_axi_aclk <= 1'b1;
        #5000;
        s_axi_aclk <= 1'b0;
        #5000;
     end
  end

  // The following generates the bitclock for sampling the Tx data
  // streams. It uses the lane0 transmit signal, waits a time
  // to allow the stream to stabilise, then centres the tx_bitclock
  // transition in the centre of the transmit eye. This signal is used
  // as a sampling point.
  initial
    begin : p_tx_bitclock
      tx_bitclock <= 0;
      @(negedge reset);       @(posedge tx_aresetn);
      #1240;
      @(posedge txp);
      #31;
      forever
        #31 tx_bitclock <= !tx_bitclock;
    end

  // The following generates the octet clock for sampling the Tx data stream
  // octets. It is divided /10 from tx_bitclock and uses the all lanes synced
  // signal to determine the start and the alignment of the valid data
  always @(posedge tx_bitclock)
  begin
    if ( all_lanes_synced !== 1'b1)
    begin
      counter        <= 0;
      tx_octet_clock <= 0;
    end
    else
    begin
      if ( counter == 3'd4 )
      begin
        tx_octet_clock <= !tx_octet_clock;
        counter <= 0;
      end
      else
        counter <= counter + 1'b1;
    end
  end //always


  // SYSREF Generation
  // This generate a periodic SYSREF with period = 4 Multiframes.
  initial
  begin : sysref_gen
    reg [5:0]      sysref_count;
    reg            sysref;
    forever begin
      @(posedge tx_aclk) begin
        if (tx_aresetn == 1'b0) begin
          sysref_count <= 6'b0;
          sysref       <= 1'b0;
          tx_sysref    <= 1'b0;
        end
        else begin
          sysref_count <= sysref_count + 1;
          if (sysref_count == 6'b111111)
            sysref <= 1'b1;
          else
            sysref <= 1'b0;
          tx_sysref    <= #1000 sysref;
        end
      end
    end
  end


  // Helper task for the transmitter monitor processes
  task decode_8b10b;
    input  [0:9] d10;
    output [7:0] q8;
    output       is_k;
    reg          k28;
    reg    [9:0] d10_rev;
    integer I;
    begin
      // reverse the 10B codeword
      for (I = 0; I < 10; I = I + 1)
        d10_rev[I] = d10[I];

      case (d10_rev[5:0])
        6'b000110 : q8[4:0] = 5'b00000;   //D.0
        6'b111001 : q8[4:0] = 5'b00000;   //D.0
        6'b010001 : q8[4:0] = 5'b00001;   //D.1
        6'b101110 : q8[4:0] = 5'b00001;   //D.1
        6'b010010 : q8[4:0] = 5'b00010;   //D.2
        6'b101101 : q8[4:0] = 5'b00010;   //D.2
        6'b100011 : q8[4:0] = 5'b00011;   //D.3
        6'b010100 : q8[4:0] = 5'b00100;   //D.4
        6'b101011 : q8[4:0] = 5'b00100;   //D.4
        6'b100101 : q8[4:0] = 5'b00101;   //D.5
        6'b100110 : q8[4:0] = 5'b00110;   //D.6
        6'b000111 : q8[4:0] = 5'b00111;   //D.7
        6'b111000 : q8[4:0] = 5'b00111;   //D.7
        6'b011000 : q8[4:0] = 5'b01000;   //D.8
        6'b100111 : q8[4:0] = 5'b01000;   //D.8
        6'b101001 : q8[4:0] = 5'b01001;   //D.9
        6'b101010 : q8[4:0] = 5'b01010;   //D.10
        6'b001011 : q8[4:0] = 5'b01011;   //D.11
        6'b101100 : q8[4:0] = 5'b01100;   //D.12
        6'b001101 : q8[4:0] = 5'b01101;   //D.13
        6'b001110 : q8[4:0] = 5'b01110;   //D.14
        6'b000101 : q8[4:0] = 5'b01111;   //D.15
        6'b111010 : q8[4:0] = 5'b01111;   //D.15
        6'b110110 : q8[4:0] = 5'b10000;   //D.16
        6'b001001 : q8[4:0] = 5'b10000;   //D.16
        6'b110001 : q8[4:0] = 5'b10001;   //D.17
        6'b110010 : q8[4:0] = 5'b10010;   //D.18
        6'b010011 : q8[4:0] = 5'b10011;   //D.19
        6'b110100 : q8[4:0] = 5'b10100;   //D.20
        6'b010101 : q8[4:0] = 5'b10101;   //D.21
        6'b010110 : q8[4:0] = 5'b10110;   //D.22
        6'b010111 : q8[4:0] = 5'b10111;   //D/K.23
        6'b101000 : q8[4:0] = 5'b10111;   //D/K.23
        6'b001100 : q8[4:0] = 5'b11000;   //D.24
        6'b110011 : q8[4:0] = 5'b11000;   //D.24
        6'b011001 : q8[4:0] = 5'b11001;   //D.25
        6'b011010 : q8[4:0] = 5'b11010;   //D.26
        6'b011011 : q8[4:0] = 5'b11011;   //D/K.27
        6'b100100 : q8[4:0] = 5'b11011;   //D/K.27
        6'b011100 : q8[4:0] = 5'b11100;   //D.28
        6'b111100 : q8[4:0] = 5'b11100;   //K.28
        6'b000011 : q8[4:0] = 5'b11100;   //K.28
        6'b011101 : q8[4:0] = 5'b11101;   //D/K.29
        6'b100010 : q8[4:0] = 5'b11101;   //D/K.29
        6'b011110 : q8[4:0] = 5'b11110;   //D.30
        6'b100001 : q8[4:0] = 5'b11110;   //D.30
        6'b110101 : q8[4:0] = 5'b11111;   //D.31
        6'b001010 : q8[4:0] = 5'b11111;   //D.31
        default   : q8[4:0] = 5'b11110;   //CODE VIOLATION - return /E/
      endcase

      k28 = ~((d10[2] | d10[3] | d10[4] | d10[5] | ~(d10[8] ^ d10[9])));

      case (d10_rev[9:6])
        4'b0010 : q8[7:5] = 3'b000;       //D/K.x.0
        4'b1101 : q8[7:5] = 3'b000;       //D/K.x.0
        4'b1001 :
          if (!k28)
            q8[7:5] = 3'b001;             //D/K.x.1
          else
            q8[7:5] = 3'b110;             //K28.6

        4'b0110 :
          if (k28)
            q8[7:5] = 3'b001;             //K.28.1
          else
            q8[7:5] = 3'b110;             //D/K.x.6
        4'b1010 :
          if (!k28)
            q8[7:5] = 3'b010;             //D/K.x.2
          else
            q8[7:5] = 3'b101;             //K28.5
        4'b0101 :
          if (k28)
            q8[7:5] = 3'b010;             //K28.2
          else
            q8[7:5] = 3'b101;             //D/K.x.5
        4'b0011 : q8[7:5] = 3'b011;       //D/K.x.3
        4'b1100 : q8[7:5] = 3'b011;       //D/K.x.3
        4'b0100 : q8[7:5] = 3'b100;       //D/K.x.4
        4'b1011 : q8[7:5] = 3'b100;       //D/K.x.4
        4'b0111 : q8[7:5] = 3'b111;       //D.x.7
        4'b1000 : q8[7:5] = 3'b111;       //D.x.7
        4'b1110 : q8[7:5] = 3'b111;       //D/K.x.7
        4'b0001 : q8[7:5] = 3'b111;       //D/K.x.7
        default : q8[7:5] = 3'b111;       //CODE VIOLATION - return /E/
      endcase

      is_k = ((d10[2] & d10[3] & d10[4] & d10[5])
           | ~(d10[2] | d10[3] | d10[4] | d10[5])
           | ((d10[4] ^ d10[5]) & ((d10[5] & d10[7] & d10[8] & d10[9])
           | ~(d10[5] | d10[7] | d10[8] | d10[9]))));

    end
  endtask // decode_8b10b

  function is_comma;
    input [0:9] codegroup;
    begin
      case (codegroup[0:6])
        7'b0011111 : is_comma = 1;
        7'b1100000 : is_comma = 1;
        default : is_comma = 0;
      endcase // case(codegroup[0:6])
    end
  endfunction // is_comma

  function is_ila;
    input [0:9] codegroup;
    begin
      case (codegroup[0:9])
        10'b0011110100 : is_ila = 1;
        10'b1100001011 : is_ila = 1;
        default : is_ila = 0;
      endcase // case(codegroup[0:9])
    end
  endfunction // is_ila

  // AXI-Lite Write task
  task axi_write;
    input [29:0] offset;
    input [31:0] data;
    reg   [31:0] addr;
    reg    [1:0] resp;
    begin
      // shift offset to account for AXI byte addressing
      addr = {offset, 2'b00};
      // Drive Address & Data valid
      @(posedge s_axi_aclk);
      #1000;
      s_axi_awaddr  = addr;
      s_axi_awvalid = 1;
      s_axi_wdata   = data;
      s_axi_wvalid  = 1;
      s_axi_bready  = 0;
      // Address Response Phase
      @(negedge s_axi_aclk);
      while (s_axi_awready == 1'b0)
        @(negedge s_axi_aclk);
      @(posedge s_axi_aclk);
      #1000;
      s_axi_awaddr  = 0;
      s_axi_awvalid = 0;
      // Data Response Phase
      @(negedge s_axi_aclk);
      while (s_axi_wready == 1'b0)
        @(negedge s_axi_aclk);
      @(posedge s_axi_aclk);
      #1000;
      s_axi_wdata   = 0;
      s_axi_wvalid  = 0;
      // BRESP phase
      @(negedge s_axi_aclk);
      while (s_axi_bvalid == 1'b0)
        @(negedge s_axi_aclk);
      @(posedge s_axi_aclk);
      resp = s_axi_bresp;
      if (resp != 0) $display ("Error AXI BRESP not equal 0");
      #1000;
      s_axi_bready = 1;
      @(posedge s_axi_aclk);
      #1000;
      s_axi_bready = 0;
    end
  endtask // axi_write

  // AXI-Lite Read task
  task axi_read;
    input  [29:0] offset;
    output [31:0] data;
    reg    [31:0] addr;
    reg     [1:0] resp;
    begin
      // shift offset to account for AXI byte addressing
      addr = {offset, 2'b00};
      // Drive Address valid
      @(posedge s_axi_aclk);
      #1000;
      s_axi_araddr  = addr;
      s_axi_arvalid = 1;
      s_axi_rready  = 0;
      // Address Response Phase
      @(negedge s_axi_aclk);
      while (s_axi_arready == 1'b0)
        @(negedge s_axi_aclk);
      @(posedge s_axi_aclk);
      #1000;
      s_axi_araddr  = 0;
      s_axi_arvalid = 0;
      s_axi_rready  = 1;
      // Read Data Phase
      @(negedge s_axi_aclk);
      while (s_axi_rvalid == 1'b0)
        @(negedge s_axi_aclk);
      @(posedge s_axi_aclk);
      data = s_axi_rdata;
      resp = s_axi_rresp;
      if (resp != 0) $display ("Error AXI RRESP not equal 0");
      #1000;
      s_axi_rready  = 0;
    end
  endtask // axi_read


  // The following code monitors each lane and detects initial sync. It then aligns the lanes
  // before outputting data.
  initial
  begin : p_decode_tx
    reg [0:9] code_buffer        [pLanes-1:0];
    reg [7:0] decoded_data       [pLanes-1:0];
    reg [7:0] data_align_buf     [pLanes-1:0][pAlign_buf_size-1:0];
    reg       is_k_var_align_buf [pLanes-1:0][pAlign_buf_size-1:0];
    reg       is_k_var           [pLanes-1:0];
    reg       initial_sync       [pLanes-1:0];
    integer   bit_count          [pLanes-1:0];
    integer   comma_count        [pLanes-1:0];
    integer   align_count        [pLanes-1:0];
    reg       ila_sync           [pLanes-1:0];
    reg       bc_ok_i            [pLanes-1:0];
    reg       ila_seen           [pLanes-1:0];

    integer   I, J, K;

    all_lanes_synced = 0;

    for ( I = 0; I < pLanes; I = I + 1 )
    begin
      initial_sync[I] = 1'b0;
      bit_count[I]    = 0;
      comma_count[I]  = 0;
      align_count[I]  = 0;
      ila_seen[I]     = 1'b0;
    end // for loop

    forever
    begin
      @(posedge tx_bitclock);

      for ( I = 0; I < pLanes; I = I + 1 )
      begin
        code_buffer[I] = {code_buffer[I][1:9], txp[I]};
        // comma detection
        if (is_comma(code_buffer[I][0:9]))
        begin
          if ((comma_count[I] < 20) || (axiReset_done == 1'b0))
          begin
            comma_count[I] = comma_count[I] + 1;
            initial_sync[I] = 1'b0;
            bc_ok_i[I] = 1'b0;
          end
          else
          begin
            initial_sync[I] = 1;
            bc_ok_i[I] = 1'b1;    //BC seen
          end
          if (!initial_sync[I])
            bit_count[I] = 0;
        end
        if (bit_count[I] == 0 && initial_sync[I])
        begin
          decode_8b10b(
            code_buffer[I][0:9],
            decoded_data[I][7:0],
            is_k_var[I]);
        end

        if (initial_sync[I])
        begin
          bit_count[I] = bit_count[I] + 1;
          if (bit_count[I] == 10)
            bit_count[I] = 0;
        end

        //Waiting for ILAs
        if (ila_seen[I] == 1'b0)
        begin
          if (is_ila(code_buffer[I][0:9]))
          begin
            ila_sync[I] = 1'b1;
            ila_seen[I] = 1'b1;
          end
          else if (axiReset_done == 1'b0)
          begin
            ila_sync[I] = 1'b0;
            ila_seen[I] = 1'b0;
          end
          else
            ila_sync[I] = 1'b0;
        end

        if (ila_sync[I] !== 1'b1)
        begin
          align_count[I]  = 0;
        end
        else if (all_lanes_synced !== 1'b1)
        begin
          //increment the alignment counter
          align_count[I] = align_count[I] + 1;
        end
        else
        begin
          //All lanes have synced
          //So now do a bitwise assignment to the output data word
          for ( J = 0; J < 8; J = J + 1 )
            tx_decoded_data[(I*8)+J] = data_align_buf[I][align_count[I]][J];
          tx_decoded_is_k[I] = is_k_var_align_buf[I][align_count[I]];
        end

        //Buffer data and is_k into alignment shift register
        is_k_var_align_buf[I][0] <= is_k_var[I];
        //must do a bitwise copy
        for ( J = 0; J < 8; J = J + 1 )
          data_align_buf[I][0][J] <= decoded_data[I][J];

        for ( J = 1; J < pAlign_buf_size; J = J + 1 )
        begin
          is_k_var_align_buf[I][J] <= is_k_var_align_buf[I][J-1];
          //must do a bitwise copy
          for ( K = 0; K < 8; K = K + 1 )
            data_align_buf[I][J][K] <= data_align_buf[I][J-1][K];
        end
      end // for loop end

      //This will notify that BCs have been on all lanes
      //and can now assert SYNC
      bc_ok = 1'b1;
      for ( I = 0; I < pLanes; I = I + 1 )
      begin
        if (bc_ok_i[I] !== 1'b1)
          bc_ok = 1'b0;
      end

      //Check if all lanes are synced yet
      all_lanes_synced = 1'b1;
      for ( I = 0; I < pLanes; I = I + 1 )
      begin
        if (ila_sync[I] !== 1'b1)
          all_lanes_synced = 1'b0;
      end // for loop end
    end // forever begin
  end // initial

  // This is the main transmitter stimulus task
  initial
    begin : p_tx_stimulus
      reg [5:0]  pointer;
      reg [1:0]  counter;
      reg [1:0]  control [pLanes-1:0];
      reg [13:0] sample [pLanes-1:0];
      reg [15:0] frame [pLanes-1:0];
      integer I, J, K, L;

      tx_sync = 0;

      while ( axiReset_done !== 1'b1 ) //Wait for AXI to complete configuration set-up
        @(posedge tx_aclk);

      $display("** GT Reset Done");

      #100000;

      $display("** Wait for K28.5");
      while (bc_ok !== 1'b1)
        @(posedge tx_bitclock);

      #100000;
      $display("** Assert Sync");
      tx_sync = 1'h1;

      while ((tx_decoded_data !== {pLanes{8'h1C}}) | (tx_decoded_is_k !== {pLanes{1'b1}}))
        @(posedge tx_bitclock);
      $display("** ILA Start");
      while (tx_decoded_is_k[pLanes-1:0] !== {pLanes{1'b0}})
        @(posedge tx_bitclock);

      while ((tx_decoded_data !== {pLanes{8'h7C}}) | (tx_decoded_is_k !== {pLanes{1'b1}}))
        @(posedge tx_bitclock);
      $display("*** End of Multi Frame 1");
      while (tx_decoded_is_k[pLanes-1:0] !== {pLanes{1'b0}})
        @(posedge tx_bitclock);

      while ((tx_decoded_data !== {pLanes{8'h7C}}) | (tx_decoded_is_k !== {pLanes{1'b1}}))
        @(posedge tx_bitclock);
      $display("*** End of Multi Frame 2");
      while (tx_decoded_is_k[pLanes-1:0] !== {pLanes{1'b0}})
        @(posedge tx_bitclock);

      while ((tx_decoded_data !== {pLanes{8'h7C}}) | (tx_decoded_is_k !== {pLanes{1'b1}}))
        @(posedge tx_bitclock);
      $display("*** End of Multi Frame 3");
      while (tx_decoded_is_k[pLanes-1:0] !== {pLanes{1'b0}})
        @(posedge tx_bitclock);

      while ((tx_decoded_data !== {pLanes{8'h7C}}) | (tx_decoded_is_k !== {pLanes{1'b1}}))
        @(posedge tx_bitclock);
      $display("*** End of Multi Frame 4");
      $display("** ILA Complete");

      while (tx_decoded_is_k[pLanes-1:0] !== {pLanes{1'b0}})
        @(posedge tx_bitclock);

      //Now check that the recieved data matches the expected data
      for (J = 0; J < 1000; J = J + 1 )
      begin
        //Construct frames for each lane
        //Two octets per frame
        for ( L = 0; L < 2; L = L + 1 )
        begin
          @(posedge tx_octet_clock);
          for ( I = 0; I < pLanes; I = I + 1)
          begin
            // Do a bitwise copy of the octet
            for ( K = 0; K < 8; K = K + 1 )
              frame[I][(L*8)+K] = tx_decoded_data[(I*8)+K];
          end
        end

        //test all is as expected
        for ( I = 0; I < pLanes; I = I + 1)
        begin
          pointer = J + (I*2);
          counter = J + (I*2);

          //de map control word and sample from transmitted frame.
          control[I] = frame[I][15:14];
          sample[I]  = frame[I][13:0];

          if ( ( control[I] !== counter ) || ( sample[I] !== sine_lut64_14bit[pointer]) )
          begin
            $display("** Error in Transmitted data.");
            $stop;
          end
        end //for I
      end //for J

      $display("** Test Passed");
      $display("** Test completed successfully");
      $stop;

    end // p_tx_stimulus

  // Program the link configuration registers
  initial
    begin : p_axi_stimulus

      reg [31:0] register_val;

      s_axi_aresetn <= 1;
      reset <= 0;
      #1000;
      // Generate the core reset.
      $display("Resetting the core...");
      reset <= 1;
      s_axi_aresetn <= 0;
      #400000;
      s_axi_aresetn <= 1;
      reset <= 0;

      // 0x000: Read Version
      axi_read(0,register_val);
      $display("Version = Major %d Minor %d Rev %d", register_val[31:24],  register_val[23:16],  register_val[15:8]);

      // 0x004: Reset later once configured

      // 0x008: Support ILA
      axi_write(2,32'h00000001);

      // 0x00C: Scrambling dissabled
      axi_write(3,32'h00000000);

      // 0x010: Sysref once
      axi_write(4,32'h00000001);

      // 0x014: Multiframes in ILA = 4
      axi_write(5,32'h00000003);

      // 0x018: Test mode = Normal operation
      axi_write(6,32'h00000000);

      // 0x020: Octets per Frame F=2
      axi_write(8,32'h00000001);

      // 0x024: Frames per Multiframe K=32
      axi_write(9,32'h0000001F);

      // 0x028: Lanes in use
      axi_write(10,32'd255);

      // 0x02C: Device subclass 1
      axi_write(11,32'h00000001);

      // 0x030: Rx only register

      // 0x034: Rx only register

      // 0x80C: L, DID, BID
      axi_write(515,{3'b0, pL, 12'b0, pBID, pDID} );

      // 0x810: CS, N', N, M
      axi_write(516,{6'b0, pCS, 3'b0, pNt, 3'b0, pN, pM} );

      // 0x814: CF, HD, S, SCR
      axi_write(517,{3'b0, pCF, 7'b0, pHD, 3'b0, pS, 7'b0, pSCR} );

      // 0x818: RES1, RES2 checksum generated automatically
      axi_write(518,{16'b0, pRES2, pRES1});

      // Link configuration has changed so reset the interface
      // 0x04: Write reset
      axi_write(1,32'h00000001);
      // Now poll register until reset has cleared
      register_val = 32'h00000001;
      while ( register_val[0] !== 32'b0 )
      begin
        #1000    //wait for a time then read
        axi_read(1,register_val);
      end
      $display("AXI Configuration and Reset complete....");

      axiReset_done = 1'b1;  //Signal to notify that AXI has been configured

    end // p_axi_stimulus

  // Check for runaway simulation
  initial
  begin : p_sim_timeout
    simtimeout_count = pSimtimeout_count;
    while( simtimeout_count > 0 )
    begin
      #(simtimeout);
      simtimeout_count = simtimeout_count - 1;
    end
    $display("** SIMULATION TIMEOUT");
    $stop;
  end // p_sim_timeout

endmodule //testbench
