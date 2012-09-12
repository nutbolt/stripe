#!/usr/bin/lua
----------------------------------------------------------------------------
-- Copyright (C) 2012 Nut & Bolt
--
-- Author: David Menting
--
-- Frames Per Second reads from standard input line by line
-- and only outputs a certain number of lines per second
--
-- This is calibrated on the 300MHz Carambola. On faster systems
-- the rates above 60 fps might be much faster than expected
----------------------------------------------------------------------------
fps = 30; 	   -- default frames per second


if(arg[1] == "-f") then
  fps = tonumber(arg[2]) or fps
elseif(arg[1] == "-h") then
  print([[
Frames Per Second reads from standard input line by line and outputs a certain number of lines per second

-f number	Set frame rate to number fps (default: 30)
-h 	        This help message
    ]])
  os.exit()
end

if(fps > 90) then
	period = 0 -- remove all brakes. Let's go as fast as we can!
elseif(fps > 60) then
	period = 0.01 -- this results in about 80-100 fps
else
	period = 1/(fps)
end

for line in io.lines() do
	local target_time = os.clock() + period
	io.write(line) -- let's write the line already to waste some time

	repeat
	until (os.clock() > target_time) -- enough time passed yet?
	io.write("\n")
	io.flush()
end