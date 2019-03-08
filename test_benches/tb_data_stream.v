///////////////////////////////////////////////////////////////////////////////
// ./test_benches/tb_data_stream.v : 
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

module tb_data_stream;

reg        tx_symbol_clk;
reg        tx_align_train;       
reg        tx_clock_train;       
reg        tx_link_established;
reg f;

wire [72:0] msa_merged_data;
wire        test_signal_ready;
wire  [2:0] stream_channel_count;

initial begin
  tx_symbol_clk       = 1'b0;
  tx_align_train      = 1'b0;
  tx_clock_train      = 1'b0;
  tx_link_established = 1'b1;
end

always begin
  #4    // Should be 135MHz, but 125 is close enough for simulation
  tx_symbol_clk = ~tx_symbol_clk;
  #4    // Should be 135MHz, but 125 is close enough for simulation
  tx_symbol_clk = ~tx_symbol_clk;
  $display("%b %b", 
         msa_merged_data[8:0],  msa_merged_data[26:18]
  );

  $display("%b %b", 
         msa_merged_data[17:9], msa_merged_data[35:27]
  );
end

///////////////////////////////////////////////////
// Video pipeline
/////////////////////////////////////////%/////////
test_source i_test_source(
        .clk                  (tx_symbol_clk),
        .stream_channel_count (stream_channel_count),
        .ready                (test_signal_ready),
        .data                 (msa_merged_data)
    );

wire [79:0] tx_symbols;
main_stream_processing i_main_stream_processing(
        .symbol_clk          (tx_symbol_clk),
        .tx_link_established (tx_link_established),
        .source_ready        (test_signal_ready),
        .tx_clock_train      (tx_clock_train),
        .tx_align_train      (tx_align_train),
        .in_data             (msa_merged_data),
        .tx_symbols          (tx_symbols)
    );

endmodule
