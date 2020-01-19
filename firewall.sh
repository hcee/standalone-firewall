#! /bin/bash

DEFAULT_CHAINS=("OUTPUT" "INPUT" "FORWARD")
VALID_TCP_PORTS="80,443"

#---------shortcut to resetting the default policy---------
if [ "$1" = "reset" ]
then
  iptables -P INPUT ACCEPT
  iptables -P OUTPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -X
  iptables -F
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

# Drop inbound traffic to port 80 (http) from source ports less than 1024
iptables -A INPUT -p tcp -s 192.168.0.0/24 --sport 0:1023 --dport 80 -j DROP

# #------------allow DNS and DHCP traffic-------------------
iptables -I INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -I OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

iptables -A OUTPUT -o eth0 -p udp --dport 67:68 --sport 67:68 -j ACCEPT

#------------------Permit inbound/outbound ssh packets-------------
iptables -A INPUT -p tcp -s 192.168.0.0/24 --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT #working now!!!!!
iptables -A OUTPUT -p tcp -d 192.168.0.0/24 --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT #--this is for sure correct

iptables -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT #---this works for sure as well


#----------Permit inbound/outbound www packets---------------------
iptables -A INPUT -p tcp -m multiport --dport "$VALID_TCP_PORTS" -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dport "$VALID_TCP_PORTS" -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT #---this works also.



# Drop all incoming packets from reserved port 0 as well as outbound traffic to port 0

iptables -L -n