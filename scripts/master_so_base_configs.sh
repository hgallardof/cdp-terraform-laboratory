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
echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag 
echo never > /sys/kernel/mm/transparent_hugepage/enabled"	>> /etc/rc.local 

#Set HOSTNAME 
new_domain=$DOMAIN_TF
new_name=$(hostname)
hostname $new_name.$new_domain

#####################
# Install software  #
#####################

#Install WGET
yum install wget -y

#python 
ln -s /bin/python2 /bin/python
yum install python38 -y

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
yum install openldap-clients krb5-workstation krb5-libs freeipa-client -y


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
    
    #Install Server httpd
    sudo rm -rf /etc/yum.repos.d/cloudera-manager.repo
    yum install httpd -y
    mkdir -p /var/www/html/cloudera-repos/cm7/$CM_VERSION
    systemctl start httpd
    systemctl enable httpd

    #Descargar y cargar binarios al repo local server
    yum install wget -y
    wget https://$USER_REPO:$PASS@archive.cloudera.com/p/cm7/$CM_VERSION/repo-as-tarball/cm$CM_VERSION-redhat8.tar.gz
    tar xvfz cm$CM_VERSION-redhat8.tar.gz -C /var/www/html/cloudera-repos/cm7/$CM_VERSION --strip-components=1
    sudo chmod -R ugo+rX /var/www/html/cloudera-repos/cm7/$CM_VERSION

    echo "[cloudera-repo]
name=cloudera-repo
baseurl=http://$(hostname -i)/cloudera-repos/cm7/$CM_VERSION
enabled=1
gpgcheck=0" | sudo tee -a /etc/yum.repos.d/cloudera-manager.repo

    INSTALL MYSQL
    sudo dnf module install mysql -y
    sudo systemctl start mysqld
    sudo systemctl enable --now mysqld

    Installing Mysql jdbc connector
    wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.48.tar.gz
    tar zxvf mysql-connector-java-5.1.48.tar.gz
    sudo mkdir -p /usr/share/java/
    cd mysql-connector-java-5.1.48
    sudo cp mysql-connector-java-5.1.48-bin.jar /usr/share/java/mysql-connector-java.jar

    Set mysql password
    sudo yum -y install expect
    SECURE_MYSQL=$(expect -c "
    set timeout 10
    spawn mysql_secure_installation
    expect \"Press y|Y for Yes, any other key for No: \"
    send \"y\r\"
    expect \"Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG: \"
    send \"2\r\"
    expect \"New password: \" 
    send \"$PASS\r\"
    expect \"Re-enter new password: \"
    send \"$PASS\r\"
    expect \"Do you wish to continue with the password provided?(Press y|Y for Yes, any other key for No) : \"
    send \"y\r\"
    expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) : \"
    send \"y\r\"
    expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) : \"
    send \"y\r\"
    expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) : \"
    send \"y\r\"
    expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) : \"
    send \"y\r\"")

    mysql -u root -e "
        CREATE DATABASE scm DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
        CREATE DATABASE smm DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
        CREATE DATABASE rman DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
        CREATE DATABASE schemaregistry DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
        CREATE DATABASE rangeradmin DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
        CREATE DATABASE das DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
        CREATE DATABASE rangerkms DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
        CREATE DATABASE oozie DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
        CREATE DATABASE hue DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
        CREATE DATABASE hive DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

        CREATE USER 'scm'@'%' IDENTIFIED BY 'scm_2023_H';
        CREATE USER 'rman'@'%' IDENTIFIED BY 'rman_2023_H';
        CREATE USER 'ranger'@'%' IDENTIFIED BY 'ranger_2023_H';
        CREATE USER 'hue'@'%' IDENTIFIED BY 'hue_2023_H';
        CREATE USER 'hive'@'%' IDENTIFIED BY 'hive_2023_H';
        CREATE USER 'oozie'@'%' IDENTIFIED BY 'oozie_2023_H';
        CREATE USER 'das'@'%' IDENTIFIED BY 'das_2023_H';
        CREATE USER 'schemaregistry'@'%' IDENTIFIED BY 'schemaregistry_2023_H';
        CREATE USER 'smm'@'%' IDENTIFIED BY 'smm_2023_H';

        GRANT ALL PRIVILEGES ON rman.* TO 'rman'@'%';
        GRANT ALL PRIVILEGES ON scm.* TO 'scm'@'%';
        GRANT ALL PRIVILEGES ON rangeradmin.* TO 'ranger'@'%';
        GRANT ALL PRIVILEGES ON rangerkms.* TO 'ranger'@'%';
        GRANT ALL PRIVILEGES ON das.* TO 'das'@'%';
        GRANT ALL PRIVILEGES ON schemaregistry.* TO 'schemaregistry'@'%';
        GRANT ALL PRIVILEGES ON hue.* TO 'hue'@'%';
        GRANT ALL PRIVILEGES ON smm.* TO 'smm'@'%';
        GRANT ALL PRIVILEGES ON hive.* TO 'hive'@'%';
        GRANT ALL PRIVILEGES ON oozie.* TO 'oozie'@'%';
    "

    sudo yum install cloudera-manager-daemons -y
    sudo yum install cloudera-manager-agent cloudera-manager-server -y
    sudo service cloudera-scm-agent start
    sudo /opt/cloudera/cm/schema/scm_prepare_database.sh -h $(hostname -i) mysql scm scm scm_2023_H
    sudo service cloudera-scm-server start

    sudo yum -y remove expect

fi 
sudo /usr/bin/hostnamectl set-hostname $(hostname).$DOMAIN_TF
sudo ipa-client-install \
--domain=$DOMAIN_TF \
--server=$IPA_SERVER \
--principal=$IPA_USER \
--password=$IPA_PASS \
-N \
--fixed-primary \
-U