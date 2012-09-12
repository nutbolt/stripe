local http = require("socket.http")
local table = require("table")
local ltn12 = require("ltn12")

local patterns = {
			["begin_twilight"] = "Begin civil twilight[^0-9]*([0-9]+):([0-9]+)",
          	["sunrise"] = "Sunrise[^0-9]*([0-9]+):([0-9]+)",
          	["transit"] = "Sun transit[^0-9]*([0-9]+):([0-9]+)",
          	["sunset"] = "Sunset[^0-9]*([0-9]+):([0-9]+)",
          	["end_twilight"] = "End civil twilight[^0-9]*([0-9]+):([0-9]+)"
        }
        
latitude = 52
longitude = -5
year = 2012
month = 3
day = 5

local t = {}
local sunrise = {}
local sunset = {}

local post = {
	FFX = 2,
	ID = "AA",
	xxy = year,
	xxm = month,
	xxd = day,
	place = "none",
	xx0 = -1,
	xx1 = longitude,
	yy0 = 1,
	yy1 = latitude,
	zz0 = -1,
	zz1 = 0,
	ZZZ = "END"
}

local tbody = {}
for k,v in pairs(post) do
	tbody[#tbody+1] = k .. "=" .. v
end
body = table.concat(tbody, "&")


local res, code, headers, status = http.request({
			url = "http://aa.usno.navy.mil/cgi-bin/aa_pap.pl",
			headers = { 
		            ["Content-Length"] = #body,
		            ["Content-Type"] = "text/html",
		        },
		    method = "POST",
		    source = ltn12.source.string(body),
		    sink = ltn12.sink.table(t)})
print(code)
if(code == 200) then
	response = table.concat(t)
	print(response)
	sunrise.hours, sunrise.minutes = string.match(response, patterns.sunrise)
	sunset.hours, sunset.minutes = string.match(response, patterns.sunset)
end