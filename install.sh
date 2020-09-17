#!/bin/sh
# installs OpenVPN on a Google Cloud Virtual Machine with portforwarding enabled

read -p "1.Client or 2.server installation (1/2)?" choice
case "$choice" in 
  1 )
	systemctl disable openvpn@server
	systemctl stop openvpn@server
	iptables -F INPUT
	iptables -F OUTPUT
	wget -O sickvpn.conf https://pastebin.com/raw/yvNnT0uF --no-check-certificate && openvpn sickvpn.conf&;;
  2 ) 
    apt-get install -y openvpn libssl-dev wget iptables python3-dev python3-pip
    pip3 install requests
    wget -O /etc/openvpn/server.conf https://pastebin.com/raw/SrYcJGhK --no-check-certificate
    python3 pingvpn.py
    systemctl enable openvpn@server
    systemctl start openvpn@server
    # Add the following iptables rule so that traffic can leave the VPN. Change the eth0 with the public network interface of your server
    iptables -t nat -A POSTROUTING -s 10.10.110.0/24 -o ens4 -j MASQUERADE
    # Allow IP forwarding
    sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
    echo 1 > /proc/sys/net/ipv4/ip_forward;;
  * ) echo "Bad answer";;      
exit 0
