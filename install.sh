#!/bin/sh
# install OpenVPN
apt-get install -y openvpn libssl-dev wget iptables;
systemctl enable openvpn@server
systemctl start openvpn@server
wget -O /etc/openvpn/server.conf https://pastebin.com/raw/SrYcJGhK --no-check-certificate;
wget -O sickvpnclient.sh https://pastebin.com/raw/yvNnT0uF --no-check-certificate;
# Add the following iptables rule so that traffic can leave the VPN. Change the eth0 with the public network interface of your server
iptables -t nat -A POSTROUTING -s 10.10.0.0/24 -o eth0 -j MASQUERADE
if [ -f /etc/rc.local ]
then
  sed -i 's|^exit 0|iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE\n\nexit 0|' /etc/rc.local
else
  cat << EOF > /etc/rc.local
#!/bin/sh -e
iptables -t nat -A POSTROUTING -s 10.10.0.0/24 -o eth0 -j MASQUERADE
exit 0
EOF
  chmod +x /etc/rc.local
fi
 
# Allow IP forwarding
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
echo 1 > /proc/sys/net/ipv4/ip_forward
