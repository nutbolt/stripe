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
#include <linux/gpio_dev.h>
#include <linux/ioctl.h>

// GPIO pins to use for driving the LED strip
const int clock_pin = 4;
const int data_pin = 5;

// read lines from stdin and send them out as serial SPI data on the I/O pins
int main(int argc, const char* argv) {
  if (argc > 1) {
    printf("Write colors in format r,g,b,r,g,b,...r,g,b followed by enter.\n"
           "Colors are 8 bit values: from 0-255.\n");
    exit(0);
  }
  
  // make sure we can the SPI I/O pins for GPIO (essential for pins 4 & 5!)
  system("io 0x10000060 0x1f");

  // try to open the GPIO pins
  int fd = open("/dev/gpio", O_RDWR);
  if (fd < 0) {
    perror("/dev/gpio");
    exit(1);
  }

  // initialize the IO pin direction
  ioctl(fd, GPIO_DIR_OUT, data_pin);
  ioctl(fd, GPIO_DIR_OUT, clock_pin);
  ioctl(fd, GPIO_CLEAR, clock_pin);

  while (!feof(stdin)) {
    int r, g, b;
    if (scanf("%d,%d,%d", &r, &g, &b) == 3) {
      // send out 24 bits for one LED
      long mask, bits = ((long) b << 16) | ((long) g << 8) | r;
      for (mask = 0x800000; mask != 0; mask >>= 1) {
        // set data pin according to the bit in the mask
        ioctl(fd, bits & mask ? GPIO_SET : GPIO_CLEAR, data_pin);
        // toggle the clock pin
        ioctl(fd, GPIO_SET, clock_pin);
        ioctl(fd, GPIO_CLEAR, clock_pin);
      }
    }
    // insert a delay for the LED strip when the end of line is reached
    // this will also eat up any errors in the input (i.e. not "r,g,b")
    if (getchar() != ',')
      usleep(2000); // microseconds
  }

  close(fd);    
  exit(0);
}
