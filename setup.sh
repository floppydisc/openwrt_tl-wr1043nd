#/bin/sh

WAN=`uci -P/var/state get network.wan.ifname`
#WANMAC=`ifconfig \$WAN | awk '/HWaddr/ { print $5 }' | sed 's/:/-/g'`
#WLAN="wlan0"
#UAMHOMEPAGE="https:\/\/customer.hotspotsystem.com\/customer\/index.php?nasid=emenu\\_2\\"
#
UAMHOMEPAGE="https:\/\/customer.hotspotsystem.com\/customer\/index.php?nasid=emenu\\_2\\\&forward=1"
WHITELABEL="https:\/\/customer.hotspotsystem.com"
uci set wireless.@wifi-device[0].disabled=0; uci commit wireless; wifi
WLAN=`ifconfig | grep wl | cut -d " " -f1`
WLANMAC=`ifconfig \$WLAN | awk '/HWaddr/ { print $5 }' | sed 's/:/-/g'`

#opkg update
#opkg install coova-chilli 
#opkg install kmod-tun 
wget -O /etc/init.d/chilli http://www.hotspotsystem.com/firmware/openwrt/chilli 
chmod a+x /etc/init.d/chilli
wget -O /etc/chilli/defaults.tmp http://hotspotsystem.com/firmware/openwrt/defaults 
cat /etc/chilli/defaults.tmp | sed "s/HS_NASID=\"xxxxx\"/HS_NASID=\"emenu\\_2\\\"/g" | sed "s/HS_WANIF=wan/HS_WANIF=$WAN/g" | sed "s/HS_LANIF=lan/HS_LANIF=$WLAN/g" | sed "s/HS_UAMHOMEPAGE=\"\"/HS_UAMHOMEPAGE=\"$UAMHOMEPAGE\"/g" | sed "s/https:\/\/customer.hotspotsystem.com/$WHITELABEL/g" > /etc/chilli/defaults
sed -i -e "/HS_UAMDOMAINS/d" /etc/chilli/defaults
echo HS_UAMDOMAINS=\"paypal.com paypalobjects.com worldpay.com rbsworldpay.com adyen.com hotspotsystem.com geotrust.com \" >> /etc/chilli/defaults
#crontab -l > /tmp/mycron
crontab -r
echo "54 * * * * /usr/bin/wget http://tech.hotspotsystem.com/up.php?mac=$WLANMAC\&nasid=emenu\\_2\\\&os_date=OpenWrt\&uptime=\`uptime|sed \"s/" "/\%20/g\"|sed \"s/:/\%3A/g\"|sed \"s/,/\%2C/g\"\` --output-document /tmp/up.result; chmod 755 /tmp/up.result; /tmp/up.result;" >> /tmp/mycron
crontab /tmp/mycron
rm /tmp/mycron
opkg remove ip6tables
opkg remove kmod-ip6tables
opkg remove odhcp6c
opkg remove 6relayd
opkg remove kmod-ipv6
#version check
OPENWRT_VER=`cat /etc/openwrt_version`
OPENWRT_VER_MAJOR=`echo $OPENWRT_VER | cut -d \. -f 1`
OPENWRT_VER_MINOR=`echo $OPENWRT_VER | cut -d \. -f 2`
DISTRIB_REV=`grep DISTRIB_REVISION /etc/openwrt_release | cut -d \= -f 2 | cut -d \" -f 2 | cut -d r -f 2`

MIN_REV="42625"

echo "OPENWRT_VER: $OPENWRT_VER"
echo "MAJOR: $OPENWRT_VER_MAJOR"
echo "MINOR: $OPENWRT_VER_MINOR"
echo "REV: r$DISTRIB_REV"

chillistart=0
wanif=0

chillihotplug="/etc/hotplug.d/iface/30-chilli"
chillirc="/etc/init.d/chilli"
netconfig="/etc/config/network"

echo -n "$chillihotplug: "
if [ -f "$chillihotplug" ]; then
  echo "found"
  chillistart=`grep $chillirc $chillihotplug | wc -l`
  echo -n "Manual chilli service start command in $chillihotplug: "
  if [ "$chillistart" -gt "0" ]; then
    echo "found"
  else
    echo "not found"
  fi
else
  echo "not found"
fi

echo -n "$chillirc: "
if [ -f "$chillirc" ]; then
  echo "found"
else
  echo "not found"
fi

echo -n "$netconfig: "
if [ -f "$netconfig" ]; then
  echo "found"
  echo -n "WAN interface in $netconfig: "
  wanif=`grep "'wan'" $netconfig | wc -l`
  if [ "$wanif" -gt "0" ]; then
    echo "yes"
  else
    echo "no"
  fi
else
  echo "not found"
fi

if [ "$wanif" -eq "0" ]; then
  echo "Enabling chilli: /etc/init.d/chilli enable"
  /etc/init.d/chilli enable
elif [ "$chillistart" -eq "0" ]; then
  echo "Enabling chilli: /etc/init.d/chilli enable"
  /etc/init.d/chilli enable
else
  echo "Disabling chilli service startup: /etc/init.d/chilli disable"
  echo "Keeping manual chilli startup in $chillihotplug"
  /etc/init.d/chilli disable
fi

#/etc/init.d/chilli start
#/etc/init.d/cron restart

reboot
