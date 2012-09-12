#!/usr/bin/lua
----------------------------------------------------------------------------
-- Transition from one pixel array to the other
-- Copyright (C) 2012 Nut & Bolt
--
-- Author: David Menting
--
---------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Declarations and settings
-----------------------------------------------------------------------------
steps = 10

-----------------------------------------------------------------------------
-- Start the program here!
-----------------------------------------------------------------------------

if(arg[1] == "-s" or arg[1] == "-S" or arg[1] == "--steps") then
  steps = tonumber(arg[2]) or steps  
elseif(arg[1] == "-h" or arg[1] == "-H" or arg[1] == "--help") then
  print([[
Fade from one row of pixels to the next.
Reads two lines from standard input outputs them to the command line

-s, --steps     Number of steps
-h, --help      This help message
    ]])
  os.exit()
end

-- Read both rows into a table

rowto = "return {" .. io.read() .. "}"

-- this is a fancy way of turning the comma-separated list into a Lua table
for line in io.lines() do
  rowfrom = rowto
  rowto   = "return {" .. line .. "}"

  tfrom = assert(loadstring(rowfrom))()
  tto = assert(loadstring(rowto))()
  tstep = {}
  tout = tfrom

  for k,v in pairs(tfrom) do
    tstep[k] = (tto[k] - v)/steps
    io.write(v)
    io.write(",")
  end

  io.write("\n")

  for i=1,steps do
    for k,v in pairs(tfrom) do
      tout[k] = tout[k] + tstep[k]
      io.write(math.floor(tout[k]+0.5))
      io.write(",")
    end
    io.write("\n")
  end
end