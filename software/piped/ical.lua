--[[

  Based on code by Matthew Wild <mwild1@gmail.com>
  http://code.matthewwild.co.uk/

--]]

module("ical", package.seeall)

local handler = {};

function handler.VEVENT(ical, line)
	local k,v = line:match("^(.+):(.*)$");

	local curr_event = ical[#ical];
	if k and v then
		curr_event[k] = v;
	end

    if k and string.find(k, "DTSTART") then
        timezone = k:match("DTSTART;TZID=([a-zA-Z\-\\/]+)")
        -- TODO: timezone handling
        local t = {};
		t.year, t.month, t.day, t.hour, t.min, t.sec = v:match("^(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)(%d%d)$");
        for k,v in pairs(t) do t[k] = tonumber(v); end
		curr_event.dtstart = os.time(t);
    end

    if k and string.find(k, "DTEND") then
        timezone = k:match("DTEND;TZID=([a-zA-Z\-\\/]+)")
        -- TODO: timezone handling
        local t = {};
		t.year, t.month, t.day, t.hour, t.min, t.sec = v:match("^(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)(%d%d)$");
        for k,v in pairs(t) do t[k] = tonumber(v); end
		curr_event.dtend = os.time(t);
	end
end

function handler.VTIMEZONE(ical, line)
    local k,v = line:match("^(.+):(.*)$");
    
    if k == "TZID" then
        -- TODO
    end
end

function load(data)
	local ical, stack = {}, {};
	local line_num = 0;
	
	-- Parse
	for line in data:gmatch("(.-)[\r\n]+") do
		line_num = line_num + 1;
		if line:match("^BEGIN:") then
			local type = line:match("^BEGIN:(%S+)");
			table.insert(stack, type);
			table.insert(ical, { type = type }); 
		elseif line:match("^END:") then
			if stack[#stack] ~= line:match("^END:(%S+)") then
				return nil, "Parsing error, expected END:"..stack[#stack].." before line "..line_num;
			end
			table.remove(stack);
		elseif handler[stack[#stack]] then
			handler[stack[#stack]](ical, line);
		end
	end
	
	-- Return calendar
	return ical;
end


return _M;
