#!/bin/bash
if [ $(id -u) -ne 0 ]; then
  printf "This script must be run as root. \n"
  exit 1
fi


function confLoop {

  echo "Please copy your openVPN keys to piKEYS folder now, then type: done and press enter to continue"
  read confirmation
  echo "$confirmation"
  if [ "$confirmation" == "done" ]; then
    userConf
  else
    confLoop
  fi

}
function routings {
  echo -e '\n#Enable IP Routing\nnet.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
  sudo sysctl -p
  sudo iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
  sudo iptables -A FORWARD -i tun0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
  sudo iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT
  sudo iptables -A OUTPUT -o tun0 -m comment --comment "vpn" -j ACCEPT
  sudo iptables -A OUTPUT -o eth0 -p icmp -m comment --comment "icmp" -j ACCEPT
  sudo iptables -A OUTPUT -d 192.168.1.0/24 -o eth0 -m comment --comment "lan" -j ACCEPT
  sudo iptables -A OUTPUT -o eth0 -p udp -m udp --dport 1198 -m comment --comment "openvpn" -j ACCEPT
  sudo iptables -A OUTPUT -o eth0 -p tcp -m tcp --sport 22 -m comment --comment "ssh" -j ACCEPT
  sudo iptables -A OUTPUT -o eth0 -p udp -m udp --dport 123 -m comment --comment "ntp" -j ACCEPT
  sudo iptables -A OUTPUT -o eth0 -p udp -m udp --dport 53 -m comment --comment "dns" -j ACCEPT
  sudo iptables -A OUTPUT -o eth0 -p tcp -m tcp --dport 53 -m comment --comment "dns" -j ACCEPT
  sudo iptables -A OUTPUT -o eth0 -j DROP
  sudo apt-get install iptables-persistent -y
  sudo netfilter-persistent save
  sudo systemctl enable netfilter-persistent
}
function userConf {
  cp ./piKEYS/ca.rsa.2048.crt ./piKEYS/crl.rsa.2048.pem /etc/openvpn/
  cp ./vpnconf.ovpn /etc/openvpn/piVPN.conf

  echo "Please type your vpn username"
  read VPNusername

  echo "Please type password for user $VPNusername"
  read VPNpassword
  echo $VPNusername >> /etc/openvpn/login
  echo $VPNpassword >> /etc/openvpn/login
  sudo chmod 600 /etc/openvpn/login
  sudo nano /etc/openvpn/piVPN.conf
}
if [$1 -eq 1]; then
  routings
  exit
fi
apt-get update
apt-get install -y openvpn unzip
mkdir piKEYS
confLoop
