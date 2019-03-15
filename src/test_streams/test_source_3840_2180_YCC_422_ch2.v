///////////////////////////////////////////////////////////////////////////////
// test_source_3840_2180_YCC_422_ch2.v : 
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
module test_source_3840_2180_YCC_422_ch2(
        output reg [23:0] M_value,
        output reg [23:0] N_value,
        output reg [11:0] H_visible,
        output reg [11:0] V_visible,
        output reg [11:0] H_total,
        output reg [11:0] V_total,
        output reg [11:0] H_sync_width,
        output reg [11:0] V_sync_width,
        output reg [11:0] H_start,
        output reg [11:0] V_start,
        output reg        H_vsync_active_high,
        output reg        V_vsync_active_high,
        output reg        flag_sync_clock,
        output reg        flag_YCCnRGB,
        output reg        flag_422n444,
        output reg        flag_YCC_colour_709,
        output reg        flag_range_reduced,
        output reg        flag_interlaced_even,
        output reg  [1:0] flags_3d_Indicators,
        output reg  [4:0] bits_per_colour,
        output reg  [2:0] stream_channel_count,

        input             clk,
        output reg        ready,
        output     [72:0] data
    );
    
    localparam [8:0] DUMMY  = 9'b000000011;  // 0x03
    localparam [8:0] SPARE  = 9'b011111111;  // 0xFF
    localparam [8:0] ZERO   = 9'b000000000;  // 0x00
    localparam [8:0] PIX_80 = 9'b011001100;  // 0x80

    localparam [8:0] SS     = 9'b101011100;  // K28.2
    localparam [8:0] SE     = 9'b111111101;  // K29.7
    localparam [8:0] BE     = 9'b111111011;  // K27.7
    localparam [8:0] BS     = 9'b110111100;  // K28.5
    localparam [8:0] SR     = 9'b100011100;  // K28.0
    localparam [8:0] FS     = 9'b111111110;  // K30.7
    localparam [8:0] FE     = 9'b111110111;  // K23.7

    localparam [8:0] VB_VS  = 9'b000000001;  // 0x00  VB-ID with Vertical blank asserted 
    localparam [8:0] VB_NVS = 9'b000000000;  // 0x00  VB-ID without Vertical blank asserted
    localparam [8:0] MVID   = 9'b001101000;  // 0x68
    localparam [8:0] MAUD   = 9'b000000000;  // 0x00    
    
    reg [7:0] index = 0;
    reg [8:0] d0 = 0;
    reg [8:0] d1 = 0;
    reg [11:0] line_count = 0;
    reg [7:0] row_count = 0;
    reg       switch_point  = 0;

initial begin
    M_value              = 24'h07DA1C;
    N_value              = 24'h080000;

    H_total              = 12'hFC0;
    H_visible            = 12'hF00; 
    H_start              = 12'h0A0;
    H_sync_width         = 12'h030;

    V_total              = 12'h890;
    V_visible            = 12'h870;
    V_sync_width         = 12'h003;
    V_start              = 12'h01A;

    H_vsync_active_high  = 1'b1;
    V_vsync_active_high  = 1'b1;
    flag_sync_clock      = 1'b1;
    flag_YCCnRGB         = 1'b1;  // YCC
    flag_422n444         = 1'b1;  // 422
    flag_range_reduced   = 1'b1;
    flag_interlaced_even = 1'b0;
    flag_YCC_colour_709  = 1'b0;
    flags_3d_Indicators  = 2'b00;
    bits_per_colour      = 5'b01000;

    stream_channel_count = 3'b010; 
    ready                = 1'b1;
end

    assign data[72]             = switch_point;
    assign data[71:36]          = 54'b0;
    assign data[35:27]          = d1;
    assign data[26:18]          = d0; 
    assign data[17:9]           = d1;
    assign data[8:0]            = d0; 

always @(posedge clk) begin
    case(index)  
        8'h00: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h01: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h02: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h03: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h04: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h05: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h06: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h07: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h08: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h09: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h0A: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h0B: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h0C: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h0D: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h0E: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h0F: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h10: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h11: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h12: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h13: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h14: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h15: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h16: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h17: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h18: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h19: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h1A: begin d0 <= DUMMY;  d1 <= DUMMY; end
        8'h1B: begin d0 <= SPARE;  d1 <= SPARE; end
        8'h1C: begin d0 <= SPARE;  d1 <= SPARE; end
        8'h1D: begin d0 <= SPARE;  d1 <= SPARE; end
        8'h1E: begin d0 <= SPARE;  d1 <= SPARE; end
        8'h1F: begin d0 <= SPARE;  d1 <= SPARE; end
    
        // Block 1 - 4 white pixels and padding
        8'h20: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h21: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h22: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h23: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h24: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h25: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h26: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h27: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h28: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h29: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h2A: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h2B: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h2C: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h2D: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h2E: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h2F: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h30: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h31: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h32: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h33: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h34: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h35: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h36: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h37: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h38: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h39: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h3A: begin d0 <= PIX_80; d1 <= FE;     end
        8'h3B: begin d0 <= SPARE;  d1 <= SPARE;  end
        8'h3C: begin d0 <= SPARE;  d1 <= SPARE;  end
        8'h3D: begin d0 <= SPARE;  d1 <= SPARE;  end
        8'h3E: begin d0 <= SPARE;  d1 <= SPARE;  end
        8'h3F: begin d0 <= SPARE;  d1 <= SPARE;  end
    
        // Block 2 - 4 white pixels and padding; d1 <= VB-ID (-vsync); d1 <= Mvid; d1 <= MAud and junk
        8'h40: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h41: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h42: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h43: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h44: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h45: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h46: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h47: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h48: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h49: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h4A: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h4B: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h4C: begin d0 <= BS;     d1 <= VB_NVS; end
        8'h4D: begin d0 <= MVID;   d1 <= MAUD;   end
        8'h4E: begin d0 <= VB_NVS; d1 <= MVID;   end
        8'h4F: begin d0 <= MAUD;   d1 <= DUMMY;  end
        8'h50: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h51: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h52: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h53: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h54: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h55: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h56: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h57: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h58: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h59: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h5A: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h5B: begin d0 <= SPARE;  d1 <= SPARE;  end
        8'h5C: begin d0 <= SPARE;  d1 <= SPARE;  end
        8'h5D: begin d0 <= SPARE;  d1 <= SPARE;  end
        8'h5E: begin d0 <= SPARE;  d1 <= SPARE;  end
        8'h5F: begin d0 <= SPARE;  d1 <= SPARE;  end
    
        // Block 3 - 8 white pixels and padding; d1 <= VB-ID (+vsync); d1 <= Mvid; d1 <= MAud and junk
        8'h60: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h61: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h62: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h63: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h64: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h65: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h66: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h67: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h68: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h69: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h6A: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h6B: begin d0 <= PIX_80; d1 <= PIX_80; end
        8'h6C: begin d0 <= BS;     d1 <= VB_VS;  end
        8'h6D: begin d0 <= MVID;   d1 <= MAUD;   end
        8'h6E: begin d0 <= VB_VS;  d1 <= MVID;   end
        8'h6F: begin d0 <= MAUD;   d1 <= DUMMY;  end
        8'h70: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h71: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h72: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h73: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h74: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h75: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h76: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h77: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h78: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h79: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h7A: begin d0 <= DUMMY;  d1 <= DUMMY;  end
        8'h7B: begin d0 <= SPARE;  d1 <= SPARE;  end
        8'h7C: begin d0 <= SPARE;  d1 <= SPARE;  end
        8'h7D: begin d0 <= SPARE;  d1 <= SPARE;  end
        8'h7E: begin d0 <= SPARE;  d1 <= SPARE;  end
        8'h7F: begin d0 <= SPARE;  d1 <= SPARE;  end
    
        // Block 4 - DUMMY;Blank Start; d1 <= VB-ID (+vsync); d1 <= Mvid; d1 <= MAud and junk
        8'h80: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h81: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h82: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h83: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h84: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h85: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h86: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h87: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h88: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h89: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h8a: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h8b: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h8c: begin d0 <= BS;    d1 <= VB_VS; end
        8'h8d: begin d0 <= MVID;  d1 <= MAUD;  end
        8'h8e: begin d0 <= VB_VS; d1 <= MVID;  end
        8'h8f: begin d0 <= MAUD;  d1 <= DUMMY; end
        8'h90: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h91: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h92: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h93: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h93: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h94: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h95: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h96: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h97: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h98: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h99: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h9A: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'h9B: begin d0 <= SPARE; d1 <= SPARE; end
        8'h9C: begin d0 <= SPARE; d1 <= SPARE; end
        8'h9D: begin d0 <= SPARE; d1 <= SPARE; end
        8'h9E: begin d0 <= SPARE; d1 <= SPARE; end
        8'h9F: begin d0 <= SPARE; d1 <= SPARE; end
    
        // Block 5 - just blank end
        8'hA0: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hA1: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hA2: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hA3: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hA4: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hA5: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hA6: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hA7: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hA8: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hA9: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hAA: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hAB: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hAC: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hAD: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hAE: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hAF: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hB0: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hB1: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hB2: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hB3: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hB4: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hB5: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hB6: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hB7: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hB8: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hB9: begin d0 <= DUMMY; d1 <= DUMMY; end
        8'hBA: begin d0 <= DUMMY; d1 <= BE;    end
        8'hBB: begin d0 <= SPARE; d1 <= SPARE; end
        8'hBC: begin d0 <= SPARE; d1 <= SPARE; end
        8'hBD: begin d0 <= SPARE; d1 <= SPARE; end
        8'hBE: begin d0 <= SPARE; d1 <= SPARE; end
        8'hBF: begin d0 <= SPARE; d1 <= SPARE; end
        
        default: begin d0 <= SPARE; d1 <= SPARE; end
    endcase

         if(index[4:0] == 5'd26) begin 
             index[4:0] <= 5'd0;
             if(row_count == 76) begin
                 row_count <= 8'b0;
                 index[4:0] <= 5'd25;
                 if(line_count == V_total-1)
                 begin
                     line_count <= 12'b0;
                 end else begin
                     line_count <= line_count + 1;
                 end
             end else begin
                 row_count <= row_count +1;
             end

    // Block 0 - Junk
    // Block 1- 8 white pixels and padding
    // Block 2 - 8 white pixels and padding, VB-ID (-vsync), Mvid, MAud and junk
    // Block 3 - 8 white pixels and padding, VB-ID (+vsync), Mvid, MAud and junk
    // Block 4 - DUMMY,Blank Start, VB-ID (+vsync), Mvid, MAud and junk
    // Block 5 - just blank end
                
             index[7:5] <= 3'b000;  // Dummy symbols
             switch_point <= 1'b0;
             if(line_count < V_visible-1) begin //-- lines of active video (except first and last)
                 if   (row_count <  1) index[7:5] <= 3'b101;  // Just blank end BE
                 else if(row_count < 73) index[7:5] <= 3'b001;  // Pixels plus fill                                                 
                 else if(row_count == 73) index[7:5] <= 3'b010;  // Pixels BS and VS-ID block (no VBLANK flag)       
           
             end else if(line_count == V_visible-1) begin // Last line of active video
                 if(row_count <  1) begin
                     index[7:5] <= 3'b101;  // Just blank end BE
                 end else if(row_count < 73) begin
                     index[7:5] <= 3'b001;  // Pixels plus fill 
                 end else if(row_count == 73) begin
                     index[7:5] <= 3'b011;  // Pixels BS and VS-ID block (with VBLANK flag)       
                 end
             end else begin
                 //---------------------------------------------------------------
                 // Allow switching to/from the idle pattern during the vertical blank
                 //---------------------------------------------------------------                        
                 if(row_count < 73) begin
                     switch_point <= 1'b1;
                 end else if(row_count == 73) begin
                    index[7:5] <= 3'b100;  // Dummy symbols, BS and VS-ID block (with VBLANK flag)                        
                 end
             end            
         end else begin
             index <= index + 1;
         end
     end
endmodule
