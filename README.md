# openwrt_config_tlwr1043nd
initial commit /etc/config/
after installing applying setup.sh
modified files (from OpenWRT 15.05 Chaos Calmer - hotspotsystems.com)

# out1.txt
## __installing chaos calmer firmware to device__

# Setting Up routed AP over wireless Internetconnection with wireless DHCP

__WIFI AP(internetconnection)<wireless>openwrt 15.05(TLWR1043nd)<wireless>clients__

following steps on http://wiki.openwrt.org/doc/recipes/routedclient

```sh
$ uci del wireless.@wifi-device[0].disabled
$ uci del wireless.@wifi-iface[0].network
$ uci set wireless.@wifi-iface[0].mode=sta
$ uci commit wireless
$ wifi
```
