///////////////////////////////////////////////////////////////////////////////
// ./src/test_streams/test_source.v : 
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
//   1.1   | Testing 720p and 1080p
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
module test_source(
    input             clk,
    output      [2:0] stream_channel_count,
    output            ready,
    output reg [72:0] data
);

    wire [23:0] M_value;
    wire [23:0] N_value;
    wire [11:0] H_visible;
    wire [11:0] V_visible;
    wire [11:0] H_total;
    wire [11:0] V_total;
    wire [11:0] H_sync_width;
    wire [11:0] V_sync_width;
    wire [11:0] H_start;
    wire [11:0] V_start;
    wire        H_vsync_active_high;
    wire        V_vsync_active_high;
    wire        flag_sync_clock;
    wire        flag_YCCnRGB;
    wire        flag_422n444;
    wire        flag_YCC_colour_709;
    wire        flag_range_reduced;
    wire        flag_interlaced_even;
    wire  [1:0] flags_3d_Indicators;
    wire  [4:0] bits_per_colour;

    wire [72:0] raw_data;
    wire [72:0] data_ch_1;
    wire [72:0] data_ch_2;
    wire [72:0] data_ch_4;

always @(*) begin
    case(stream_channel_count)
        3'b100:  data <= data_ch_4;
        3'b010:  data <= data_ch_2;
        default: data <= data_ch_1;
    endcase
end

//test_source_800_600_RGB_444_colourbar i_test_source(
//test_source_1080p_RGB_444_gutted i_test_source(
//test_source_720p_RGB_444_colourbar i_test_source(
//test_source_800_600_RGB_444_ch2 i_test_source(
//test_source_1080p_RGB_444_colourbar i_test_source(
//test_source_1080p_RGB_444_colourbar i_test_source(
test_source_3840_2180_YCC_422_ch2 i_test_source(
            .M_value              (M_value),
            .N_value              (N_value),
            
            .H_visible            (H_visible),
            .H_total              (H_total),
            .H_sync_width         (H_sync_width),
            .H_start              (H_start),    
            
            .V_visible            (V_visible),
            .V_total              (V_total),
            .V_sync_width         (V_sync_width),
            .V_start              (V_start),
            .H_vsync_active_high  (H_vsync_active_high),
            .V_vsync_active_high  (V_vsync_active_high),
            .flag_sync_clock      (flag_sync_clock),
            .flag_YCCnRGB         (flag_YCCnRGB),
            .flag_422n444         (flag_422n444),
            .flag_range_reduced   (flag_range_reduced),
            .flag_interlaced_even (flag_interlaced_even),
            .flag_YCC_colour_709  (flag_YCC_colour_709),
            .flags_3d_Indicators  (flags_3d_Indicators),
            .bits_per_colour      (bits_per_colour), 
            .stream_channel_count (stream_channel_count),

            .clk          (clk),
            .ready        (ready),
            .data         (raw_data)
        );

insert_main_stream_attrbutes_one_channel i_insert_main_stream_attrbutes_one_channel(
            .clk                  (clk),
            .active                  (1'b1),
            //////////////////////////////////////////////////////
            // The MSA values (some are range reduced and could 
            // be 16 bits ins size)
            //////////////////////////////////////////////////////     
            .M_value              (M_value),
            .N_value              (N_value),

            .H_visible            (H_visible),
            .H_total              (H_total),
            .H_sync_width         (H_sync_width),
            .H_start              (H_start),    
     
            .V_visible            (V_visible),
            .V_total              (V_total),
            .V_sync_width         (V_sync_width),
            .V_start              (V_start),
            .H_vsync_active_high  (H_vsync_active_high),
            .V_vsync_active_high  (V_vsync_active_high),
            .flag_sync_clock      (flag_sync_clock),
            .flag_YCCnRGB         (flag_YCCnRGB),
            .flag_422n444         (flag_422n444),
            .flag_range_reduced   (flag_range_reduced),
            .flag_interlaced_even (flag_interlaced_even),
            .flag_YCC_colour_709  (flag_YCC_colour_709),
            .flags_3d_Indicators  (flags_3d_Indicators),
            .bits_per_colour      (bits_per_colour), 
            //////////////////////////////////////////////////////
            // The stream of pixel data coming in
            //////////////////////////////////////////////////////
            .in_data              (raw_data),
            //////////////////////////////////////////////////////
            // The stream of pixel data going out
            //////////////////////////////////////////////////////
            .out_data             (data_ch_1)
        );

insert_main_stream_attrbutes_two_channels i_insert_main_stream_attrbutes_two_channels(
            .clk                  (clk),
            .active               (1'b1),
            //////////////////////////////////////////////////////
            // The MSA values (some are range reduced and could 
            // be 16 bits ins size)
            //////////////////////////////////////////////////////     
            .M_value              (M_value),
            .N_value              (N_value),

            .H_visible            (H_visible),
            .H_total              (H_total),
            .H_sync_width         (H_sync_width),
            .H_start              (H_start),    
     
            .V_visible            (V_visible),
            .V_total              (V_total),
            .V_sync_width         (V_sync_width),
            .V_start              (V_start),
            .H_vsync_active_high  (H_vsync_active_high),
            .V_vsync_active_high  (V_vsync_active_high),
            .flag_sync_clock      (flag_sync_clock),
            .flag_YCCnRGB         (flag_YCCnRGB),
            .flag_422n444         (flag_422n444),
            .flag_range_reduced   (flag_range_reduced),
            .flag_interlaced_even (flag_interlaced_even),
            .flag_YCC_colour_709  (flag_YCC_colour_709),
            .flags_3d_Indicators  (flags_3d_Indicators),
            .bits_per_colour      (bits_per_colour), 
            //////////////////////////////////////////////////////
            // The stream of pixel data coming in
            //////////////////////////////////////////////////////
            .in_data              (raw_data),
            //////////////////////////////////////////////////////
            // The stream of pixel data going out
            //////////////////////////////////////////////////////
            .out_data             (data_ch_2)
        );

insert_main_stream_attrbutes_four_channels i_insert_main_stream_attrbutes_four_channels(
            .clk                  (clk),
            .active               (1'b1),
            //////////////////////////////////////////////////////
            // The MSA values (some are range reduced and could 
            // be 16 bits ins size)
            //////////////////////////////////////////////////////     
            .M_value              (M_value),
            .N_value              (N_value),

            .H_visible            (H_visible),
            .H_total              (H_total),
            .H_sync_width         (H_sync_width),
            .H_start              (H_start),    
     
            .V_visible            (V_visible),
            .V_total              (V_total),
            .V_sync_width         (V_sync_width),
            .V_start              (V_start),
            .H_vsync_active_high  (H_vsync_active_high),
            .V_vsync_active_high  (V_vsync_active_high),
            .flag_sync_clock      (flag_sync_clock),
            .flag_YCCnRGB         (flag_YCCnRGB),
            .flag_422n444         (flag_422n444),
            .flag_range_reduced   (flag_range_reduced),
            .flag_interlaced_even (flag_interlaced_even),
            .flag_YCC_colour_709  (flag_YCC_colour_709),
            .flags_3d_Indicators  (flags_3d_Indicators),
            .bits_per_colour      (bits_per_colour), 
            //////////////////////////////////////////////////////
            // The stream of pixel data coming in
            //////////////////////////////////////////////////////
            .in_data              (raw_data),
            //////////////////////////////////////////////////////
            // The stream of pixel data going out
            //////////////////////////////////////////////////////
            .out_data             (data_ch_4)
        );

endmodule
