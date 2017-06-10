#!/bin/sh

lan_ipaddr=$(nvram get lan_ipaddr)

rm -f /tmp/dnsmasq.d/black.conf

/sbin/service restart_dnsmasq

killall ss-tunnel
killall ss-redir

iptables -t nat -D PREROUTING -p udp --dport 53 -j DNAT --to $lan_ipaddr
iptables -t nat -D PREROUTING -p tcp -j SHADOWSOCKS

iptables -t nat -F SHADOWSOCKS 
iptables -t nat -X SHADOWSOCKS 

iptables -t nat -F SHADOWSOCKS_WHITELIST 
iptables -t nat -X SHADOWSOCKS_WHITELIST 

