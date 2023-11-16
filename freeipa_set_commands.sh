pass_ipa="Cloudera.2023"
domain="laboratory.cloudera.net"
realm="LABORATORY.CLOUDERA.NET"
reverse_zone="1.0.10"

sudo yum install freeipa-server -y
sudo yum install -y ipa-server-dns bind-dyndb-ldap

# sudo sed -i "s/search/#search/g" /etc/resolv.conf
# sudo sed -i "s/nameserver/#nameserver/g" /etc/resolv.conf

# echo "search laboratory.cloudera.net
# nameserver $(hostname -i)" | sudo tee -a /etc/resolv.conf

sudo ipa-server-install --domain ${domain} --realm ${realm} \
    --reverse-zone=${reverse_zone}.in-addr.arpa. \
    --no-forwarders \
    --no-ntp \
    --setup-dns \
    --ds-password ${pass_ipa} \
    --admin-password ${pass_ipa} \
    --unattended

