-- Public scheduler API, as exposed by the server.

-- all the display-specific code is in a separate module
local display = require 'display'
-- local display = require 'display-debug'

local M = {} -- public module interface

-- current cheduler version
function M.version () return {0,1,0} end

-- for basic testing, see smoke.lua
function M.sum (a,b) return a+b end

--[[

- the state mainly consists of a series of layers with color ranges
- layers are ordered and will be merged in "level" and "slot" directions
- slots are numbered 0..1439, one for each minute since midnight
- layers are named via an arbitrary unique string
- each layer is a table with the following structure:
    { alpha=AAA; SLICE-1, ..., SLICE-N }
  where
    AAA is the opacity of this layer (from 0=clear to 1023=opaque)
    and slices are objects defining ranges, ordered by their offset
- each slice is an object with these fields:
    { offset=OOO, duration=DDD, r=RRR, g=GGG, b=BBB }
  where:
    OOO is the start of this slice in minutes since midnight (0..1439)
    DDD is the duration in minutes of this slice (1..up)
    RRR is a 10-bit red intensity level (0..1023)
    GGG is a 10-bit green intensity level (0..1023)
    BBB is a 10-bit blue intensity level (0..1023)

--]]

local state = {} -- the individual layers, keyed on their string name
local order = {} -- an ordered list of all the layer names

-- return the ordered list of layers
function M.layers () return order end

-- given a layer name, return its position or nil
local function findLayer (name)
  for i, v in ipairs(order) do
    if v == name then
      return i
    end
  end
end

-- add, change, or remove a layer
function M.setlayer (name, content)
  assert(name, 'missing layer name')
  if content then
    if not state[name] then
      table.insert(order, name) -- append new layer
    end
  else
    local pos = findLayer(name)
    if pos then table.remove(order, pos) end
  end
  state[name] = content
end

-- update the display
function M.update ()
  display.update(state)
end

return M
