#!/bin/sh

ss_basic_server="###"
ss_basic_password="###"
ss_basic_port="2047"
ss_basic_method="rc4-md5"
ss_local_port="7912"
ss_tunnel_port="7913"

# write config file
config_file=/tmp/ss.json

cat > $config_file <<-EOF
{
    "server":"$ss_basic_server",
    "server_port":$ss_basic_port,
    "local_port":$ss_local_port,
    "password":"$ss_basic_password",
    "timeout":600,
    "method":"$ss_basic_method"
}
EOF

wan_ip=$(nvram get wan0_ipaddr | cut -d"." -f1,2)
lan_ipaddr=$(nvram get lan_ipaddr)
wan_dns=$(nvram get wan0_dns|sed 's/ /\n/g'|grep -v 0.0.0.0|grep -v 127.0.0.1|sed -n 1p)
# default dns used for the china domins
default_dns="$wan_dns"
# Dns used for the black list
black_dns="8.8.8.8:53"

sed -i 's/cache-size=1500/cache-size=9999/g' /etc/dnsmasq.conf

echo "start to write dnsmasq"

# append gfw
for black_ip in `cat /jffs/ss/black.txt`;
do
	echo "server=/.${black_ip}/127.0.0.1#${ss_tunnel_port}" >> /tmp/resolv.dnsmasq
done

echo "finish write dnsmasq"

echo "start ss"
# start ss

ss-tunnel -b 0.0.0.0 -s $ss_basic_server -p $ss_basic_port -c $config_file -l ${ss_tunnel_port} -L "$black_dns" -u -f /var/run/ss_tunnel.pid
ss-redir -b 0.0.0.0 -c $config_file -f /var/run/shadowsocks.pid

/sbin/service restart_dnsmasq


echo "update iptables"
## update iptables

iptables -t nat -N SHADOWSOCKS
iptables -t nat -N SHADOWSOCKS_WHITELIST

# Ignore your shadowsocks server's addresses. It's very IMPORTANT, just be careful.
iptables -t nat -A SHADOWSOCKS -d ${ss_basic_server} -j RETURN


# Ignore LANs IP address
iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN
iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN

# Check whitelist
iptables -t nat -A SHADOWSOCKS -j SHADOWSOCKS_WHITELIST
iptables -t nat -A SHADOWSOCKS -m mark --mark 1 -j RETURN

# Anything else should be redirected to shadowsocks's local port
iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-ports ${ss_local_port}
# Apply the rules
iptables -t nat -A PREROUTING -p tcp -j SHADOWSOCKS

# Ignore China IP address
for white_ip in `cat /jffs/ss/white_ip_list.txt`;
do
    iptables -t nat -A SHADOWSOCKS_WHITELIST -d "${white_ip}" -j MARK --set-mark 1
done

# forward all DNS
iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to $lan_ipaddr

echo "finish update iptables"
