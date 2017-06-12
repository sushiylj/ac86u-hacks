# 华硕RT-AC86U 路由 临时 ss 解决方案

在merlin固件之前的临时解决方案。

## 使用方法

首先进入路由管理界面，打开SSH功能，接下的操作都在ssh下进行。

1. 开启 jffs

```
nvram set jffs2_on=1
nvram set jffs2_enable=1
nvram set jffs2_format=1
nvram set jffs2_scripts=1
nvram set jffs2_exec="/jffs/jffs.autorun"
nvram commit
reboot
```

2. 安装 entware-ng 和 shadowsocks

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

3. 下载需要的文件

```
mkdir -p /jffs/ss/
wget --no-check-certificate --timeout=8 -qO - https://raw.githubusercontent.com/guolinke/ac86u-hacks/master/black.txt > /jffs/ss/black.txt
wget --no-check-certificate --timeout=8 -qO - https://raw.githubusercontent.com/guolinke/ac86u-hacks/master/white_ip_list.txt > /jffs/ss/white_ip_list.txt
wget --no-check-certificate --timeout=8 -qO - https://raw.githubusercontent.com/guolinke/ac86u-hacks/master/start_ss.sh > /jffs/ss/start_ss.sh
wget --no-check-certificate --timeout=8 -qO - https://raw.githubusercontent.com/guolinke/ac86u-hacks/master/stop_ss.sh > /jffs/ss/stop_ss.sh
chmod +x /jffs/ss/start_ss.sh
chmod +x /jffs/ss/stop_ss.sh
```


4. 编辑 `/jffs/ss/start_ss.sh`, 写上你自己的ss账号 (``ss_basic_server, ss_basic_password, ss_basic_port, ss_basic_method``) . 
注意： ``ss_basic_server`` 只支持ip 

6. 添加开机启动

```
cat << EOF > /jffs/jffs.autorun
#!/bin/sh
mount -o bind /jffs/opt /opt
/opt/etc/init.d/rc.unslung start
sh -x /jffs/ss/start_ss.sh &
EOF

chmod +x /jffs/jffs.autorun
```

7. 重启，ss会自动开机启动。

## 存在问题

这个固件不支持ipset，所以用的大陆ip段+白名单模式。由于cdn的动态ip问题，所以可能会有部分国内网站走的ss通道。
