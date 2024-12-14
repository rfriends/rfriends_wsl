#!/bin/bash
# -----------------------------------------
# service for wsl
# -----------------------------------------
# 1.0 2024/11/13
# -----------------------------------------
# service
#
sudo grep mount.rc /etc/fstab
if [ $? = 1 ]; then
cat <<EOF | sudo tee -a /etc/fstab > /dev/null
#
# mount.rc
#
none none rc defaults 0 0
EOF
else echo "already exist"
fi

cat <<EOF | sudo tee /sbin/mount.rc > /dev/null
#!/bin/sh
#
# for non systemd (rfriends)
#
service lighttpd start
#service smbd start
service atd start
service cron start
#
EOF

sudo chmod +x /sbin/mount.rc
# -----------------------------------------
