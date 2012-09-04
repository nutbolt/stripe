#!/usr/bin/env lua
-- Simple "smoke test" of the ZeroMQ / bencode based RPC call mechanism.

local stripe = require 'stripe-api'

-- this is a local call
print("Current ZEROMQ version is " .. table.concat(zmq.version(), '.'))

-- so is this, because "apiVers" is predefined in stripe-api.lua
print("Current STRIPE-API version is " .. table.concat(stripe.apiVers(), '.'))

-- but this is a remote call, handled by the "version" code in scheduler.lua
print("Current SCHEDULER version is " .. table.concat(stripe:version(), '.'))

-- illustrate client-side debugging output of outgoing and returned data
stripe.apiDebug(true)
print(stripe:abc(1,2,{3,4,{5,6},7,8},9,0))
stripe.apiDebug(false)

-- here's a more sensible call
print(stripe:sum(11,22))
