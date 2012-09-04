-- Display-specific code for merging colors and driving the output device.

local M = {} -- public module interface

local NLEDS = 32 -- number of LEDs
local SLOTS = 15 -- minute slots per LED
local START = 540 -- minutes offset of first LED, i.e. 9:00

-- combine layers and slots into an RGB value to display
local function combine (state, fromSlot, numSlots)
  return fromSlot % 256, fromSlot % 150, fromSlot % 100 -- dummy code for now
end

-- update the display
function M.update (state)
  local s = '> '
  for i = 1, NLEDS do
    local r, g, b = combine(state, START + (i - 1) * SLOTS, SLOTS)
    s = s..r..'/'..g..'/'..b..' ' 
  end
  print(s)
end

return M