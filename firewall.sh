#! /bin/bash

DEFAULT_CHAINS=("OUTPUT" "INPUT" "FORWARD")
VALID_TCP_PORTS="80,443"

#---------shortcut to resetting the default policy---------
if [ "$1" = "flush" ]; then
  iptables -F
  iptables -X
  iptables -P INPUT ACCEPT
  iptables -P OUTPUT ACCEPT
  iptables -P FORWARD ACCEPT
  echo -e "Firewall rules reset!"
  echo -e "-------------------------------------------\n"
  iptables -L -n
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
iptables -N ingress
iptables -N egress

# Drop all incoming packets from reserved port 0 as well as outbound traffic to port 0
iptables -A INPUT -p tcp --sport 0 -j DROP
iptables -A INPUT -p udp --sport 0 -j DROP
iptables -A INPUT -p tcp --dport 0 -j DROP
iptables -A INPUT -p udp --dport 0 -j DROP

iptables -A OUTPUT -p tcp --sport 0 -j DROP
iptables -A OUTPUT -p udp --sport 0 -j DROP
iptables -A OUTPUT -p tcp --dport 0 -j DROP
iptables -A OUTPUT -p udp --dport 0 -j DROP

#------------allow DNS and DHCP traffic-------------------
iptables -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp -m udp --sport 53 -j ACCEPT
iptables -A OUTPUT -o eth0 -p udp --dport 67:68 --sport 67:68 -j ACCEPT

iptables -A INPUT -p tcp -j ingress
iptables -A OUTPUT -p tcp -j egress

#------------------Permit inbound SSH-------------
iptables -A ingress -p tcp -s 192.168.0.0/24 --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A egress -p tcp -d 192.168.0.0/24 --sport 22 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# outbound ssh packets
iptables -A ingress -p tcp -s 192.168.0.0/24 --sport 22 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A egress -p tcp -d 192.168.0.0/24 --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# Drop inbound traffic to port 80 (http) from source ports less than 1024
iptables -A ingress -p tcp -m tcp --sport 0:1023 --dport 80 -j DROP

#----------Permit inbounds WWW---------------------
iptables -A ingress -p tcp -m multiport --dport "$VALID_TCP_PORTS" -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT 
iptables -A egress -p tcp -m multiport --sport "$VALID_TCP_PORTS" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# outbound www packet
iptables -A ingress -p tcp -m multiport --sport "$VALID_TCP_PORTS" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 
iptables -A egress -p tcp -m multiport --dport "$VALID_TCP_PORTS" -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# Drop all inbound SYN packets
iptables -A INPUT -p tcp --syn -j DROP

iptables -L -n