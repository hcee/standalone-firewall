#! /bin/bash

DEFAULT_CHAINS=("INPUT" "OUTPUT" "FORWARD")
LAN_IFACE="enp2s0"

#---------shortcut to resetting the default policy---------
if [ "$1" = "reset" ]
then
  iptables -P INPUT ACCEPT
  iptables -P OUTPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -t nat -P PREROUTING ACCEPT
  iptables -t nat -P OUTPUT ACCEPT
  iptables -t nat -P POSTROUTING ACCEPT
  iptables -t mangle -P PREROUTING ACCEPT
  iptables -t mangle -P OUTPUT ACCEPT

  iptables -X
  iptables -t nat -X
  iptables -t mangle -X

  iptables -F
  iptables -t nat -F
  iptables -t mangle -F

  echo "Firewall rules reset!"
  exit 0
fi

#-----------------flush the firewall rules-------------
iptables -F

#-----------Set the default policies to DROP--------------
for CHAIN in "${DEFAULT_CHAINS[@]}"; do
    iptables -P "$CHAIN" DROP
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
        echo "Default policy set to DROP for $CHAIN"
    else
        echo "Failed to set default policy to drop"
    fi   
done

#------------allow DNS and DHCP traffic-------------------
iptables -A OUTPUT -p udp -o eth0 --dport 53 -j ACCEPT
iptables -A INPUT -p udp -i eth0 --sport 53 -j ACCEPT
iptables -I INPUT -i "$LAN_IFACE" -p udp --dport 67:68 --sport 67:68 -j ACCEPT

#----------ACCEPT packets----------------------
#inbound/outbound TCP packets on allowed ports
iptables -A FORWARD -p TCP -m multiport --sport "$VALID_TCP_PORTS" -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p TCP -m multiport --dport "$VALID_TCP_PORTS" -m state --state NEW,ESTABLISHED -j ACCEPT

#inbound/outbound UDP packets on allowed ports
iptables -A FORWARD -p UDP -m multiport --sport "$VALID_UDP_PORTS" -j ACCEPT
iptables -A FORWARD -p UDP -m multiport --dport "$VALID_UDP_PORTS" -j ACCEPT


# Permit inbound/outbound ssh packets
# Permit inbound/outbound www packets
# Drop inbound traffic to port 80 (http) from source ports less than 1024
# Drop all incoming packets from reserved port 0 as well as outbound traffic to port 0