///////////////////////////////////////////////////////////////////////////////
// merge_colourbar.v : Replace sential values in a two channel 1080p stream
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
module merge_colourbars(
        input      clk,
        input      [72:0] data_in,
        output reg [72:0] data_out
    );

    localparam [8:0] PIX   = 9'b011001100;
    localparam [8:0] BE    = 9'b111111011;  // K27.7 Blank End
    localparam [8:0] BS    = 9'b110111100;  // K28.5 Blank Start 
   
    reg [11:0] pixel_count;
    reg [23:0] ch0_pixel;
    reg [23:0] ch0_pixel_next;
    reg [23:0] ch1_pixel;
    reg [23:0] ch1_pixel_next;
    reg [1:0] r_g_b;

initial begin
    pixel_count          = 12'b0;
    r_g_b                = 2'b00;
end


always @(posedge clk) begin
//////////////////////////////////
// Pixel value generation 
//////////////////////////////////

    ////////////////////////////////////////////////////
    // Advance the counter when last byte of pixel is used
    ////////////////////////////////////////////////////
    if     (pixel_count < 274*1)   begin ch0_pixel[23:0] = 24'hCCCCCC; end
    else if(pixel_count < 274*2)   begin ch0_pixel[23:0] = 24'h00CCCC; end
    else if(pixel_count < 274*3)   begin ch0_pixel[23:0] = 24'hCCCC00; end
    else if(pixel_count < 274*4)   begin ch0_pixel[23:0] = 24'h00CC00; end
    else if(pixel_count < 274*5)   begin ch0_pixel[23:0] = 24'hCC00CC; end
    else if(pixel_count < 274*6)   begin ch0_pixel[23:0] = 24'h0000CC; end
    else                           begin ch0_pixel[23:0] = 24'hCC0000; end
  
    if     (pixel_count < 274*1-1) begin ch1_pixel[23:0] = 24'hCCCCCC; end
    else if(pixel_count < 274*2-1) begin ch1_pixel[23:0] = 24'h00CCCC; end
    else if(pixel_count < 274*3-1) begin ch1_pixel[23:0] = 24'hCCCC00; end
    else if(pixel_count < 274*4-1) begin ch1_pixel[23:0] = 24'h00CC00; end
    else if(pixel_count < 274*5-1) begin ch1_pixel[23:0] = 24'hCC00CC; end
    else if(pixel_count < 274*6-1) begin ch1_pixel[23:0] = 24'h0000CC; end
    else                           begin ch1_pixel[23:0] = 24'hCC0000; end
  
    if     (pixel_count < 274*1-2) begin ch0_pixel_next[23:0] = 24'hfCCCCC; end
    else if(pixel_count < 274*2-2) begin ch0_pixel_next[23:0] = 24'h00CCCC; end
    else if(pixel_count < 274*3-2) begin ch0_pixel_next[23:0] = 24'hCCCC00; end
    else if(pixel_count < 274*4-2) begin ch0_pixel_next[23:0] = 24'h00CC00; end
    else if(pixel_count < 274*5-2) begin ch0_pixel_next[23:0] = 24'hCC00CC; end
    else if(pixel_count < 274*6-2) begin ch0_pixel_next[23:0] = 24'h0000CC; end
    else                           begin ch0_pixel_next[23:0] = 24'hCC0000; end

    if     (pixel_count < 274*1-3) begin ch1_pixel_next[23:0] = 24'hfCCCCC; end
    else if(pixel_count < 274*2-3) begin ch1_pixel_next[23:0] = 24'h00CCCC; end
    else if(pixel_count < 274*3-3) begin ch1_pixel_next[23:0] = 24'hCCCC00; end
    else if(pixel_count < 274*4-3) begin ch1_pixel_next[23:0] = 24'h00CC00; end
    else if(pixel_count < 274*5-3) begin ch1_pixel_next[23:0] = 24'hCC00CC; end
    else if(pixel_count < 274*6-3) begin ch1_pixel_next[23:0] = 24'h0000CC; end
    else                           begin ch1_pixel_next[23:0] = 24'hCC0000; end
 
///////////////////////////////////////////////
// Scheduling the data out to the pipeline
///////////////////////////////////////////////

    data_out <= data_in;
    ///////////////////////////////////////////////
    // Replace the sentinel values with pixel data  
    ///////////////////////////////////////////////
    if(data_in[17:9] == PIX && data_in[8:0] == PIX) begin
       case(r_g_b) 
         2'b00:   begin
                    r_g_b = 2'b10;
                    data_out[7:0]   <=  ch0_pixel[7:0]; 
                    data_out[25:18] <=  ch1_pixel[7:0];
                    data_out[16:9]  <=  ch0_pixel[15:8];
                    data_out[34:27] <=  ch1_pixel[15:8];
                  end
         2'b01:   begin
                    r_g_b = 2'b00;
                    pixel_count = pixel_count + 2;
                    data_out[7:0]   <=  ch0_pixel[15:8];
                    data_out[25:18] <=  ch1_pixel[15:8];
                    data_out[16:9]  <=  ch0_pixel[23:16];
                    data_out[34:27] <=  ch1_pixel[23:16];
                    ch0_pixel <= ch0_pixel_next;
                    ch1_pixel <= ch1_pixel_next;
                  end
         default: begin
                    r_g_b = 2'b01;
                    pixel_count = pixel_count + 2;
                    data_out[7:0]   <=  ch0_pixel[23:16];
                    data_out[25:18] <=  ch1_pixel[23:16];
                    data_out[16:9]  <=  ch0_pixel_next[7:0];
                    data_out[34:27] <=  ch1_pixel_next[7:0];
                    ch0_pixel <= ch0_pixel_next;
                    ch1_pixel <= ch1_pixel_next;
                  end
       endcase
    end else if(data_in[17:9] == PIX) begin
       case(r_g_b) 
         2'b00:   begin
                    r_g_b = 2'b01;
                    data_out[17:9]  <=  ch0_pixel[7:0];
                    data_out[35:27] <=  ch1_pixel[7:0];
                  end
         2'b01:   begin
                    r_g_b = 2'b10;
                    data_out[17:9]  <=  ch0_pixel[15:8];
                    data_out[35:27] <=  ch1_pixel[15:8];
                  end
         default: begin
                    r_g_b = 2'b00;
                    pixel_count = pixel_count + 2;
                    data_out[17:9]  <=  ch0_pixel[23:16];
                    data_out[35:27] <=  ch1_pixel[23:16];
                    ch0_pixel <= ch0_pixel_next;
                    ch1_pixel <= ch1_pixel_next;
                  end
       endcase
    end else if(data_in[8:0] == PIX) begin
       case(r_g_b) 
         2'b00:   begin
                    r_g_b = 2'b01;
                    data_out[8:0]   <=  ch0_pixel[7:0];
                    data_out[26:18] <=  ch1_pixel[7:0];
                  end
         2'b01:   begin
                    r_g_b = 2'b10;
                    data_out[8:0]   <=  ch0_pixel[15:8];
                    data_out[26:18] <=  ch1_pixel[15:8];
                  end
         default: begin
                    r_g_b = 2'b00;
                    pixel_count = pixel_count + 2;
                    data_out[8:0]   <=  ch0_pixel[23:16];
                    data_out[26:18] <=  ch1_pixel[23:16];
                    ch0_pixel <= ch0_pixel_next;
                    ch1_pixel <= ch1_pixel_next;
                  end
       endcase
    end
    if(data_in[17:9] == BS || data_in[8:0] == BS) begin
       pixel_count = 12'b0;
    end 


end
endmodule
