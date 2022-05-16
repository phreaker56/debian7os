#!/bin/sh

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;

# set time GMT +7
ln -fs /usr/share/zoneinfo/America/Managua /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# install openvpn
apt-get install openvpn iptables openssl ca-certificates -y
wget -O /etc/openvpn/openvpn.tar "https://raw.github.com/phreaker56/debian7os/master/openvpn-debian.tar"
cd /etc/openvpn/
tar xzf openvpn.tar
wget -O /etc/openvpn/1194.conf "https://raw.github.com/phreaker56/debian7os/master/1194.conf"
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
wget -O /etc/iptables.up.rules "https://raw.github.com/phreaker56/debian7os/master/iptables.up.rules"
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules
service openvpn restart

# configure openvpn client config
cd /etc/openvpn/
wget -O /etc/openvpn/1194-client.ovpn "https://raw.github.com/phreaker56/debian7os/master/1194-client.conf"
sed -i $MYIP2 /etc/openvpn/1194-client.ovpn;
PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
useradd -M -s /bin/false phreaker56
echo "phreaker56:$PASS" | chpasswd
echo "username" >> pass.txt
echo "password" >> pass.txt
tar cf client.tar 1194-client.ovpn pass.txt
cp client.tar /home/vps/public_html/
cd

# finishing
chown -R www-data:www-data /home/vps/public_html
service openvpn restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo ""  | tee -a log-install.txt
echo "AUTOSCRIPT INCLUDES" | tee log-install.txt
echo "===============================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Service"  | tee -a log-install.txt
echo "-------"  | tee -a log-install.txt
echo "OpenVPN  : TCP 1194 (client config : http://$MYIP:81/client.tar)"  | tee -a log-install.txt
echo "==============================================="  | tee -a log-install.txt
cd
rm -f /root/debian7.sh
