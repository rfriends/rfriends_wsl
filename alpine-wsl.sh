#!/bin/sh
# alpine on wsl
# 2025/08/20
#
user=alpine

echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
adduser $user -s /bin/bash 
addgroup $user wheel
#----------------------------------------
apk update
apk upgrade --no-cache

apk add --no-cache tzdata sudo git bash bash-completion
apk add --no-cache openrc icu-libs icu-data-full
apk add --update busybox-suid

sed -i 's/^tty3/#tty3/g' /etc/inittab
sed -i 's/^tty4/#tty4/g' /etc/inittab
sed -i 's/^tty5/#tty5/g' /etc/inittab
sed -i 's/^tty6/#tty6/g' /etc/inittab
#----------------------------------------
install -Dm 644 /usr/share/zoneinfo/Asia/Tokyo /etc/zoneinfo/Asia/Tokyo
export TZ='Asia/Tokyo'
echo "export TZ='$TZ'" >> /etc/profile.d/timezone.sh
apk del tzdata
#----------------------------------------
cat << EOF > /etc/wsl.conf
[user]
default=$user

[interop]
appendWindowsPath=false

[boot]
command = "/usr/bin/env -i /usr/bin/unshare --pid --mount-proc --fork --propagation private -- sh -c 'exec /sbin/init'"
EOF
#
echo '%wheel ALL=(ALL) NOPASSWD: /usr/bin/nsenter' >> /etc/sudoers.d/wheel

cat << 'EOF' > /etc/profile.d/wsl-init.sh
#!/bin/bash

# Get PID of /sbin/init
sleep 1
pid="$(ps -o pid,args | awk '$2 ~ /\/sbin\/init/ {print $1}')"

# Run WSL service script
if [ "$pid" -ne 1 ]; then
  # Export ENV variables
  if [ "$USER" != "root" ]; then
    [ -f "$HOME/.openrc.env" ] && rm "$HOME/.openrc.env"
    export > "$HOME/.openrc.env"
  fi

  echo "Entering /sbin/init PID: $pid"
  exec sudo /usr/bin/nsenter -p -m -t "${pid}" -- su - "$USER"
fi

# Import ENV variables
if [ -f "$HOME/.openrc.env" ]; then
  set -a
  source "$HOME/.openrc.env"
  set +a
  rm "$HOME/.openrc.env"
fi
EOF
#----------------------------------------
# /etc/rc.conf
sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf
echo 'rc_provide="loopback net"' >> /etc/rc.conf
sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf
#----------------------------------------
cat << 'EOF' > /etc/local.d/rf3.start
#rc-service atd start
#rc-service samba start
#rc-service lighttpd start
crond
EOF

rc-update add local default
#-------------------------------------------------------
# thanks!
# https://zenn.dev/ignorant/articles/wsl2_alpine_docker
#-------------------------------------------------------
