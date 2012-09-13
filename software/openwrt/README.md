Installing a Stripe system on the Carambola
=================

From the Carambola command line (SSH,telnet or UART), go to /tmp and download the OpenWrt 12.09 binary from [openwrt.org](http://downloads.openwrt.org/attitude_adjustment/12.09-beta/ramips/rt305x/openwrt-ramips-rt305x-carambola-squashfs-sysupgrade.bin)

Run 'sysupgrade -v openwrt-ramips-rt305x-carambola-squashfs-sysupgrade.bin' to install OpenWrt

The sysupgrade retains sytem settings. If you want to revert to system defaults run 'firstboot' and then 'reboot'

Paste this into the command line to convert a plain OpenWrt installation to a PSK2 Wi-Fi client. Be sure to replace Your_SSID and Your_Key with the right string.

	uci set system.@system[0].hostname="Stripe"
	uci commit system
	uci set wireless.radio0.channel=auto
	echo "config interface 'loopback'
	        option ifname 'lo'
	        option proto 'static'
	        option ipaddr '127.0.0.1'
	        option netmask '255.0.0.0'

	config 'interface' 'wwan'
	        option 'proto' 'dhcp'" >> /etc/config/network
	uci set wireless.radio0.disabled=0
	uci set wireless.@wifi-iface[0].network=wwan
	uci set wireless.@wifi-iface[0].mode=sta
	#
	# Fill in your Wi-Fi credentials in the lines below
	#
	uci set wireless.@wifi-iface[0].ssid='Your_SSID'
	uci set wireless.@wifi-iface[0].key='Your_Key'
	uci set wireless.@wifi-iface[0].encryption=psk2
	#
	uci commit wireless
	/etc/init.d/dnsmasq disable
	/etc/init.d/dnsmasq stop
	/etc/init.d/firewall disable
	/etc/init.d/firewall stop
	reboot