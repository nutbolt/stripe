----------------------------------------------------------------------------
-- Stripe main handler
-- Copyright (C) 2012 Nut & Bolt
--
-- Author: David Menting
--
--[[

this file is going to be the main application:

-- Step 1: determine time & date: proceed if within range
-- Step 2: query calendars for colors
-- Step 3: query calendars for events
-- Step 4: calculate pixels for date
-- Step 5: push data out to the led strip

]]--
---------------------------------------------------------------------------

local https = require("ssl.https")
local table = require("table")
local ltn12 = require("ltn12")
local ical = require("ical")

-- require("string") is this necessary?
dofile("config.lua")

-----------------------------------------------------------------------------
-- Declarations and settings
-----------------------------------------------------------------------------
local t = {} -- return table for HTTP bodies
calendar = {}
DATE_FORMAT = "%Y%m%dT%H%M%SZ" -- this is the format Google Calendar likes to see
-- zerofill the pixel array
pixels = {}
for i=1,config.pixel_count do pixels[i] = "0,0,0" end
verbose_flag = false

local auth_string = "c3R1ZGlvbWVudGluZ0BnbWFpbC5jb206c3N2ZWx2aWtkeGpkYW5lYg=="
local calendar_id = "qkm5l1dv0uo1j3ev7kmtmsvsj8%40group.calendar.google.com"
--local calendar_id = "studiomenting%40gmail.com"
-----------------------------------------------------------------------------
-- HTTP Request defaults
-----------------------------------------------------------------------------

request = {
  headers = { 
            ["Host"] = "calendar.google.com",          
            ["Content-Type"] = "text/xml; charset=UTF-8",
        },
}

-----------------------------------------------------------------------------
-- Date and time
-----------------------------------------------------------------------------
n = os.date("*t")
now = os.time()

-- TODO: this doesn't work for nocturnal people. This assumes you wake up after midnight, not before
morning = os.time({ year=n.year, month=n.month, day=n.day, hour=config.start_hours, minutes=config.start_minutes })
night = morning + config.total_seconds
pixel_divider = (night - morning) / config.pixel_count

-----------------------------------------------------------------------------
-- Output parsing
-----------------------------------------------------------------------------

pattern = {
          ["ctag"] = "<[%w:]*getctag[%w:=/\"\.\ ]*>([0-9]+)</[%w:]*getctag>", -- want to add whitespace at start of line
          ["name"] = "<[%w:]*displayname>([%w]*)</[%w:]*displayname>",
          ["description"] =  "<[%w:]*calendar--description[%w:=/\"\.\ :]*>([%w\ ]+)",
          ["color"] = "<[%w:]*calendar--color[%w:=/\"\.\ :]*>(#[0-9a-fA-F]+)" 
        }

function parse_properties(s) 
    calendar.ctag = string.match(s, pattern.ctag)
    calendar.name = string.match(s, pattern.name)
    calendar.description = string.match(s, pattern.description)
    calendar.color = string.match(s, pattern.color)
    -- TODO: could be more like for each pattern try to match and add it to the calendar table
end

function hex_to_rgbstring(hex) -- converts a hex color code #ff0000 to a 24 bit color value separated by commas
    -- TODO: validity checks
    red = tonumber("0x" .. string.sub(hex,2,3))
    green = tonumber("0x" .. string.sub(hex,4,5))
    blue = tonumber("0x" .. string.sub(hex,6,7))
    return red .. "," .. green .. "," .. blue
end

function verbose(message)
  if(verbose_flag) then print(message) end
end

-----------------------------------------------------------------------------
-- Start the program here!
-----------------------------------------------------------------------------

if(arg[1] == "-v" or arg[1] == "-V" or arg[1] == "--verbose") then
  print(arg[1])
  verbose_flag = true
elseif(arg[1] == "-h" or arg[1] == "-H" or arg[1] == "--help") then
  print([[
Google Calendar handler

-v, --verbose   Human readable output
-h, --help      This help message
    ]])
end

verbose("Time range is from " .. os.date(DATE_FORMAT, morning) .. " to " .. os.date(DATE_FORMAT, night))

-- Are we before morning? Lets blank the pixels then
if(now < morning) then
  verbose("It's too early to be Striping - you should be sleeping")
  os.exit()
end

verbose("\nGet today's events from Google Calendar\n")

options = {
    url = "https://calendar.google.com/calendar/dav/" .. calendar_id .. "/",
    headers = { 
            ["Authorization"] = "Basic " .. auth_string,
            ["Content-Length"] = 0,
            ["Content-Type"] = "text/xml; charset=UTF-8",
            ["Depth"] = 0,
            ["Connection"] = "keep-alive"
        },
    method = "OPTIONS",
    sink = ltn12.sink.table(t) -- The sink is a function that processes the incoming data
}

propfind = {
    --url = "https://calendar.google.com/calendar/dav/qkm5l1dv0uo1j3ev7kmtmsvsj8%40group.calendar.google.com/events/",
    url = "https://calendar.google.com/calendar/dav/" .. calendar_id .. "/events/",
    headers = { 
            ["Authorization"] = "Basic " .. auth_string,
            ["Content-Length"] = 0,
            ["Content-Type"] = "text/xml; charset=UTF-8",
            ["Depth"] = 0,
            ["Connection"] = "keep-alive"
        },
    method = "PROPFIND",
    sink = ltn12.sink.table(t) -- The sink is a function that processes the incoming data
}


res, code, headers, status = https.request(propfind)
-- Restrict to morning and night
body = [[
<?xml version="1.0" encoding="utf-8" ?>
<C:calendar-query xmlns:D="DAV:"
                  xmlns:C="urn:ietf:params:xml:ns:caldav">
  <D:prop>
    <D:getetag/>
    <C:calendar-data/>
  </D:prop>
  <C:filter>
    <C:comp-filter name="VCALENDAR">
      <C:comp-filter name="VEVENT">
        <C:time-range start="]] .. os.date(DATE_FORMAT, now) .. [["
                      end="]] .. os.date(DATE_FORMAT, night) .. [["/>
      </C:comp-filter>
    </C:comp-filter>
  </C:filter>
</C:calendar-query>

]]

todaysevents = {
    url = "https://calendar.google.com/calendar/dav/" .. calendar_id .. "/events/",
    headers = { 
            ["Authorization"] = "Basic " .. auth_string,
            ["Host"] = "calendar.google.com",
            ["Content-Length"] = #body,
            ["Depth"] = 1,
            ["Content-Type"] = "text/xml; charset=UTF-8",
        },
    method = "REPORT",
    source = ltn12.source.string(body),
    sink = ltn12.sink.table(t),
}

verbose(code)

if(code == 207) then

    parse_properties(table.concat(t))

    if(calendar.color) then
      verbose(hex_to_rgbstring(calendar.color))
    end

    res, code, headers, status = https.request(todaysevents)

    if(code == 207) then
      verbose("Found events for today:")

      xmlresponse = table.concat(t)
      
      vcal_begin = string.find(xmlresponse, "BEGIN:VCALENDAR") or 0
      vcal_end = string.find(xmlresponse, "END:VCALENDAR") or 0

      vcalendar = string.sub(xmlresponse,vcal_begin,(vcal_end+#"END:VCALENDAR"-1))
      
      --strip off all xml and send to ical parser
      events = ical.load(vcalendar)

      -- Loop through today's events
      for i, event in ipairs(events) do
        if event.type == "VEVENT" and event.dtstart and event.dtend and event.dtstart < night and event.dtend > morning then
          verbose(event.dtstart and os.date("!%c", event.dtstart) or "Unknown", event.SUMMARY);

              local s = (math.floor((event.dtstart - morning)/pixel_divider))
              local e = (math.floor((event.dtend - morning)/pixel_divider))
              
              for i=s, e do
                  pixels[i] = hex_to_rgbstring(calendar.color)
              end
        end
      end
    else
      print("No events for today")
    end
    verbose(table.concat(t))
end
    
for i, v in ipairs(pixels) do
  io.write(v,",")
end
io.write("\n")