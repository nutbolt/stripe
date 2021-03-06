-- pbm2C.lua
-- ascii saved pbm image to arduino array converter
-- 2010 Osgeld (zlib)
-- very basic, change filename in script, run
-- requires lua 5.0.2 or better
-- tested with pbm files generated by the gimp
-- X (width) must be a power of 2 (8, 16, 32, etc)
-------------------------------------------------------
----------------- FILE NAME ---------------------------
-------------------------------------------------------
filename = "anim.ppm"
-------------------------------------------------------
----------------- RUN THE SCRIPT ----------------------
----------- C:\lua\lua pbm2arduino.lua ----------------
-------------------------------------------------------

file      = io.open(filename)
shortname = string.sub(filename, 1, string.len(filename) - 4)
output    = io.open(shortname .. ".OUT", "w+")

data  = {}
image = ""
pixel = ""
byte  = ""
xSize = 0;
ySize = 0;
i = 1


-- read the file into a table
for line in file:lines() do
	pixel = math.floor(tonumber(line) / 4)
	output:write(pixel)
	if(math.fmod(i, 96) == 0) then
		output:write(";\n")
	elseif(math.fmod(i, 3) == 0) then
		output:write(";")
	else
		output:write(",")
	end
	i = i + 1
end

-- shutdown
io.close(file)
io.close(output)
print("done, view: " .. shortname .. ".OUT") 