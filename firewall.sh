#! /bin/bash

DEFAULT_CHAINS=("INPUT" "OUTPUT" "FORWARD")
LAN_IFACE="eno1"
VALID_TCP_PORTS=("22")

#---------shortcut to resetting the default policy---------
if [ "$1" = "reset" ]
then
  iptables -P INPUT ACCEPT
  iptables -P OUTPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -X
  iptables -F
  echo "Firewall rules reset!"
  exit 0
fi

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

#----user-defined chains-------

#------------allow DNS and DHCP traffic-------------------
iptables -I INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -I OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# iptables -A OUTPUT -o eth0 -p udp --dport 67:68 --sport 67:68 -j ACCEPT

iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

iptables -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT

# #----------ACCEPT packets on www----------------------
# iptables -A INPUT -p tcp --dport 80 -j ACCEPT
# iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT


# #inbound/outbound UDP packets on allowed ports
# iptables -A FORWARD -p UDP -m multiport --sport "$VALID_UDP_PORTS" -j ACCEPT
# iptables -A FORWARD -p UDP -m multiport --dport "$VALID_UDP_PORTS" -j ACCEPT


# Permit inbound/outbound ssh packets
# Permit inbound/outbound www packets
# Drop inbound traffic to port 80 (http) from source ports less than 1024
# Drop all incoming packets from reserved port 0 as well as outbound traffic to port 0

iptables -L -n