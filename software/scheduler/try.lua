#!/usr/bin/env lua

require 'zmq'
for k,v in pairs(zmq) do
  print(k)
end

local t = {'a','b','c'}
print(1,t['a'])
print(2,t['d'])

-- require 'bencode'
-- print(bencode.encode())

-- 3456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
