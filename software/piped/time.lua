#!/usr/bin/lua
----------------------------------------------------------------------------
-- Stripe time handler
-- Copyright (C) 2012 Nut & Bolt
--
-- Author: David Menting
---------------------------------------------------------------------------

dofile("config.lua")

-----------------------------------------------------------------------------
-- Declarations and settings
-----------------------------------------------------------------------------
n = os.date("*t")
now = os.time()

-- TODO: this doesn't work for nocturnal people. This assumes you wake up after midnight, not before
morning = os.time({ year=n.year, month=n.month, day=n.day, hour=config.start_hours, minutes=config.start_minutes })
night = morning + config.total_seconds
pixel_divider = (night - morning) / config.pixel_count

pixels = {}
for i=1,config.pixel_count do pixels[i] = "0,0,0" end

-----------------------------------------------------------------------------
-- Start the program here!
-----------------------------------------------------------------------------

    
if now > morning and now < night then
    local e = math.floor(0.5 + (now - morning)/pixel_divider)

    for i=1, e do
        pixels[i] = "100,100,100"
    end
end


for i, v in ipairs(pixels) do
  io.write(v,",")
end
io.write("\n")