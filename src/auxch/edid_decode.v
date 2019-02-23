///////////////////////////////////////////////////////////////////////////////
// ./src/auxch/edid_decode.v : 
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

module edid_decode(
          input         clk,

          input         edid_de,
          input  [7:0]  edid_data,
          input  [7:0]  edid_addr,
          input         invalidate,

          output reg        valid,

          output reg        support_RGB444,
          output reg        support_YCC444,
          output reg        support_YCC422,

          output reg [15:0] pixel_clock_x10k,

          output reg [11:0] h_visible_len,
          output reg [11:0] h_blank_len,
          output reg [11:0] h_front_len,
          output reg [11:0] h_sync_len,

          output reg [11:0] v_visible_len,
          output reg [11:0] v_blank_len,
          output reg [11:0] v_front_len,
          output reg [11:0] v_sync_len,
          output reg        interlaced
    );

   reg  [7:0] checksum;
   wire [7:0] checksum_next;
   
   assign checksum_next =  checksum + edid_data;


initial begin
    checksum = 8'b0;
    valid   = 1'b0;

    support_RGB444   = 1'b0;
    support_YCC444   = 1'b0;
    support_YCC422   = 1'b0;

    pixel_clock_x10k = 16'b0;

    h_visible_len   = 12'b0;
    h_blank_len   = 12'b0;
    h_front_len   = 12'b0;
    h_sync_len   = 12'b0;

    v_visible_len   = 12'b0;
    v_blank_len   = 12'b0;
    v_front_len   = 12'b0;
    v_sync_len   = 12'b0;
    interlaced   = 1'b0;
end 

always @(posedge clk) begin
    if(edid_de == 1'b1) begin
        checksum <= checksum_next;
        valid    <= 1'b0;
        case(edid_addr)
            8'h00: begin // reset the checksum
                       checksum <= edid_data;
                   end
            8'h18: begin // Colour modes supported
                          support_RGB444 <= 1'b1;
                          support_YCC444 <= edid_data[3];
                          support_YCC422 <= edid_data[4];
                   end
            // Timing 0 - 1    
            8'h36: begin
                       pixel_clock_x10k[7:0] <= edid_data;
                   end
            8'h37: begin
                        pixel_clock_x10k[15:8] <= edid_data;
                   end
                
            // Timing 2 - 4    
            8'h38: begin
                       h_visible_len[7:0] <= edid_data;
                   end
            8'h39: begin
                       h_blank_len[7:0]    <= edid_data;
                   end
            8'h3a: begin
                       h_visible_len[11:8] <= edid_data[7:4];
                       h_blank_len[11:8]   <= edid_data[3:0];
                   end

            // Timing 5 - 7    
            8'h3B: begin
                       v_visible_len[7:0] <= edid_data;
                   end
            8'h3C: begin
                       v_blank_len[7:0]    <= edid_data;
                   end
            8'h3D: begin
                       v_visible_len[11:8] <= edid_data[7:4];
                       v_blank_len[11:8]   <= edid_data[3:0];
                   end
            // Timing 8 - 11
            8'h3E: begin
                       h_front_len[ 7:0]   <= edid_data;
                   end
            8'h3F: begin
                       h_sync_len[  7:0]   <= edid_data;
                   end
            8'h40: begin
                       v_front_len[ 3:0]   <= edid_data[7:4];
                       v_sync_len[  3:0]   <= edid_data[3:0];
                   end
            8'h41: begin
                       h_front_len[ 9:8]   <= edid_data[7:6];
                       h_sync_len[  9:8]   <= edid_data[5:4];
                       v_front_len[ 5:4]   <= edid_data[3:2];
                       v_sync_len[  5:4]   <= edid_data[1:0];
                   end
            // Timing 11-16 not used - that is the physical 
            // size and boarder.
            8'h7F: begin
                       if(checksum_next == 8'h00) begin
                             valid <= 1'b1;
                       end
                   end
        endcase

        //----------------------------------------------
        // Allow for an external event to invalidate the 
        // outputs (e.g. hot plug)
        //----------------------------------------------
        if(invalidate == 1'b1) begin
           valid <= 1'b0;
        end
    end
end
endmodule
