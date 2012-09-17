#!/bin/sh
# A quick test to verify that the LED serial out pins work.
# This is extremely slow, serial bits are shifted out at about 30 Hz.

# This code depends on the standard "io" and "gpioctl" packages:
#    opkg update && opkg install io gpioctl

# pin definitions
clock=4
data=5

# make sure the SPI pins are configured as GPIO pins
io 0x10000060 0x1f

# prepare clock and data I/O pins as outputs
gpioctl dirout $clock >/dev/null
gpioctl dirout $data >/dev/null

for v in clear set; do
  for i in 1 2 3 4 5 6 7 8 9 10 1 2 3 4 5 6 7 8 9 10 1 2 3 4 5; do
    gpioctl $v $data >/dev/null
    gpioctl set $clock >/dev/null
    gpioctl clear $clock >/dev/null
  done
  sleep 1
done
