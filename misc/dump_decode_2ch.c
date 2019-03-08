///////////////////////////////////////////////////////////////////////////////
// dump_decode_2ch.c : 
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
/****************************************************************
* A parser for raw DisplayPort channel data, to aid in debug
*
* Expects to see teo 9-bit binary values per line
*
****************************************************************/

#include <stdio.h>
/***************************************************************/
static int read_a_line(FILE *f, char *buffer, int len) {
  int c;
  if(len > 0) {
    c = getc(f);
    if(c == EOF) 
      return 0;
    *buffer = c;
    buffer++;
    len--;
  }

  while(len > 0) {
    c = getc(f);
    if(c == EOF || c == '\n') 
      break;
    *buffer = c;
    buffer++;
    len--;
  }

  if(len < 1) {
    printf("Line too long\n");
    return 0;
  }
  *buffer = '\0';
  return 1;
}

/***************************************************************/
int parse(char *buffer, int *ch0, int *ch1) {
  int i = 0,  j;
  int c0 = 0, c1 = 0;
  // Eat whitespace

  while(buffer[i] == ' ' || buffer[i] == '\t') {
    i++;
  }

  for(j = 0; j < 9; j++) {
    if(buffer[i] == '0') {
      c0 = (c0<<1);
    } else if(buffer[i] == '1') {
      c0 = (c0<<1)+1;
    } else {
      return 0;
    }
    i++;
  }

  // If not end of line it must have whitespace
  if(buffer[i] != '\0') {
     if(buffer[i] != ' ' && buffer[i] != '\t') {
       return 0;
     }
  }

  // Eat whitespace
  while(buffer[i] == ' ' || buffer[i] == '\t') {
     i++;
  }

  if(buffer[i] != '\0') {
    for(j = 0; j < 9; j++) {
      if(buffer[i] == '0') {
        c1 = (c1<<1);
      } else if(buffer[i] == '1') {
        c1 = (c1<<1)+1;
      } else {
        return 0;
      }
      i++;
    }

    // If not end of line it must have whitespace
    if(buffer[i] != '\0' && buffer[i] != ' ' && buffer[i] != '\t') {
      return 0;
    }
  }

  // Eat whitespace
  while(buffer[i] == ' ' || buffer[i] == '\t') {
     i++;
  }

  *ch0 = c0;
  *ch1 = c1;

  return 1;
}

/***************************************************************/
int process(int ch0, int ch1) {
   static int count = 0,  last_be = 0,  last_bs = 0, in_fill = 0;
   static int pcount = 0, in_pixel = 0, in_secondary = 0;
   static long int bcount = 0, mcount = 0, mpart = 0;
   static long int mvalue = 2200, nvalue=4000;  
   static int p_of_line = 0;

   mpart  += mvalue;
   while(mpart >= nvalue) {
      mcount++;
      mpart -= nvalue;
   }
   if(mcount >= mvalue)
     mcount -= mvalue;
   
   printf("%6i ", p_of_line);
   if(ch0 == 0x1FE) {
      printf("%03X %03X - Fill Start\n",ch0, ch1);
      in_fill = 1;
   }  else if(ch0 == 0x1F7) {
      printf("%03X %03X - Fill End\n",ch0, ch1);
      in_fill = 0;
   }  else if(ch0 == 0x1BC) {
      printf("%03X %03X - Blank Start (%i since last, %i:%i  pixels,  mcount %i:%i x%02X)\n",
              ch0, ch1, count-last_bs, pcount/3*2, pcount%3*2,
              (int)mcount, (int)mpart, (int)mcount&0xFF);
      bcount = 6;
      pcount = 0;
      in_pixel = 0;
      last_bs = count;
   }  else if(ch0 == 0x1FB) {
      printf("%03X %03X - Blank End (%i since last)\n",ch0, ch1, count-last_be);
      pcount = 0;
      p_of_line = -1;
      in_pixel = 1;
      last_be = count;
   }  else if(ch0 == 0x15C) {
      printf("%03X %03X - Secondary Start\n",ch0, ch1);
      in_secondary = 1;
   }  else if(ch0 == 0x1FD) {
      printf("%03X %03X - Secondary End\n",ch0, ch1);
      in_secondary = 0;
   } else {
      if(in_fill) {
         printf("%03X %03X - Fill\n",ch0, ch1); 
      } else if(in_pixel) {
         printf("%03X %03X - pixel %i:%i %i:%i\n",ch0, ch1, pcount/3*2,pcount%3, pcount/3*2+1,pcount%3); 
         pcount++;      
      } else if(in_secondary) {
         printf("%03X %03X - Secondary\n",ch0, ch1); 
      } else {
         switch(bcount) {
           case 6:  printf("%03X %03X - VB-ID %s\n",   ch0, ch1, (ch0&1) ? "BLANKING" : "active"); bcount--; break;
           case 5:  printf("%03X %03X - Mvid\n",       ch0, ch1); bcount--; break;
           case 4:  printf("%03X %03X - Maud\n",       ch0, ch1); bcount--; break;
           case 3:  printf("%03X %03X - VB-ID #2 %s \n",   ch0, ch1, (ch1&1) ?  "BLANKING" : "active"); bcount--; break;
           case 2:  printf("%03X %03X - Mvid\n",       ch0, ch1); bcount--; break;
           case 1:  printf("%03X %03X - Maud\n",       ch0, ch1); bcount--; break;
           default: printf("%03X %03X - blanking\n",   ch0, ch1); break;
         } 
      }
  
   }
   p_of_line++;
   count++;
   return 0;
}

/***************************************************************/
int main(int argc, char *argv[]) {
  FILE *f;
  char buffer[128];

  int lines = 0;
  if(argc == 1) {
    f = stdin;
  } else {
    f = fopen(argv[1], "r");
  } 
  if(f == NULL) {
    fprintf(stderr, "Unable to open file\n");
    return 0;
  }
  while(read_a_line(f, buffer, sizeof(buffer))) {
    int ch0, ch1;
    if(parse(buffer, &ch0, &ch1)) {
      process(ch0, ch1);
    } else {
      printf("Unable to parse: '%s'\n", buffer);
    }
    lines++;
  }
  printf("%i lines processed\n", lines);
  return 0;
}
