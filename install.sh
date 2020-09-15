#!/bin/sh
# installs OpenVPN on a Google Cloud Virtual Machine with portforwarding enabled
read -p "Continue (y/n)?" choice
case "$choice" in 
  y|Y ) 
    apt-get install -y openvpn libssl-dev wget iptables;
    wget -O /etc/openvpn/server.conf https://pastebin.com/raw/SrYcJGhK --no-check-certificate;
    systemctl enable openvpn@server
    systemctl start openvpn@server
    # Add the following iptables rule so that traffic can leave the VPN. Change the eth0 with the public network interface of your server
    iptables -t nat -A POSTROUTING -s 10.10.110.0/24 -o ens4 -j MASQUERADE
    1f [ -f /etc/rc.local ]; then 
    sed -i 's|^exit 0|iptables -t nat -A POSTROUTING -s 10.10.110.0/24 -o ens4 -j MASQUERADE\n\nexit 0|' /etc/rc.local;
    else
    cat << EOF > /etc/rc.local
    #!/bin/sh -e
    iptables -t nat -A POSTROUTING -s 10.10.110.0/24 -o ens4 -j MASQUERADE
    exit 0
    EOF
    chmod +x /etc/rc.local
    fi
    # Allow IP forwarding
    sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
    echo 1 > /proc/sys/net/ipv4/ip_forward
    systemctl enable rc-local;;
  n|N ) echo "Skipping";;
  * ) echo "Bad answer";;
esac

read -p "Continue (y/n)?" choice
case "$choice" in 
  y|Y ) wget -O sickvpn.conf https://pastebin.com/raw/yvNnT0uF --no-check-certificate && openvpn sickvpn.conf&;
  n|N ) echo "Skipping";;
  * ) echo "Bad answer";;
esac   
exit 0
