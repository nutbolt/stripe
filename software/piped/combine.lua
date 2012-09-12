#!/usr/bin/lua
----------------------------------------------------------------------------
-- Combine two pixel rows
-- Copyright (C) 2012 Nut & Bolt
--
-- Author: David Menting
--
---------------------------------------------------------------------------
-- Declarations and settings
---------------------------------------------------------------------------
r1 = {}
r2 = {}

---------------------------------------------------------------------------
-- Start the program here!
---------------------------------------------------------------------------

if(arg[1] == "-h" or arg[1] == "-H" or arg[1] == "--help") then
  print([[
Combine two rows of pixels. The second row overrules the first

-h, --help      This help message
    ]])
  os.exit()
end

-- Read both rows
row1 = io.read()
row2 = io.read()

-- Parse them out into a table of rgb values
for r,g,b in string.gmatch(row1, "(%d+),(%d+),(%d+)") do
  r1[#r1+1] = { ["r"] = r, ["g"] = g, ["b"] = b }
end

for r,g,b in string.gmatch(row2, "(%d+),(%d+),(%d+)") do
  r2[#r2+1] = { ["r"] = r, ["g"] = g, ["b"] = b }
end

-- choose the longest row
length = #r1
if(#r2 > #r1) then
  length = #r2
end

for k=1, length do
  if(k > #r2) then
    -- we ran out of data in row2 so add the values from row1
    io.write(r1[k].r, ",", r1[k].g, ",", r1[k].b, ",")
  else
    if(r2[k].r == "0") and (r2[k].g == "0") and (r2[k].b == "0") and (k <= #r1) then
      -- we've got zeros in row2 and row1 still has values, so use those
      io.write(r1[k].r, ",", r1[k].g, ",", r1[k].b, ",")
    else
      -- just use the values from row2
      io.write(r2[k].r, ",", r2[k].g, ",", r2[k].b, ",")
    end
  end

end

io.write("\n")