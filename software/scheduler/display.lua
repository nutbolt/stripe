-- Display-specific code for merging colors and driving the output device.

local M = {} -- public module interface

-- specifications of the display
local leds = 32     -- number of LEDs
local start = 9*60  -- first LED starts at 9:00
local limit = 17*60 -- last LED ends at 17:00

-- try to open the spi device, fall back to running ledstrip if not available
local spi = io.open('/dev/spidev0.0', 'wb')
local fd = spi or assert(io.popen('nice --20 ledstrip', 'w'))
assert(fd, 'failed to connect to LED strip')

if spi then print('using SPI') end

-- combine layers and slots into an RGB value to display
local function combine (state, fromSlot, numSlots)
  return fromSlot % 256, fromSlot % 150, fromSlot % 100 -- dummy code for now
end

-- update the display, sends one line of r,g,b,... values to ledstrip
function M.update (state)
  local step = math.floor((limit - start) / leds + 0.5)
  local t = {}
  for i = 1, leds do
    local r, g, b = combine(state, start + (i - 1) * step, step)
    table.insert(t, r)
    table.insert(t, g)
    table.insert(t, b)
  end
  if spi then
    -- write one string with binary rgb values
    for i,v in ipairs(t) do
      t[i] = string.char(v)
    end
    fd:write(table.concat(t))
  else
    -- write one line with comma-separated rgb values
    fd:write(table.concat(t, ',')..'\n')
  end
  fd:flush()
end

return M
