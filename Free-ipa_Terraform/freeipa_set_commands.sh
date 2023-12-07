pass_ipa="Cloudera.2023"
domain="internal.cloudapp.net"
realm="INTERNAL.CLOUDAPP.NET"
reverse_zone="0.0.10"

sudo hostname $(hostname).$domain
sudo yum install freeipa-server -y
sudo yum install -y ipa-server-dns bind-dyndb-ldap
# sudo sed -i "s/internal.cloudapp.net/laboratory.cloudera.net/g" /etc/hostname;hostname; sudo ipa-client-install
# sudo sed -i "s/search/#search/g" /etc/resolv.conf
sudo sed -i "s/nameserver/#nameserver/g" /etc/resolv.conf
echo "nameserver $(hostname -i)" | sudo tee -a /etc/resolv.conf

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

