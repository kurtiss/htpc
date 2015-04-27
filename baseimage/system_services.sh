#!/bin/bash
set -e
source /build/buildconfig
set -x

## Install init process.
cp /build/bin/my_init /sbin/
mkdir -p /etc/my_init.d
mkdir -p /etc/container_environment
touch /etc/container_environment.sh
touch /etc/container_environment.json
chmod 700 /etc/container_environment

groupadd -g 8377 docker_env
chown :docker_env /etc/container_environment.sh /etc/container_environment.json
chmod 640 /etc/container_environment.sh /etc/container_environment.json
ln -s /etc/container_environment.sh /etc/profile.d/

# Install runit + hack
$minimal_apt_get_install wget
wget http://launchpadlibrarian.net/86390097/runit_2.1.1-6.2ubuntu2_armhf.deb
dpkg --unpack runit_2.1.1-6.2ubuntu2_armhf.deb
sed -i -e :a -e '$d;N;2,16ba' -e 'P;D' /var/lib/dpkg/info/runit.postinst
dpkg --configure runit
rm runit_2.1.1-6.2ubuntu2_armhf.deb

## Install a syslog daemon.
$minimal_apt_get_install syslog-ng-core
mkdir -p /etc/service/syslog-ng
cp /build/runit/syslog-ng /etc/service/syslog-ng/run
mkdir -p /var/lib/syslog-ng
cp /build/config/syslog_ng_default /etc/default/syslog-ng
touch /var/log/syslog
chmod u=rw,g=r,o= /var/log/syslog
# Replace the system() source because inside Docker we can't access /proc/kmsg.
sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf

## Install syslog to "docker logs" forwarder.
mkdir -p /etc/service/syslog-forwarder
cp /build/runit/syslog-forwarder /etc/service/syslog-forwarder/run

## Install logrotate.
$minimal_apt_get_install logrotate
cp /build/config/logrotate_syslogng /etc/logrotate.d/syslog-ng

## Install the SSH server.
$minimal_apt_get_install openssh-server
mkdir -p /var/run/sshd
mkdir -p /etc/service/sshd
touch /etc/service/sshd/down
cp /build/runit/sshd /etc/service/sshd/run
cp /build/config/sshd_config /etc/ssh/sshd_config
cp /build/00_regen_ssh_host_keys.sh /etc/my_init.d/

## Install default SSH key for root and app.
mkdir -p /root/.ssh
chmod 700 /root/.ssh
chown root:root /root/.ssh
cp /build/insecure_key.pub /etc/insecure_key.pub
cp /build/insecure_key /etc/insecure_key
chmod 644 /etc/insecure_key*
chown root:root /etc/insecure_key*
cp /build/bin/enable_insecure_key /usr/sbin/

## Install cron daemon.
$minimal_apt_get_install cron
mkdir -p /etc/service/cron
chmod 600 /etc/crontab
cp /build/runit/cron /etc/service/cron/run

## Remove useless cron entries.
# Checks for lost+found and scans for mtab.
rm -f /etc/cron.daily/standard