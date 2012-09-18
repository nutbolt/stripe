#!/usr/bin/env lua

local nixio = require 'nixio'

local SPI_DEV     = '/dev/spidev0.0'
local STRIP_SLEEP       = 900000

local O_RDWR_NONBLOCK   = nixio.open_flags('rdwr', 'nonblock')

-- make sure the SPI pins are configured as SPI pins (Carambola only)
os.execute('io 0x10000060 0x1d')

local spidev = nixio.open(SPI_DEV, O_RDWR_NONBLOCK)

for i=1,32 do
  -- B, G, R format
  spidev:write(string.char(20,100,200))
end

nixio.nanosleep(0,STRIP_SLEEP)

for i=1,32 do
  spidev:write(string.char(0,0,0))
end

nixio.nanosleep(0,STRIP_SLEEP)