# ac86u-hacks

A temporary solution before merlin firmware.

## How to use

1. enable jffs

```
nvram set jffs2_on=1
nvram set jffs2_enable=1
nvram set jffs2_format=1
nvram set jffs2_scripts=1
nvram set jffs2_exec="/jffs/jffs.autorun"
nvram commit
reboot
```

2. install entware-ng and shadowsocks

```
cat << EOF > /jffs/jffs.autorun
#!/bin/sh
mount -o bind /jffs/opt /opt
/opt/etc/init.d/rc.unslung start
EOF

chmod +x /jffs/jffs.autorun

mount -o bind /jffs/opt /opt
wget -O - http://pkg.entware.net/binaries/armv7/installer/entware_install.sh | sh

opkg install shadowsocks-libev

reboot
```

3. Download scripts

```
mkdir -p /jffs/ss/
wget --no-check-certificate --timeout=8 -qO - https://raw.githubusercontent.com/guolinke/ac86u-hacks/master/black.txt > /jffs/ss/black.txt
wget --no-check-certificate --timeout=8 -qO - https://raw.githubusercontent.com/guolinke/ac86u-hacks/master/white_ip_list.txt > /jffs/ss/white_ip_list.txt
wget --no-check-certificate --timeout=8 -qO - https://raw.githubusercontent.com/guolinke/ac86u-hacks/master/start_ss.sh > /jffs/ss/start_ss.sh
wget --no-check-certificate --timeout=8 -qO - https://raw.githubusercontent.com/guolinke/ac86u-hacks/master/stop_ss.sh > /jffs/ss/stop_ss.sh
chmod +x /jffs/ss/start_ss.sh
chmod +x /jffs/ss/stop_ss.sh
```


4. Edit `/jffs/ss/start_ss.sh` with your own ss server (``ss_basic_server, ss_basic_password, ss_basic_port, ss_basic_method``) . Note: ``ss_basic_server`` only support ip.

6. Add auto-start when power on

```
cat << EOF > /jffs/jffs.autorun
#!/bin/sh
mount -o bind /jffs/opt /opt
/opt/etc/init.d/rc.unslung start
sh -x /jffs/ss/start_ss.sh &
EOF

chmod +x /jffs/jffs.autorun
```

7. Reboot. And the SS will auto start.
