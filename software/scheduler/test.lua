#!/usr/bin/env lua

local stripe = require 'stripe-api'

local S = require 'serialization'
S = S.serialize

print(1, S(stripe:layers()))
print(2, stripe:setlayer('wow', {1,2,3}))
print(3, stripe:setlayer('yes', {4,5,6}))
print(4, S(stripe:layers()))
print(5, stripe:setlayer('yes'))
print(6, stripe:setlayer())
print(7, S(stripe:layers()))
print(8, stripe:update())
