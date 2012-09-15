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

const int pause = 2000;     // microseconds
const int data_pin = 5;
const int clock_pin = 4;

int main(int argc, const char* argv) {
  if (argc > 1) {
    printf("Write colors in format r,g,b,r,g,b,...r,g,b followed by enter.\n"
           "Colors are 8 bit values: from 0-255.\n");
    exit(0);
  }
  
  system("io 0x10000060 0x1f"); // use SPI's I/O pins as GPIO

  // Try to open the GPIO pins
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
    while (scanf("%d,%d,%d", &r, &g, &b) == 3) {
      // write 24 bits per pixel
      long mask, bits = ((long) b << 16) | ((long) g << 8) | r;
      for (mask = 0x800000; mask != 0; mask >>= 1) {
        // set data pin according to the bit in the mask
        ioctl(fd, bits & mask ? GPIO_SET : GPIO_CLEAR, data_pin);
        // toggle the clock pin
        ioctl(fd, GPIO_SET, clock_pin);
        ioctl(fd, GPIO_CLEAR, clock_pin);
      }
      // keep going as long as more comma-separate values follow
      if (getchar() != ',')
        break;
    }

    // We need to have a delay here, a few ms seems to do the job
    // shorter may be OK as well - need to experiment :(
    usleep(pause);
  }

  close(fd);    
  exit(0);
}
