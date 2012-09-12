--[[
 Copyright (C) 2012 Nut & Bolt

 Author: David Menting
 
 Takes the input from 'iwlist scan' to output a Lua table of Wi-Fi networks
 found by the system's Wi-Fi interfaces.
 
 Usage: iwlist scan | lua iwlist.lua

 Uses the serialization library by Matthew Wild to output a nice table.
 http://code.matthewwild.co.uk/
 If you don't need it just remove the first and last lines of the script.

]]--

local serialization = require("serialization")
JSON = (loadfile "JSON.lua")()

local iwlist = {}

-- Read lines from stdin until a Cell: is found - this means a new network
for line in io.lines() do
	-- strip whitespace from line
	local l = line:gsub("^%s*(.-)%s*$", "%1")

	if l:match("^Cell") then
		local cell, address = l:match("^Cell%s+(%d+)%s+-%s+Address:%s+([0-9a-fA-F:]+)");
		iwlist[#iwlist+1] = { cell = tonumber(cell), address = address, encryption = "WEP" } 

	elseif l:match("^ESSID:(.*)") then
		iwlist[#iwlist].ssid = l:match("^ESSID:\"(.*)\"")

	elseif l:match("^Channel:(%d+)") then
		iwlist[#iwlist].channel = tonumber(l:match("^Channel:(%d+)"))

	elseif l:match("^Quality=(%d+)") then
		-- TODO: quality is reported in fractions of 70, so now we just multiply by 1/70 * 100 to get a percentage
		local q = l:match("^Quality=(%d+)/(%d+)")
		iwlist[#iwlist].quality = math.floor(tonumber(q) * 1.4285714286 + 0.5)

	elseif l:match("^Encryption%s+key:off") then
		iwlist[#iwlist].encryption = "Open"

	elseif l:match("^IE:%s+") then
		-- TODO: probably not the best way to match encryption but it works for now
		local major = l:match("WPA(%d).+Version") or "1"
		local minor = l:match("WPA.+Version%s(%d+)")
		if minor then
			iwlist[#iwlist].encryption = "WPA v" .. major .. "." .. minor
		end

	end
end

-- Sort table by link quality
table.sort(iwlist, function(a,b) return a.quality > b.quality end )
--print(serialization.serialize(iwlist))
print(JSON:encode(iwlist))