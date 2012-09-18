/* ledstrip -- Set the Stripe LED strip to RGB values read from stdin.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA02111-1307USA
 *
 * Based on Arduino library to control LPD8806-based RGB LED Strips
 *            (c) Adafruit industries, MIT license
 * Adapted by David Menting 2012
 * Adapted to WS2801 30 jul 2012
 * Simplified and io call added by jcw, 2012-09-16
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <sys/mman.h>

// GPIO pins to use for driving the LED strip
const int clock_pin = 4;
const int data_pin = 5;
const int page_offset = 0x10000000;
const int page_size = 0x1000;

// read lines from stdin and send them out as serial SPI data on the I/O pins
int main(int argc, const char* argv) {
  if (argc > 1) {
    printf("Write colors in format r,g,b,r,g,b,...r,g,b followed by enter.\n"
           "Colors are 8 bit values: from 0-255.\n");
    exit(0);
  }
  
  // try to open the memory device
  int fd = open("/dev/mem", O_RDWR);
  if (fd < 0) {
    perror("/dev/mem");
    exit(1);
  }

  // get a map into raw memory
  void* mem = mmap(NULL, page_size, PROT_READ|PROT_WRITE,
                    MAP_SHARED, fd, page_offset);
  if (mem == MAP_FAILED) {
    perror("cannot map memory");
    exit(1);
  }

#define SET32(o,v) *(long*)((char*) mem + (o)) = v
#define OR32(o,v) *(long*)((char*) mem + (o)) |= v

  // make sure we can use the SPI I/O pins for GPIO (essential for pins 4 & 5!)
  SET32(0x60, 0x1f);

  // initialize the IO pin direction
  OR32(0x624, (1 << data_pin) | (1 << clock_pin)); // p.58
  OR32(0x630, 1 << clock_pin); // p.59, sets clock pin low

  while (!feof(stdin)) {
    int r, g, b;
    if (scanf("%d,%d,%d", &r, &g, &b) == 3) {
      // send out 24 bits for one LED
      long mask, bits = ((long) b << 16) | ((long) g << 8) | r;
      for (mask = 0x800000; mask != 0; mask >>= 1) {
        // set data pin according to the bit in the mask
        OR32(bits & mask ? 0x62C : 0x630, 1 << data_pin); // p.59
        // toggle the clock pin
        OR32(0x634, 1 << clock_pin); // p.59
        OR32(0x634, 1 << clock_pin); // p.59
      }
    }
    // insert a delay for the LED strip when the end of line is reached
    // this will also eat up any errors in the input (i.e. not "r,g,b")
    if (getchar() != ',')
      usleep(2000); // microseconds
  }

  munmap(mem, page_size);
  exit(0);
}
