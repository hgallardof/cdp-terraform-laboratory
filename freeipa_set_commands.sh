# yum install krb5-workstation krb5-libs -y
# # if Red Hat IPA is used as the KDC
# yum install freeipa-client -y

#Remove IPV6 from 
source /etc/profile
echo net.ipv6.conf.all.disable_ipv6 = 1 >> /etc/sysctl.conf
echo net.ipv6.conf.default.disable_ipv6 = 1 >> /etc/sysctl.conf
echo net.ipv6.conf.lo.disable_ipv6 = 1 >> /etc/sysctl.conf
sysctl -p

pass_ipa="B@dPassw0rd!"
domain="laboratory.cloudera.net"
realm="LABORATORY.CLOUDERA.NET"
reverse_zone="1.0.10"
host_ip=$(hostname -i)
host_name="$(hostname).$domain"

sudo /usr/bin/hostnamectl set-hostname ${host_name}
sudo yum install freeipa-server -y
sudo yum install -y ipa-server-dns bind-dyndb-ldap

sudo sed -i "s/search/#search/g" /etc/resolv.conf
sudo sed -i "s/nameserver/#nameserver/g" /etc/resolv.conf

echo "search laboratory.cloudera.net
nameserver $(hostname -i)" | sudo tee -a /etc/resolv.conf

nohup sudo ipa-server-install --domain ${domain} --realm ${realm} \
    --reverse-zone=${reverse_zone}.in-addr.arpa. \
    --no-forwarders \
    --no-ntp \
    --setup-dns \
    --ds-password ${pass_ipa} \
    --admin-password ${pass_ipa} \
    --unattended  > /tmp/ipa-server-install.out 2> /tmp/ipa-server-install.err &

