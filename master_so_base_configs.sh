#!/bin/bash

#####################
# SO Configs        #
#####################
echo "vm.swappiness = 1" >> /etc/sysctl.conf
echo 1 > /proc/sys/vm/swappiness
systemctl restart chronyd
systemctl status firewalld.service
systemctl stop firewalld.service
systemctl disable firewalld.service
selinuxenabled || echo "disabled"
sestatus 
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
echo "sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux"	>> /etc/rc.local 
# reboot

#Según mi sistema operativo, estos dos componentes no existen, no se pueden configurar
#service cups status && chkconfig cups off
service postfix status && chkconfig postfix off

echo never > /sys/kernel/mm/transparent_hugepage/defrag 
echo never > /sys/kernel/mm/transparent_hugepage/enabled

#Set HOSTNAME 
new_domain=internal.cloudapp.net
new_name=$(hostname)
hostname $new_name.$new_domain

#####################
# Install software  #
#####################

#Install WGET
yum install wget -y

#python 
ln -s /bin/python2 /bin/python
#yum install python39 -y

#Instal JDK
#yum install java-1.8.0-openjdk -y
yum install java-1.8.0-openjdk-devel.x86_64 -y
# ls -l /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.382.b05-2.el8.x86_64/jre
# echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.382.b05-2.el8.x86_64/jre" >> /etc/profile

#Disabling IPV6
source /etc/profile
echo net.ipv6.conf.all.disable_ipv6 = 1 >> /etc/sysctl.conf
echo net.ipv6.conf.default.disable_ipv6 = 1 >> /etc/sysctl.conf
echo net.ipv6.conf.lo.disable_ipv6 = 1 >> /etc/sysctl.conf
sysctl -p

echo "
NETWORKING_IPV6=no
IPV6INIT=no
" >> /etc/sysconfig/network

# REDHAD 8.4 <
service fapolicyd status

#######################
"""
Cloudera  recommends   to   disable  fapolicyd  daemon  present  in  RHEL 8.4
systems before beginning installation  of Cloudera  Manager  application.  Be
informed  that  fapolicyd  is  a  user space daemon  that  determines  access
rights  to  files based on attributes of the process and file. It can be used
to  either  blacklist  or  whitelist  processes  or file access. Proceed with
caution  with enforcing the use of this daemon.  Improper  configuration  may
render the system non-functional.
"""


# If yo have kerberos + FreeIPA
# # if Red Hat IPA is used as the KDC
yum install krb5-workstation krb5-libs freeipa-client -y


sudo mkfs -t ext4 /dev/sdc
sudo mkfs -t ext4 /dev/sdd
sudo mkfs -t ext4 /dev/sde

sudo mkdir /nn
sudo mkdir /zk
sudo mkdir /nn2

sudo mount /dev/sdc /nn
sudo mount /dev/sdd /zk
sudo mount /dev/sde /nn2

echo "/dev/sdc /nn ext4 noatime,discard 0 0
/dev/sdd /zk ext4 noatime,discard 0 0
/dev/sde /nn2 ext4 noatime,discard 0 0" | sudo tee -a /etc/fstab


#########################
#$ WORKING ON MASTER 0 $#
#########################

check_master0="vm-master-0"
if [[ "$(hostname)" == *"$check_master0"* ]]
then
    #CREATE CLOUDERA-MANAGER.REPO
    echo "[cloudera-manager]
    name=Cloudera Manager $CM_VERSION
    baseurl=https://$USER:$PASS@archive.cloudera.com/p/cm7/$CM_VERSION/$SO_VERSION/yum/
    gpgkey=https://$USER:$PASS@archive.cloudera.com/p/cm7/$CM_VERSION/$SO_VERSION/yum/RPM-GPG-KEY-cloudera
    gpgcheck=1
    enabled=1
    autorefresh=0
    type=rpm-md" | sudo tee -a /etc/yum.repos.d/cloudera-manager.repo

    #INSTALL MYSQL
    dnf module install mysql -y
    systemctl start mysqld
    systemctl enable --now mysqld
    systemctl status mysqld
fi 