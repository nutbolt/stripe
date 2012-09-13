#!/usr/bin/env lua
-- A quick test to verify that the LED serial out pins work.
-- This is extremely slow, serial bits are shifted out at about 20 Hz.

-- This code depends on the standard "io" and "gpioctl" packages:
--    opkg update && opkg install io gpioctl

local clock, data = 4, 5 -- pin definitions

local function gpio (cmd, value)
  os.execute('gpioctl '..cmd..' '..value..' >/dev/null')
end

-- make sure the SPI pins are configured as GPIO pins
os.execute('io 0x10000060 0x1f')

-- prepare clock and data I/O pins as outputs
gpio('dirout', clock)
gpio('dirout', data)

local function sendBit(value)
  if value > 0 then
    gpio('set', data)
  else
    gpio('clear', data)
  end
  gpio('set', clock)
  gpio('clear', clock)
end

for i=1,25 do
  sendBit(0) -- all off
end

os.execute('sleep 1')

for i=1,25 do
  sendBit(1) -- full white
end