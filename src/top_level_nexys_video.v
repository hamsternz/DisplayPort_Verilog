///////////////////////////////////////////////////////////////////////////////
// ./src/top_level_nexys_video.v : 
//
// Author: Mike Field <hamster@snap.net.nz>
//
// Part of the DisplayPort_Verlog project - an open implementation of the 
// DisplayPort protocol for FPGA boards. 
//
// See https://github.com/hamsternz/DisplayPort_Verilog for latest versions.
//
///////////////////////////////////////////////////////////////////////////////
// Version |  Notes
// ----------------------------------------------------------------------------
//   1.0   | Initial Release
//
///////////////////////////////////////////////////////////////////////////////
//
// MIT License
// 
// Copyright (c) 2019 Mike Field
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
///////////////////////////////////////////////////////////////////////////////
//
// Want to say thanks?
//
// This design has taken many hours - 3 months of work for the initial VHDL
// design, and another month or so to convert it to Verilog for this release.
//
// I'm more than happy to share it if you can make use of it. It is released
// under the MIT license, so you are not under any onus to say thanks, but....
//
// If you what to say thanks for this design either drop me an email, or how about
// trying PayPal to my email (hamster@snap.net.nz)?
//
//  Educational use - Enough for a beer
//  Hobbyist use    - Enough for a pizza
//  Research use    - Enough to take the family out to dinner
//  Commercial use  - A weeks pay for an engineer (I wish!)
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module top_level_nexys_video(
    input clk100,
    //////////////////////////////////////////
    output [1:0] dp_tx_lane_p,
    output [1:0] dp_tx_lane_n,
    //////////////////////////////////////////
    input  dp_refclk_p,
    input  dp_refclk_n,
    input  mgtrefclk1_p,
    input  mgtrefclk1_n,
    //////////////////////////////////////////
    input  dp_tx_hp_detect,
    inout  dp_tx_auxch_tx_p,
    inout  dp_tx_auxch_tx_n,
    inout  dp_tx_auxch_rx_p,
    inout  dp_tx_auxch_rx_n,
    ///////////////////////////////////////////
    output [7:0] debug,
    input  [3:0] sw,
//    output [7:0] seg_segs,
//    output [2:0] seg_en,
    output [7:0] LED
    );

reg [37:0] counter;
    
always @(posedge clk100) begin
    counter <= counter + 1;
  end

wire      refclk0, odiv2_0;
wire      refclk1, odiv2_1;

wire [3:0] tx_powerup_channel;

wire       preemp_0p0;
wire       preemp_3p5;
wire       preemp_6p0;

wire       swing_0p4;
wire       swing_0p6;
wire       swing_0p8;

wire  [3:0] tx_running;

wire        tx_symbol_clk;
wire [79:0] tx_symbols;
wire  [7:0] debug_cm;

wire        tx_align_train;       
wire        tx_clock_train;       
wire        tx_link_established;

wire  [2:0] stream_channel_count;
wire  [2:0] source_channel_count = 3'b010;
wire [72:0] msa_merged_data;
wire        test_signal_ready;

wire auxch_in;
wire auxch_out;
wire auxch_tri;


assign debug = debug_cm;

///////////////////////////////////////////////////
// Debug infrastructure
///////////////////////////////////////////////////
wire [7:0] seg_segs;
wire [2:0] seg_en;
seven_segment_driver ssd(
        .clk            (clk100),
        .value          (counter[37:26]),
        .segments       (seg_segs),
        .segment_enable (seg_en)
    );

///////////////////////////////////////////////////
// Refclock buffers
///////////////////////////////////////////////////
IBUFDS_GTE2  ibufds_gte2_0 ( 
        .O               (refclk0),
        .ODIV2           (odiv2_0),      
        .CEB             (1'b0),
        .I               (dp_refclk_p),
        .IB              (dp_refclk_n)
    );

IBUFDS_GTE2  ibufds_gte2_1 ( 
        .O               (refclk1),
        .ODIV2           (odiv2_1),
        .CEB             (1'b0),
        .I               (mgtrefclk1_p),
        .IB              (mgtrefclk1_n)
    );
///////////////////////////////////////////////////
// Aux channel interface 
///////////////////////////////////////////////////
wire auxch_in_ignore = 1'b0;
IOBUFDS #(
          .DIFF_TERM("TRUE"),     // Differential Termination ("TRUE"/"FALSE")
          .IBUF_LOW_PWR("TRUE"),   // Low Power - "TRUE", High Performance = "FALSE" 
          .IOSTANDARD("DEFAULT"), // Specify the I/O standard
          .SLEW("SLOW")            // Specify the output slew rate
       ) i_IOBUFDS_1 (
          .O   (auxch_in),         // Buffer output
          .IO  (dp_tx_auxch_rx_p),   // Diff_p inout (connect directly to top-level port)
          .IOB (dp_tx_auxch_rx_n),  // Diff_n inout (connect directly to top-level port)
          .I   (auxch_in_ignore),    // Buffer input
          .T   (1'b1)        // 3-state enableie input, high=input, low=output
      );

wire auxch_out_ignore;
IOBUFDS #(
          .DIFF_TERM("FALSE"),     // Differential Termination ("TRUE"/"FALSE")
          .IBUF_LOW_PWR("TRUE"),   // Low Power - "TRUE", High Performance = "FALSE" 
          .IOSTANDARD("DEFAULT"), // Specify the I/O standard
          .SLEW("SLOW")            // Specify the output slew rate
       ) i_IOBUFDS_2 (
          .O   (auxch_out_ignore),         // Buffer output
          .IO  (dp_tx_auxch_tx_p),  // Diff_p inout (connect directly to top-level port)
          .IOB (dp_tx_auxch_tx_n),  // Diff_n inout (connect directly to top-level port)
          .I   (auxch_out),              // Buffer input
          .T   (auxch_tri)               // 3-state enable input, high=input, low=output
      );
///////////////////////////////////////////////////
// Video pipeline
///////////////////////////////////////////////////
test_source i_test_source(
        .clk                  (tx_symbol_clk),
        .stream_channel_count (stream_channel_count),
        .ready                (test_signal_ready),
        .data                 (msa_merged_data)
    );
main_stream_processing i_main_stream_processing(
        .symbol_clk          (tx_symbol_clk),
        .tx_link_established (tx_link_established),
        .source_ready        (test_signal_ready),
        .tx_clock_train      (tx_clock_train),
        .tx_align_train      (tx_align_train),
        .in_data             (msa_merged_data),
        .tx_symbols          (tx_symbols)
    );

////////////////////////////////////////////////
// Transceivers 
///////////////////////////////////////////////
transceiver_bank i_transciever_bank(
    .mgmt_clk        (clk100),

    ///////////////////////////////
    // Master control
    ///////////////////////////////
    .powerup_channel (tx_powerup_channel[1:0]),
 
    ///////////////////////////////
    // Output signal control
    ///////////////////////////////
    .preemp_0p0      (preemp_0p0),
    .preemp_3p5      (preemp_3p5),
    .preemp_6p0      (preemp_6p0),
           
    .swing_0p4       (swing_0p4),
    .swing_0p6       (swing_0p6),
    .swing_0p8       (swing_0p8),

    ///////////////////////////////
    // Status feedback
    ///////////////////////////////
    .tx_running      (tx_running[1:0]),

    ///////////////////////////////
    // Reference clocks
    ///////////////////////////////
    .refclk0       (refclk0),
    .refclk1       (refclk1),

    ///////////////////////////////
    // Symbols to transmit
    ///////////////////////////////
    .tx_symbol_clk   (tx_symbol_clk),
    .tx_symbols      (tx_symbols),

    .gtptx_p         (dp_tx_lane_p),
    .gtptx_n         (dp_tx_lane_n)
);

channel_management i_channel_management(
        .clk100               (clk100),
        .debug                (debug_cm),
        .hpd                  (dp_tx_hp_detect),
        .auxch_in             (auxch_in),
        .auxch_out            (auxch_out),
        .auxch_tri            (auxch_tri),
        .stream_channel_count (stream_channel_count),
        .source_channel_count (source_channel_count),
        .tx_clock_train       (tx_clock_train),
        .tx_align_train       (tx_align_train),
        .tx_powerup_channel   (tx_powerup_channel),
        .tx_preemp_0p0        (preemp_0p0),
        .tx_preemp_3p5        (preemp_3p5),
        .tx_preemp_6p0        (preemp_6p0),
        .tx_swing_0p4         (swing_0p4),
        .tx_swing_0p6         (swing_0p6),
        .tx_swing_0p8         (swing_0p8),
        .tx_running           (tx_running),
        .tx_link_established  (tx_link_established)
    );
    
    assign LED = {tx_running, tx_powerup_channel};

endmodule