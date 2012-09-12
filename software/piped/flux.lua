--[[

http://aa.quae.nl/en/reken/zonpositie.html



unix_time = os.time();

julian_day = (unix_time / 86400) --+ 2440587.5 it's accurate enough without

M = -3.59 + (0.98560*julian_day)

latitude = 52
longitude = -5

print("Latitude: " .. latitude .. "˚ Longitude: " .. longitude .. "˚")
d_sun = math.rad(4.7585);

L_sun = M + 102.9372 + 180

t_transit = (longitude/15) + 7.6*math.sin(math.rad(M)) - 9.9*(math.sin(math.rad(2*L_sun)))
print("t_transit: " .. t_transit .. " before noon")

r_lat = math.rad(latitude)
r_long = math.rad(longitude)

h0 = math.rad(-0.83)

r_latlng = math.cos(r_lat)*math.cos(d_sun)

h = (math.sin(h0) - math.sin(r_lat)*math.sin(d_sun)) / r_latlng
hour_angle = math.acos(h)

print(math.deg(hour_angle)/15 .. " hours before noon")

]]--

local n = os.date("*t")
local now = os.time()
local pixels = {}
local sunset = {
	hours = 16,
	minutes = 0
}

local sunset_stamp = os.time({ year=n.year, month=n.month, day=n.day, hour=sunset.hours, minutes=sunset.minutes })

local line = io.read();

if(now < sunset_stamp) then
	io.write(line)
else
	for r,g,b in string.gmatch(line, "(%d+),(%d+),(%d+)") do
	  
	  red = math.floor(tonumber(r) * 0.3)
	  green = math.floor(tonumber(g) * 0.2)
	  blue = math.floor(tonumber(b) * 0.1)

	  io.write(red)
	  io.write(",")
	  io.write(green)
	  io.write(",")
	  io.write(blue)
	  io.write(",")


	end
end
io.write("\n")