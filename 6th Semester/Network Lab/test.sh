# Name : Sumit Kumar Yadav
# Roll No. : 18CS30042

#!/bin/bash

# check whether user is in sudo or not
if [[ $EUID -ne 0 ]]; then										
	echo "Please execute the code in 'sudo su' "		
	exit 1														
fi


# Declaration of the network namespace
ip netns add H1 	
ip netns add H2
ip netns add H3
ip netns add H4
ip netns add R1
ip netns add R2
ip netns add R3
ip netns add R4
ip netns add R5
ip netns add R6

# connection of the virtual ethernet pair
ip link add v1 type veth peer name v2 		
ip link add v3 type veth peer name v4  		
ip link add v5 type veth peer name v6  		
ip link add v7 type veth peer name v8 		
ip link add v9 type veth peer name v10 		
ip link add v11 type veth peer name v12		
ip link add v13 type veth peer name v14
ip link add v15 type veth peer name v16
ip link add v17 type veth peer name v18

# connect namespace with the ethernet
ip link set v1 netns H1
ip link set v2 netns R1
ip link set v3 netns R1
ip link set v4 netns R2
ip link set v5 netns R2
ip link set v6 netns R3
ip link set v7 netns R3
ip link set v8 netns H2
ip link set v9 netns R2
ip link set v10 netns R4
ip link set v11 netns R4
ip link set v12 netns R5
ip link set v13 netns R5
ip link set v14 netns H3
ip link set v15 netns R4
ip link set v16 netns R6
ip link set v17 netns R6
ip link set v18 netns H4


# Assign IP address range to each of the virtual ethernet like v1,v2..... corresponding to its network namespace
ip -n H1 addr add 10.10.10.42/24 dev v1
ip -n R1 addr add 10.10.10.43/24 dev v2
ip -n R1 addr add 10.10.20.42/24 dev v3
ip -n R2 addr add 10.10.20.43/24 dev v4 
ip -n R2 addr add 10.10.30.42/24 dev v5
ip -n R3 addr add 10.10.30.43/24 dev v6
ip -n R3 addr add 10.10.40.42/24 dev v7
ip -n H2 addr add 10.10.40.43/24 dev v8
ip -n R2 addr add 10.10.50.42/24 dev v9
ip -n R4 addr add 10.10.50.43/24 dev v10
ip -n R4 addr add 10.20.10.42/24 dev v11
ip -n R5 addr add 10.20.10.43/24 dev v12
ip -n R5 addr add 10.20.20.42/24 dev v13
ip -n H3 addr add 10.20.20.43/24 dev v14 
ip -n R4 addr add 10.30.10.42/24 dev v15
ip -n R6 addr add 10.30.10.43/24 dev v16
ip -n R6 addr add 10.30.20.42/24 dev v17
ip -n H4 addr add 10.30.20.43/24 dev v18


# Bring the IP link interfaces up
ip -n H1 link set v1 up
ip -n R1 link set v2 up
ip -n R1 link set v3 up
ip -n R2 link set v4 up
ip -n R2 link set v5 up
ip -n R3 link set v6 up
ip -n R3 link set v7 up
ip -n H2 link set v8 up
ip -n R2 link set v9 up
ip -n R4 link set v10 up
ip -n R4 link set v11 up
ip -n R5 link set v12 up
ip -n R5 link set v13 up
ip -n H3 link set v14 up
ip -n R4 link set v15 up
ip -n R6 link set v16 up
ip -n R6 link set v17 up
ip -n H4 link set v18 up


# Enable loop back interface for each namespace to check if you can ping a namespace’s own interfaces (sanity check)
ip -n H1 link set lo up
ip -n H2 link set lo up
ip -n H3 link set lo up
ip -n H4 link set lo up
ip -n R1 link set lo up
ip -n R2 link set lo up
ip -n R3 link set lo up
ip -n R4 link set lo up
ip -n R5 link set lo up
ip -n R6 link set lo up


# Enable IP forward to all the network namespace
ip netns exec H1 sysctl -w net.ipv4.ip_forward=1
ip netns exec H2 sysctl -w net.ipv4.ip_forward=1
ip netns exec H3 sysctl -w net.ipv4.ip_forward=1
ip netns exec H4 sysctl -w net.ipv4.ip_forward=1
ip netns exec R1 sysctl -w net.ipv4.ip_forward=1
ip netns exec R2 sysctl -w net.ipv4.ip_forward=1
ip netns exec R3 sysctl -w net.ipv4.ip_forward=1
ip netns exec R4 sysctl -w net.ipv4.ip_forward=1
ip netns exec R5 sysctl -w net.ipv4.ip_forward=1
ip netns exec R6 sysctl -w net.ipv4.ip_forward=1


# To check the route of any namespace
# ip -n N1 route
# Adding routes command to connect all inerfaces with namespaces
# routes from namespace H1
ip -n H1 route add 10.10.20.0/24 via 10.10.10.43 dev v1
ip -n H1 route add 10.10.30.0/24 via 10.10.10.43 dev v1
ip -n H1 route add 10.10.50.0/24 via 10.10.10.43 dev v1
ip -n H1 route add 10.10.40.0/24 via 10.10.10.43 dev v1
ip -n H1 route add 10.20.10.0/24 via 10.10.10.43 dev v1
ip -n H1 route add 10.30.10.0/24 via 10.10.10.43 dev v1
ip -n H1 route add 10.20.20.0/24 via 10.10.10.43 dev v1
ip -n H1 route add 10.30.20.0/24 via 10.10.10.43 dev v1

# routes from namespace H2
ip -n H2 route add 10.10.30.0/24 via 10.10.40.42 dev v8
ip -n H2 route add 10.10.20.0/24 via 10.10.40.42 dev v8
ip -n H2 route add 10.10.50.0/24 via 10.10.40.42 dev v8
ip -n H2 route add 10.10.10.0/24 via 10.10.40.42 dev v8
ip -n H2 route add 10.20.10.0/24 via 10.10.40.42 dev v8
ip -n H2 route add 10.30.10.0/24 via 10.10.40.42 dev v8
ip -n H2 route add 10.20.20.0/24 via 10.10.40.42 dev v8
ip -n H2 route add 10.30.20.0/24 via 10.10.40.42 dev v8

# routes from namespace H3
ip -n H3 route add 10.10.30.0/24 via 10.20.20.42 dev v14
ip -n H3 route add 10.10.20.0/24 via 10.20.20.42 dev v14
ip -n H3 route add 10.10.50.0/24 via 10.20.20.42 dev v14
ip -n H3 route add 10.10.10.0/24 via 10.20.20.42 dev v14
ip -n H3 route add 10.20.10.0/24 via 10.20.20.42 dev v14
ip -n H3 route add 10.30.10.0/24 via 10.20.20.42 dev v14
ip -n H3 route add 10.10.40.0/24 via 10.20.20.42 dev v14
ip -n H3 route add 10.30.20.0/24 via 10.20.20.42 dev v14

# routes from namespace H4
ip -n H4 route add 10.10.30.0/24 via 10.30.20.42 dev v18
ip -n H4 route add 10.10.20.0/24 via 10.30.20.42 dev v18
ip -n H4 route add 10.10.50.0/24 via 10.30.20.42 dev v18
ip -n H4 route add 10.10.10.0/24 via 10.30.20.42 dev v18
ip -n H4 route add 10.20.10.0/24 via 10.30.20.42 dev v18
ip -n H4 route add 10.30.10.0/24 via 10.30.20.42 dev v18
ip -n H4 route add 10.10.40.0/24 via 10.30.20.42 dev v18
ip -n H4 route add 10.20.20.0/24 via 10.30.20.42 dev v18

# routes from namespace R1
ip -n R1 route add 10.10.30.0/24 via 10.10.20.43 dev v3
ip -n R1 route add 10.10.50.0/24 via 10.10.20.43 dev v3
ip -n R1 route add 10.30.20.0/24 via 10.10.20.43 dev v3
ip -n R1 route add 10.20.10.0/24 via 10.10.20.43 dev v3
ip -n R1 route add 10.30.10.0/24 via 10.10.20.43 dev v3
ip -n R1 route add 10.10.40.0/24 via 10.10.20.43 dev v3
ip -n R1 route add 10.20.20.0/24 via 10.10.20.43 dev v3

# routes from namespace R3
ip -n R3 route add 10.10.20.0/24 via 10.10.30.42 dev v6
ip -n R3 route add 10.10.50.0/24 via 10.10.30.42 dev v6
ip -n R3 route add 10.30.20.0/24 via 10.10.30.42 dev v6
ip -n R3 route add 10.20.10.0/24 via 10.10.30.42 dev v6
ip -n R3 route add 10.30.10.0/24 via 10.10.30.42 dev v6
ip -n R3 route add 10.10.10.0/24 via 10.10.30.42 dev v6
ip -n R3 route add 10.20.20.0/24 via 10.10.30.42 dev v6

# routes from namespace R5
ip -n R5 route add 10.10.20.0/24 via 10.20.10.42 dev v12
ip -n R5 route add 10.10.50.0/24 via 10.20.10.42 dev v12
ip -n R5 route add 10.30.20.0/24 via 10.20.10.42 dev v12
ip -n R5 route add 10.10.40.0/24 via 10.20.10.42 dev v12
ip -n R5 route add 10.30.10.0/24 via 10.20.10.42 dev v12
ip -n R5 route add 10.10.10.0/24 via 10.20.10.42 dev v12
ip -n R5 route add 10.10.30.0/24 via 10.20.10.42 dev v12

# routes from namespace R6
ip -n R6 route add 10.10.20.0/24 via 10.30.10.42 dev v16
ip -n R6 route add 10.10.50.0/24 via 10.30.10.42 dev v16
ip -n R6 route add 10.20.20.0/24 via 10.30.10.42 dev v16
ip -n R6 route add 10.10.40.0/24 via 10.30.10.42 dev v16
ip -n R6 route add 10.20.10.0/24 via 10.30.10.42 dev v16
ip -n R6 route add 10.10.10.0/24 via 10.30.10.42 dev v16
ip -n R6 route add 10.10.30.0/24 via 10.30.10.42 dev v16

# routes from namespace R2
ip -n R2 route add 10.10.10.0/24 via 10.10.20.42 dev v4
ip -n R2 route add 10.10.40.0/24 via 10.10.30.43 dev v5
ip -n R2 route add 10.20.20.0/24 via 10.10.50.43 dev v9
ip -n R2 route add 10.30.20.0/24 via 10.10.50.43 dev v9
ip -n R2 route add 10.20.10.0/24 via 10.10.50.43 dev v9
ip -n R2 route add 10.30.10.0/24 via 10.10.50.43 dev v9

# routes from namespace R4
ip -n R4 route add 10.20.20.0/24 via 10.20.10.43 dev v11
ip -n R4 route add 10.30.20.0/24 via 10.30.10.43 dev v15
ip -n R4 route add 10.10.20.0/24 via 10.10.50.42 dev v10
ip -n R4 route add 10.10.30.0/24 via 10.10.50.42 dev v10
ip -n R4 route add 10.10.10.0/24 via 10.10.50.42 dev v10
ip -n R4 route add 10.10.40.0/24 via 10.10.50.42 dev v10


# Add the trace route commands
# H1 to H4
ip netns exec H1 traceroute 10.30.20.43
sleep 3
# H3 to H2
ip netns exec H3 traceroute 10.10.40.43
sleep 3
# H4 to H3
ip netns exec H4 traceroute 10.20.20.43
sleep 3


to test ping uncomment below lines
for x in {1..5}
do
	y=$((x*10))
	sudo ip netns exec H1 ping -c1 10.10."$y".42
	sudo ip netns exec H2 ping -c1 10.10."$y".42 
	sudo ip netns exec H3 ping -c1 10.10."$y".42 
	sudo ip netns exec H4 ping -c1 10.10."$y".42 
	sudo ip netns exec R1 ping -c1 10.10."$y".42 
	sudo ip netns exec R2 ping -c1 10.10."$y".42 
	sudo ip netns exec R3 ping -c1 10.10."$y".42 
    sudo ip netns exec R4 ping -c1 10.10."$y".42 
	sudo ip netns exec R5 ping -c1 10.10."$y".42 
	sudo ip netns exec R6 ping -c1 10.10."$y".42 
	sudo ip netns exec H1 ping -c1 10.10."$y".43 
	sudo ip netns exec H2 ping -c1 10.10."$y".43 
	sudo ip netns exec H3 ping -c1 10.10."$y".43 
	sudo ip netns exec H4 ping -c1 10.10."$y".43 
	sudo ip netns exec R1 ping -c1 10.10."$y".43 
	sudo ip netns exec R2 ping -c1 10.10."$y".43 
	sudo ip netns exec R3 ping -c1 10.10."$y".43 
    sudo ip netns exec R4 ping -c1 10.10."$y".43 
	sudo ip netns exec R5 ping -c1 10.10."$y".43 
	sudo ip netns exec R6 ping -c1 10.10."$y".43 
done

for x in {1..2}
do
	y=$((x*10))
    sudo ip netns exec H1 ping -c1 10.20."$y".42
    sudo ip netns exec H2 ping -c1 10.20."$y".42 
    sudo ip netns exec H3 ping -c1 10.20."$y".42 
    sudo ip netns exec H4 ping -c1 10.20."$y".42 
    sudo ip netns exec R1 ping -c1 10.20."$y".42 
    sudo ip netns exec R2 ping -c1 10.20."$y".42 
    sudo ip netns exec R3 ping -c1 10.20."$y".42 
    sudo ip netns exec R4 ping -c1 10.20."$y".42 
    sudo ip netns exec R5 ping -c1 10.20."$y".42 
    sudo ip netns exec R6 ping -c1 10.20."$y".42 
    sudo ip netns exec H1 ping -c1 10.20."$y".43
     sudo ip netns exec H2 ping -c1 10.20."$y".43 
    sudo ip netns exec H3 ping -c1 10.20."$y".43 
    sudo ip netns exec H4 ping -c1 10.20."$y".43
    sudo ip netns exec R1 ping -c1 10.20."$y".43 
    sudo ip netns exec R2 ping -c1 10.20."$y".43 
    sudo ip netns exec R3 ping -c1 10.20."$y".43 
    sudo ip netns exec R4 ping -c1 10.20."$y".43 
    sudo ip netns exec R5 ping -c1 10.20."$y".43 
    sudo ip netns exec R6 ping -c1 10.20."$y".43

    sudo ip netns exec H1 ping -c1 10.30."$y".42
    sudo ip netns exec H2 ping -c1 10.30."$y".42 
    sudo ip netns exec H3 ping -c1 10.30."$y".42 
    sudo ip netns exec H4 ping -c1 10.30."$y".42 
    sudo ip netns exec R1 ping -c1 10.30."$y".42 
    sudo ip netns exec R2 ping -c1 10.30."$y".42 
    sudo ip netns exec R3 ping -c1 10.30."$y".42 
    sudo ip netns exec R4 ping -c1 10.30."$y".42 
    sudo ip netns exec R5 ping -c1 10.30."$y".42 
    sudo ip netns exec R6 ping -c1 10.30."$y".42 
    sudo ip netns exec H1 ping -c1 10.30."$y".43 
    sudo ip netns exec H2 ping -c1 10.30."$y".43 
    sudo ip netns exec H3 ping -c1 10.30."$y".43 
    sudo ip netns exec H4 ping -c1 10.30."$y".43
    sudo ip netns exec R1 ping -c1 10.30."$y".43 
    sudo ip netns exec R2 ping -c1 10.30."$y".43 
    sudo ip netns exec R3 ping -c1 10.30."$y".43 
    sudo ip netns exec R4 ping -c1 10.30."$y".43 
    sudo ip netns exec R5 ping -c1 10.30."$y".43 
    sudo ip netns exec R6 ping -c1 10.30."$y".43
done