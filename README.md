# standalone-firewall
COMP 8006 - Winter 2020 - Assignment 1

12:11:07(master)root@datacomm-192-168-0-4:standalone-firewall$ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp2s0: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether b4:96:91:51:ca:f5 brd ff:ff:ff:ff:ff:ff
    inet 192.168.11.1/24 brd 192.168.11.255 scope global enp2s0
       valid_lft forever preferred_lft forever
3: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether e4:b9:7a:ef:21:7a brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.4/24 brd 192.168.0.255 scope global dynamic noprefixroute eno1
       valid_lft 18959sec preferred_lft 18959sec
    inet6 fe80::c9f6:7b4e:7309:ccfb/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever

12:11:51(master)root@datacomm-192-168-0-4:standalone-firewall$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.0.100   0.0.0.0         UG    20100  0        0 eno1
192.168.0.0     0.0.0.0         255.255.255.0   U     100    0        0 eno1