--[[

 Copyright (C) 2012 Nut & Bolt

 Author: David Menting

 Setup script to convert a plain Carambola into a Stripe

]]--

-- These are the packages that should be installed
-- for Stripe to work
required_packages = {
	--lua 
	--luci-mod-admin-full
	--libuci-lua
	"luasec",
	"uhttpd",
	"luci-theme-bootstrap"
}

local uci = require("uci")
local opkg = require("luci.model.ipkg")

os.remove("/etc/config/wireless")

f = io.popen("wifi detect > /etc/config/wireless") -- will this work?
f.close()

