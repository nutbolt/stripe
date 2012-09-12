-- By Norman Ramsey: http://stackoverflow.com/questions/132397/get-back-the-output-of-os-execute-in-lua
function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

-- Ping the gateway

-- Google Calendar check
ping_calendar = os.capture("ping -c 1 calendar.google.com | grep '1 packets received'")
if ping_calendar == "" then
	print("Google Calendar: No connection.")
else
	print("Google Calendar: OK!")
end
-- ntp.org checks

-- Got IP address?
if os.capture("ifconfig wlan0 | grep 'inet addr'") == "" then
	print("No IP address")
end

-- WLAN association check
access_point = os.capture("iwconfig wlan0 | grep 'Access Point'")
if string.find(access_point, "Not Associated") then
	print("Not associated with an access point")
else
	print("Access point: " .. access_point)
end

--[[
"Bad address" on ping: probably an internal firewall or configuration error
""
]]--