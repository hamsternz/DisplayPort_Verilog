///////////////////////////////////////////////////////////////////////////////
// ./test_benches/tb_dummy_sink.v : 
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

//////////////////////////////////////////////////////
// tb_dummy_sink.v 
//
// This module pretends to be a DisplayPort sink, by
// answering the configuration requests at the correct
// time. It isn't smart, so if you change the AUXCH 
// channel management FSM you WILL need to come here
// and revise this if you want to simulate the link
// negotionation and standing up process.
//////////////////////////////////////////////////////

module tb_dummy_sink(
    input clk100,
    output auxch_data,
    output reg   hotplug_detect
    );

wire [7:0] sender_debug_pmod;
wire       sender_aux_tri;
 
reg        sender_wr_en;
reg [7:0]  sender_wr_data;
wire       sender_wr_full;
       //----------------------------                                  
reg        sender_rd_en;
wire [7:0] sender_rd_data;
wire       sender_rd_empty;
wire       sender_busy;
wire       sender_timeout;
reg        sender_abort;

aux_interface sender(
       .clk         (clk100),
       .debug_pmod  (sender_debug_pmod),
       //----------------------------
       .aux_in      (1'b1),
       .aux_out     (auxch_data),
       .aux_tri     (sender_aux_tri),
       //----------------------------
       .tx_wr_en    (sender_wr_en),
       .tx_data     (sender_wr_data),
       .tx_full     (sender_wr_full),
       //----------------------------                                  
       .rx_rd_en    (sender_rd_en),
       .rx_data     (sender_rd_data),
       .rx_empty    (sender_rd_empty),
       //----------------------------
       .busy        (sender_busy),
       .abort       (sender_abort),
       .timeout     (sender_timeout)
     );

initial begin
    hotplug_detect  = 1'b0;
    sender_wr_en    = 1'b0;
    sender_wr_data  = 8'h00;
    sender_rd_en    = 1'b0;
    sender_abort    = 1'b0;
    sender_rd_en = 1'b0;
    sender_wr_en = 1'b0;
    sender_abort = 1'b0;
    
    #1000
    hotplug_detect = 1'b1;
    
    #200000
    
    /////////////////////////////////////////////////////
    //  Reply to the read command
    //////////////////////////////////////////////////////
    sender_wr_data   = 8'h00;
    sender_wr_en  = 1'b1;
    #10
    sender_wr_en  = 1'b0;

    #300000

    /////////////////////////////////////////////////////
    //  EDID Bloack 0
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10
    sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hFF; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hFF; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hFF; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hFF; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hFF; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hFF; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h5A; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h63; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h2F; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hCE; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h01; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h01; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h01; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h01; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #300000

    /////////////////////////////////////////////////////
    //  EDID Bloack 1
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10
    sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h29; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h18; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h01; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h04; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hB5; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h3E; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h22; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h78; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h3A; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h08; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hA5; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hA2; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h57; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h4F; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hA2; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h28; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #300000

    /////////////////////////////////////////////////////
    //  EDID Bloack 2
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10
    sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h0F; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h50; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h54; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hA5; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h4B; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h71; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h4F; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h81; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h81; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h80; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hA9; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h40; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hB3; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #300000

    /////////////////////////////////////////////////////
    //  EDID Bloack 3
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10
    sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hD1; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hC0; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hD1; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h01; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h01; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hA3; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h66; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hA0; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hF0; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h70; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h1f; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h80; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h30; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h20; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #300000

    /////////////////////////////////////////////////////
    //  EDID Bloack 4
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10
    sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h35; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h6D; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h55; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h21; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h1A; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hFF; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h55; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h32; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h4E; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;


    #300000

    /////////////////////////////////////////////////////
    //  EDID Bloack 5
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10
    sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h31; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h34; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h34; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h31; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h30; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h30; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h30; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h38; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h38; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h0A; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hFC; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h56; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;


    #300000

    /////////////////////////////////////////////////////
    //  EDID Bloack 6
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10
    sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h58; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h32; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h38; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h38; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h30; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h4D; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h4C; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h0A; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h20; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h20; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h20; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h20; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hFD; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;


    #300000

    /////////////////////////////////////////////////////
    //  EDID Bloack 7
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10
    sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h18; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h55; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h1F; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h72; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h1E; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h0A; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h20; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h20; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h20; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h20; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h20; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h20; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h01; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h42; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #300000

    /////////////////////////////////////////////////////
    //  REPLY to READ SINK COUNT 90 02 00 00 00 01  
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h01; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #200000


    /////////////////////////////////////////////////////
    //  REPLY to READ CONFIG registers 
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h11; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h0A; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'hA4; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h01; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h01; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h01; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h81; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #200000

    /////////////////////////////////////////////////////
    // Reply to SET 8b/10b CODING
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #200000

    /////////////////////////////////////////////////////
    // Reply to SET LINK BANDWIDTH 
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #200000

    /////////////////////////////////////////////////////
    // Reply to SET DOWNSPREAD
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #200000

    /////////////////////////////////////////////////////
    // Reply to SET LANE COUNT
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #200000

    /////////////////////////////////////////////////////
    // Reply to SET TRAINING PATTERN
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #200000

    /////////////////////////////////////////////////////
    // Reply to SET VOLTAGE  ( request retry)!
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h20; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #200000

    /////////////////////////////////////////////////////
    // Reply to SET VOLTAGE 
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #200000

    /////////////////////////////////////////////////////
    // Reply to READ LINK STATUS (7 registers)
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h01; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h80; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #200000

    /////////////////////////////////////////////////////
    // Reply to READ LINK ADJUST REQUST (2 regs)
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #300000

    /////////////////////////////////////////////////////
    // Reply to SET TRAINING PATTERN
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort  = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #200000

    /////////////////////////////////////////////////////
    // Reply to SET VOLTAGE 
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #600000

    /////////////////////////////////////////////////////
    // Reply to READ LINK STATUS (7 registers)
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h07; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h81; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #200000

    /////////////////////////////////////////////////////
    // Reply to READ LINK ADJUST REQUST (2 regs)
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #400000

    /////////////////////////////////////////////////////
    // Reply to SET TRAINING PATTERN OFF
    //////////////////////////////////////////////////////
    sender_abort = 1'b1;
    #10 sender_abort  = 1'b0;
    #10 sender_wr_data   = 8'h00; sender_wr_en  = 1'b1;
    #10 sender_wr_en  = 1'b0;

    #200000

    /////////////////////////////////////////////////////
    //  All done!
    ///////////////////////////////////////////////////
    sender_wr_en  = 1'b0;

    #200000000
    sender_wr_en  = 1'b0;

end     

endmodule
