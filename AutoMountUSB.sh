#!/bin/bash
# 等待系统启动完成
sleep 30

# 卸载可能存在的自动挂载
umount /dev/sdr1 2>/dev/null
umount /volumeUSB2/usbshare 2>/dev/null

# 终止占用进程
fuser -k /dev/sdr1 2>/dev/null

# 挂载到目标路径
mount -o uid=1026,gid=100,umask=000 "UUID=BD3007CFA7AC53ED" /volume1/homes/USB

# 记录日志
if [ $? -eq 0 ]; then
    echo "$(date): USB硬盘成功挂载到 /volume1/homes/USB" >> /var/log/usb_mount.log
else
    echo "$(date): USB硬盘挂载失败" >> /var/log/usb_mount.log
fi