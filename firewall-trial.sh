#! /bin/bash

DEFAULT_CHAINS=("INPUT" "OUTPUT")
LAN_IFACE="eno1"
VALID_TCP_PORTS="80,443"

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


iptables -A INPUT -p tcp -s 192.168.0.0/24 --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -s 192.168.0.18 --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

iptables -L -n