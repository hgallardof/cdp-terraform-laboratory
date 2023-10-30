# yum install krb5-workstation krb5-libs -y
# # if Red Hat IPA is used as the KDC
# yum install freeipa-client -y

pass_ipa="B@dPassw0rd!"
domain="laboratory.cloudera.net"
realm="LABORATORY.CLOUDERA.NET"
reverse_zone="1.0.0"
host_ip=$(hostname -i)
host_name="$(hostname).$domain"

sudo /usr/bin/hostnamectl set-hostname ${host_name}
dnf install freeipa-server -y
dnf install -y ipa-server-dns bind-dyndb-ldap

sudo ipa-server-install --domain ${domain} --realm ${realm} \
    --reverse-zone=${reverse_zone}.in-addr.arpa. \
    --no-forwarders \
    --no-ntp \
    --setup-dns \
    --ds-password ${pass_ipa} \
    --admin-password ${pass_ipa} \
    --unattended

