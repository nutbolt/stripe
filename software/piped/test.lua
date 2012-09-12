require("gcal")

dofile("config.lua")
dofile("calendars.lua")

-----------------------------------------------------------------------------
-- Date and time
-----------------------------------------------------------------------------
n = os.date("*t")
now = os.time()

-- TODO: this doesn't work for nocturnal people. This assumes you wake up after midnight, not before
morning = os.time({ year=n.year, month=n.month, day=n.day, hour=config.start_hours, minutes=config.start_minutes })
night = morning + config.total_seconds
pixel_divider = (night - morning) / config.pixel_count

pixels = {}
for i=1,config.pixel_count do pixels[i] = "0,0,0" end

for _,c in pairs(GoogleCalendars) do
	local calendar = gcal.fetchproperties(c)

	-- white balance factors
	c.color[1] = math.floor(c.color[1])
	c.color[2] = math.floor(c.color[2])
	c.color[3] = math.floor(c.color[3] * .8)

	colorstring = table.concat(c.color,",") -- color is returned as a table of an r,g and b value

	if(type(calendar) == "table") then
		local code, events = gcal.getevents(c.calendar_id, c.auth_string, morning, night)

		for _,event in pairs(events) do
			if event.dtstart and event.dtend and event.dtstart < night and event.dtend > morning then
          
              local s = (math.floor((event.dtstart - morning)/pixel_divider))
              local e = (math.floor((event.dtend - morning)/pixel_divider))
              
              for i=s, e do
                  pixels[i] = colorstring
              end
        	end
		end
	end
end

for i, v in ipairs(pixels) do
  io.write(v,",")
end
io.write("\n")