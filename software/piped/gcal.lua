--[[



]]--
local https = require("ssl.https")
local table = require("table")
local ltn12 = require("ltn12")
local ical = require("ical")

module("gcal", package.seeall)

local patterns = {
          ["ctag"] = "<[%w:]*getctag[%w:=/\"\.\ ]*>([0-9]+)</[%w:]*getctag>", -- want to add whitespace at start of line
          ["name"] = "<[%w:]*displayname>([%w]*)</[%w:]*displayname>",
          ["description"] =  "<[%w:]*calendar--description[%w:=/\"\.\ :]*>([%w\ ]+)",
          ["color"] = "<[%w:]*calendar--color[%w:=/\"\.\ :]*>(#[0-9a-fA-F]+)" 
        }
calendars = {}
local DATE_FORMAT = "%Y%m%dT%H%M%SZ" -- this is the format Google Calendar likes to see
local headers = { 
            ["Host"] = "calendar.google.com",          
            ["Content-Type"] = "text/xml; charset=UTF-8",
        }
local t = {}
local calendarrequest = [[
<?xml version="1.0" encoding="utf-8" ?>
<C:calendar-query xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
  <D:prop>
    <D:getetag/>
    <C:calendar-data/>
  </D:prop>
  <C:filter>
    <C:comp-filter name="VCALENDAR">
      <C:comp-filter name="VEVENT">
        <C:time-range start="start_time" end="end_time"/>
      </C:comp-filter>
    </C:comp-filter>
  </C:filter>
</C:calendar-query>

]]

local function hextorgb(hex) -- converts a hex color code #ff0000 to a 24 bit color value separated by commas
    -- TODO: validity checks
    red = tonumber("0x" .. string.sub(hex,2,3))
    green = tonumber("0x" .. string.sub(hex,4,5))
    blue = tonumber("0x" .. string.sub(hex,6,7))
    return { red, green, blue }
end

-- Add a calendar from the calendar config file
function addcalendar(c)
	--TODO: error checking and validation
	calendars[#calendars+1] = {
		["displayname"] = c.displayname,
		["calendar_id"] = c.calendar_id,
		["auth_string"] = c.auth_string,
		["calendar_color"] = c.calendar_color
	}
end

-- Retrieve this calendar's properties from Google
function fetchproperties(c)
	local res, code, headers, status = https.request({
		url = "https://calendar.google.com/calendar/dav/" .. c.calendar_id .. "/events/",
	    headers = { 
	            ["Authorization"] = "Basic " .. c.auth_string,
	            ["Content-Length"] = 0,
	            ["Content-Type"] = "text/xml; charset=UTF-8",
	            ["Depth"] = 0
	        },
	    method = "PROPFIND",
	    sink = ltn12.sink.table(t)
	    })
	if(code == 207 or code == 200) then
		--parse the color
		s = table.concat(t)
		c.ctag = string.match(s, patterns.ctag)
	    c.name = string.match(s, patterns.name)
	    c.description = string.match(s, patterns.description)
	    c.color = hextorgb(string.match(s, patterns.color))
	    return c
	elseif(code == 404) then
		return code
	else
		error("Unknown response: " .. code)
	end
end

function getevents(calendar_id, auth_string, start_time, end_time)
	t = {} -- Make sure the return table is empty
	if not start_time then error("Please define a start time") end
	local body = string.gsub(calendarrequest, "start_time", os.date(DATE_FORMAT, start_time))
		  body = string.gsub(body, 			   "end_time",	os.date(DATE_FORMAT, end_time))
	local events = {}
	local res, code, headers, status = https.request({
		 url = "https://calendar.google.com/calendar/dav/" .. calendar_id .. "/events/",
		    headers = { 
		            ["Authorization"] = "Basic " .. auth_string,
		            ["Host"] = headers["Host"],
		            ["Content-Length"] = #body,
		            ["Depth"] = 1,
		            ["Content-Type"] = headers["Content-Type"],
		        },
		    method = "REPORT",
		    source = ltn12.source.string(body),
		    sink = ltn12.sink.table(t)
		})
    if(code == 207) then
	    xmlresponse = table.concat(t)
		vcal_begin = string.find(xmlresponse, "BEGIN:VCALENDAR") or 0
	    vcal_end = string.find(xmlresponse, "END:VCALENDAR") or 0
	    vcalendar = string.sub(xmlresponse,vcal_begin,(vcal_end+#"END:VCALENDAR"-1))
	    entries = ical.load(vcalendar)
	    for _,e in ipairs(entries) do
	    	if(e.type == "VEVENT") then -- we only want events
	    		events[#events+1] = e
	    	end
	    end
	end
	return code, events
end
