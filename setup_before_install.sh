#!/bin/bash
echo "-- Configure and optimize the OS"
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.d/rc.local
echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >> /etc/rc.d/rc.local

echo '-- disable tuned'
systemctl disable tuned
systemctl stop tuned

echo '-- set vm.swappiness = 1'
sed -i '/vm.swappiness/d' /etc/sysctl.conf
echo  "vm.swappiness = 1" >> /etc/sysctl.conf
sysctl vm.swappiness=1
chmod 755 /etc/rc.d/rc.local

#timedatectl set-timezone UTC
echo "-- Set Timezone Asia/Seoul"
timedatectl set-timezone Asia/Seoul

echo "-- Diabled firewalld"
systemctl disable firewalld
systemctl stop firewalld
echo "-- Diabled selinux"
setenforce 0
sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

if [ "`ulimit -n`" -lt "65536" ]; then
  echo "-- Set open files : 1048576"
  ulimit -n 1048576
  echo "* hard nofile 1048576" >> /etc/security/limits.conf
  echo "* soft nofile 1048576" >> /etc/security/limits.conf
fi

if [ "`ulimit -u`" -lt "65536" ]; then
  echo "-- Set max user processes : 65536"
  ulimit -u 65536
  echo "* hard nproc 65536" >> /etc/security/limits.conf
  echo "* soft nproc 65536" >> /etc/security/limits.conf
fi

NTP_SERVER_ADDRESS=141.223.182.106
if [ "${NTP_SERVER_ADDRESS}" != "" ]; then
  echo "-- Disable chronyd"
  systemctl disable chronyd
  systemctl stop chronyd
  echo "-- Install NTP"
  yum install -y ntp
  echo "-- set NTP server : ${NTP_SERVER_ADDRESS}"
  sed -ri "/^server / { x; /./ d; s/^.*$/server ${NTP_SERVER_ADDRESS} iburst/ }" /etc/ntp.conf
  systemctl start ntpd
fi