///////////////////////////////////////////////////////////////////////////////
// ./test_benches/tb_hotplug_detect.v : 
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
// Rather than testing in isolation, this tests the hotplug detection
// and the IRQ signalling as part of the channel management component

module tb_hotplug_detect;

    reg        clk100;
    wire [7:0] debug;

    reg        hpd;
    reg        auxch_in;
    wire       auxch_out;
    wire       auxch_tri;

        // Datapath requirements
    reg  [2:0] stream_channel_count;
    reg  [2:0] source_channel_count;

        // Datapath control
    wire       tx_clock_train;
    wire       tx_align_train;

        // Transceiver management
    wire [3:0] tx_powerup_channel;

    wire       tx_preemp_0p0;
    wire       tx_preemp_3p5;
    wire       tx_preemp_6p0;
           
    wire       tx_swing_0p4;
    wire       tx_swing_0p6;
    wire       tx_swing_0p8;
          
    reg  [3:0] tx_running;
    wire       tx_link_established;

    reg  [19:0] count;
initial begin
    clk100               = 1'b0;
    hpd                  = 1'b0;
    auxch_in             = 1'b0;
        // Datapath requirements
    stream_channel_count = 3'b001;
    source_channel_count = 3'b001;
    tx_running           = 4'b0000;
    count                = 16'b0;
end

initial begin
    forever begin
        if(count == 100) begin
            hpd = 1'b1;
        end
        if(count == 250000) begin   // IRQ PULSE
            hpd = 1'b0;
        end
        if(count == 400000) begin
            hpd = 1'b1;
        end
        if(count == 750000) begin
            hpd = 1'b0;
        end
        #5 
        clk100 = ~clk100; // generate a clock
        #5 
        clk100 = ~clk100; // generate a clock
        count = count +1;
    end     
end     


channel_management i_channel_management(
        .clk100               (clk100),
        .debug                (debug),

        .hpd                  (hpd),
        .auxch_in             (auxch_in),
        .auxch_out            (auxch_out),
        .auxch_tri            (auxch_tri),

        // Datapath requirements
        .stream_channel_count (stream_channel_count),
        .source_channel_count (source_channel_count),

        // Datapath control
        .tx_clock_train       (tx_clock_train),
        .tx_align_train       (tx_align_train),

        // Transceiver management
        .tx_powerup_channel   (tx_powerup_channel),

        .tx_preemp_0p0        (tx_preemp_0p0),
        .tx_preemp_3p5        (tx_preemp_3p5),
        .tx_preemp_6p0        (tx_preemp_6p0),
           
        .tx_swing_0p4         (tx_swing_0p4),
        .tx_swing_0p6         (tx_swing_0p6),
        .tx_swing_0p8         (tx_swing_0p8),
 
        .tx_running           (tx_running),
        .tx_link_established  (tx_link_established)
);

endmodule
