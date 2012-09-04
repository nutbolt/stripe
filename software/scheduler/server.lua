#!/usr/bin/env lua
-- Main server process, dispatches incoming requests to the scheduler.

require 'zmq'
require 'bencode'

-- configuration
local PORT = 'tcp://*:9384'
local VERBOSE = true

local sched = require 'scheduler'
local context = zmq.init(1)
local socket = context:socket(zmq.REP)

-- wrap all processing so we can catch and return errors
local function process (msg)
  local request = bencode.decode(msg)
  request[1] = sched[request[1]]
  return unpack(request)
end

-- main server loop, never stops
print('Server listening on '..PORT)
socket:bind(PORT)

while true do
  local message = socket:recv()
  if VERBOSE then print(message) end
  local valid, result = pcall(process(message))
  if VERBOSE then print(valid and '    OK:' or ' ERROR:',result) end
  socket:send(bencode.encode({valid and 0 or 1, result or ''}))
end
