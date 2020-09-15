#!/bin/sh
# installs OpenVPN on a Google Cloud Virtual Machine with portforwarding enabled
read -p "Install Server (y/n)?" choice
case "$choice" in 
  y|Y ) 
    apt-get install -y openvpn libssl-dev wget iptables
    wget -O /etc/openvpn/server.conf https://pastebin.com/raw/SrYcJGhK --no-check-certificate
    systemctl enable openvpn@server
    systemctl start openvpn@server
    # Add the following iptables rule so that traffic can leave the VPN. Change the eth0 with the public network interface of your server
    iptables -t nat -A POSTROUTING -s 10.10.110.0/24 -o ens4 -j MASQUERADE
    chmod +x /etc/rc.local;
    fi
    # Allow IP forwarding
    sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
    echo 1 > /proc/sys/net/ipv4/ip_forward;;
  n|N ) echo "Skipping";;
  * ) echo "Bad answer";;
esac
read -p "Install and run client (y/n)?" choice
case "$choice" in 
  y|Y ) wget -O sickvpn.conf https://pastebin.com/raw/yvNnT0uF --no-check-certificate && openvpn sickvpn.conf&;;
  n|N ) echo "Skipping";;
  * ) echo "Bad answer";;
esac   
exit 0
