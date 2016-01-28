#Setup the Configurations

pineapplenetmask=255.255.255.0 # Default netmask for /24 network
pineapplenet=172.16.42.0/24 # Pineapple network. Default is 172.16.42.0/24
pineapplelan=XXX    # Interface of Ethernet cable connected to the laptop
pineapplewan=XXX    # Interface of the Pineapple connected to the laptop
pineapplegw=XXX     # The IP of the Internet Gateway
pineapplehostip=XXX #IP Address of host computer
pineappleip=172.16.42.1 # IP Address of the pineapple

#Bring up Ethernet Interface directly connected to Pineapple
ifconfig $pineapplelan $pineapplehostip netmask $pineapplenetmask up

#Enable IP Forwarding
echo '1' > /proc/sys/net/ipv4/ip_forward

#Clear the IPTables Chains and Rules
iptables -X
iptables -F

#Setup IP Forwarding
iptables -A FORWARD -i $pineapplewan -o $pineapplelan -s $pineapplenet -m state --state NEW -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A POSTROUTING -t nat -j MASQUERADE

#Remove the Default Route
route del default

#Add a new Default Gateway
route add default gw $pineapplegw $pineapplewan

#Modify the IPTables to enable proxying
iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
iptables -t nat -I OUTPUT -p tcp -d 127.0.0.1 --dport 80 -j REDIRECT --to-ports 8080
iptables -t nat -I PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 8080
iptables -t nat -I OUTPUT -p tcp -d 127.0.0.1 --dport 443 -j REDIRECT --to-ports 8080
