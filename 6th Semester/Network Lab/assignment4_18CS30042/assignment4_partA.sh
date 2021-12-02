# Name : Sumit Kumar Yadav
# Roll No. : 18CS30042

#!/bin/bash

# check whether user is in sudo or not
if [[ $EUID -ne 0 ]]; then										
	echo "Please execute the code in 'sudo su' "		
	exit 1														
fi

ip netns add N1			# add network namespace with name as N1
ip netns add N2			# add network namespace with name as N2
ip netns add N3			# add network namespace with name as N3
ip netns add N4			# add network namespace with name as N4

ip link add v1 type veth peer name v2 	# add veth peer between v1 and v2
ip link add v3 type veth peer name v4 	# add veth peer between v3 and v4
ip link add v5 type veth peer name v6 	# add veth peer between v5 and v6

ip link set v1 netns N1			# link the v1 with network N1
ip link set v2 netns N2			# link the v2 with network N2
ip link set v3 netns N2			# link the v3 with network N2
ip link set v4 netns N3			# link the v4 with network N3
ip link set v5 netns N3			# link the v5 with network N3
ip link set v6 netns N4			# link the v6 with network N4

# Assign IP address range to each of the virtual ethernet like v1,v2..... corresponding to its network namespace
ip -n N1 addr add 10.0.10.42/24 dev v1
ip -n N2 addr add 10.0.10.43/24 dev v2
ip -n N2 addr add 10.0.20.42/24 dev v3
ip -n N3 addr add 10.0.20.43/24 dev v4
ip -n N3 addr add 10.0.30.42/24 dev v5
ip -n N4 addr add 10.0.30.43/24 dev v6

# Bring the IP link interfaces up
ip -n N1 link set v1 up
ip -n N2 link set v2 up
ip -n N2 link set v3 up
ip -n N3 link set v4 up
ip -n N3 link set v5 up
ip -n N4 link set v6 up

# Enable loop back interface for each namespace to check if you can ping a namespace’s own interfaces (sanity check)
ip -n N1 link set lo up
ip -n N2 link set lo up
ip -n N3 link set lo up
ip -n N4 link set lo up

# To check the route of any namespace
# ip -n N1 route

# Adding routes command to connect all inerfaces with namespaces
# Adding Routes for N1
ip -n N1 route add 10.0.20.0/24 via 10.0.10.43 dev v1 	# v2 and v3,v4 
ip -n N1 route add 10.0.30.0/24 via 10.0.10.43 dev v1 	# v2 and v5,v6

# Adding Routes for N2
ip -n N2 route add 10.0.30.0/24 via 10.0.20.43 dev v3 	# v4 and v5,v6

# Adding Routes for N3
ip -n N3 route add 10.0.10.0/24 via 10.0.20.42 dev v4 	# v3 and v1,v2

# Adding Routes for N4
ip -n N4 route add 10.0.20.0/24 via 10.0.30.42 dev v6 	# v5 and v3,v4
ip -n N4 route add 10.0.10.0/24 via 10.0.30.42 dev v6 	# v5 and v1,v2 ie,v6 echo reply to v1

# Enable IP forward to all the namespace
ip netns exec N1 sysctl -w net.ipv4.ip_forward=1
ip netns exec N2 sysctl -w net.ipv4.ip_forward=1
ip netns exec N3 sysctl -w net.ipv4.ip_forward=1
ip netns exec N4 sysctl -w net.ipv4.ip_forward=1

# ping commands
# For N1
ip netns exec N1 ping -c3 10.0.10.42
ip netns exec N1 ping -c3 10.0.10.43
ip netns exec N1 ping -c3 10.0.20.42
ip netns exec N1 ping -c3 10.0.20.43
ip netns exec N1 ping -c3 10.0.30.42
ip netns exec N1 ping -c3 10.0.30.43

# For N2
ip netns exec N2 ping -c3 10.0.10.42
ip netns exec N2 ping -c3 10.0.10.43
ip netns exec N2 ping -c3 10.0.20.42
ip netns exec N2 ping -c3 10.0.20.43
ip netns exec N2 ping -c3 10.0.30.42
ip netns exec N2 ping -c3 10.0.30.43

# For N3
ip netns exec N3 ping -c3 10.0.10.42
ip netns exec N3 ping -c3 10.0.10.43
ip netns exec N3 ping -c3 10.0.20.42
ip netns exec N3 ping -c3 10.0.20.43
ip netns exec N3 ping -c3 10.0.30.42
ip netns exec N3 ping -c3 10.0.30.43

# For N4
ip netns exec N4 ping -c3 10.0.10.42
ip netns exec N4 ping -c3 10.0.10.43
ip netns exec N4 ping -c3 10.0.20.42
ip netns exec N4 ping -c3 10.0.20.43
ip netns exec N4 ping -c3 10.0.30.42
ip netns exec N4 ping -c3 10.0.30.43