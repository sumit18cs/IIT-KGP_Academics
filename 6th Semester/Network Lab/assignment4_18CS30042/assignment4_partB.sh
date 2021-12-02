# Name : Sumit Kumar Yadav
# Roll No. : 18CS30042

#!/bin/bash

# check whether user is in sudo or not
if [[ $EUID -ne 0 ]]; then										
	echo "Please execute the code in 'sudo su' "		
	exit 1														
fi

ip netns add H1			# add network namespace with name as H1
ip netns add H2			# add network namespace with name as H2
ip netns add H3			# add network namespace with name as H3
ip netns add H4			# add network namespace with name as H4
ip netns add R1			# add network namespace with name as R1
ip netns add R2			# add network namespace with name as R2
ip netns add R3			# add network namespace with name as R3

ip link add v1 type veth peer name v2 		# add veth peer between v1 and v2
ip link add v3 type veth peer name v4 		# add veth peer between v3 and v4
ip link add v5 type veth peer name v6 		# add veth peer between v5 and v6
ip link add v7 type veth peer name v8 		# add veth peer between v7 and v8
ip link add v9 type veth peer name v10 		# add veth peer between v9 and v10
ip link add v11 type veth peer name v12 	# add veth peer between v11 and v12

ip link set v1 netns H1			# link the v1 with network H1
ip link set v2 netns R1			# link the v2 with network R1
ip link set v3 netns H2			# link the v3 with network H2
ip link set v4 netns R1			# link the v4 with network R1
ip link set v5 netns R1			# link the v5 with network R1
ip link set v6 netns R2			# link the v6 with network R2
ip link set v7 netns R2			# link the v7 with network R2
ip link set v8 netns R3			# link the v8 with network R3
ip link set v9 netns R3			# link the v9 with network R3
ip link set v10 netns H3		# link the v10 with network H3
ip link set v11 netns R3		# link the v11 with network R3
ip link set v12 netns H4		# link the v12 with network H4

# Assign IP address range to each of the virtual ethernet like v1,v2..... corresponding to its network namespace
ip -n H1 addr add 10.0.10.42/24 dev v1
ip -n R1 addr add 10.0.10.43/24 dev v2
ip -n H2 addr add 10.0.20.42/24 dev v3
ip -n R1 addr add 10.0.20.43/24 dev v4 
ip -n R1 addr add 10.0.30.42/24 dev v5
ip -n R2 addr add 10.0.30.43/24 dev v6
ip -n R2 addr add 10.0.40.42/24 dev v7
ip -n R3 addr add 10.0.40.43/24 dev v8
ip -n R3 addr add 10.0.50.42/24 dev v9
ip -n H3 addr add 10.0.50.43/24 dev v10
ip -n R3 addr add 10.0.60.42/24 dev v11
ip -n H4 addr add 10.0.60.43/24 dev v12

# Bring the IP link interfaces up
ip -n H1 link set v1 up
ip -n R1 link set v2 up
ip -n H2 link set v3 up
ip -n R1 link set v4 up
ip -n R1 link set v5 up
ip -n R2 link set v6 up
ip -n R2 link set v7 up
ip -n R3 link set v8 up
ip -n R3 link set v9 up
ip -n H3 link set v10 up
ip -n R3 link set v11 up
ip -n H4 link set v12 up

# Enable loop back interface for each namespace to check if you can ping a namespace’s own interfaces (sanity check)
ip -n H1 link set lo up
ip -n H2 link set lo up
ip -n H3 link set lo up
ip -n H4 link set lo up
ip -n R1 link set lo up
ip -n R2 link set lo up
ip -n R3 link set lo up


# To check the route of any namespace
# ip -n N1 route

# Adding routes command to connect all inerfaces with namespaces
# Adding Routes for H1
ip -n H1 route add 10.0.20.0/24 via 10.0.10.43 dev v1 	# v2 and v3,v4
ip -n H1 route add 10.0.30.0/24 via 10.0.10.43 dev v1 	# v2 and v5,v6
ip -n H1 route add 10.0.40.0/24 via 10.0.10.43 dev v1 	# v2 and v7,v8	
ip -n H1 route add 10.0.50.0/24 via 10.0.10.43 dev v1 	# v2 and v9,v10
ip -n H1 route add 10.0.60.0/24 via 10.0.10.43 dev v1 	# v2 and v11,v12

# Adding Routes for H2
ip -n H2 route add 10.0.10.0/24 via 10.0.20.43 dev v3 	# v4 and v1,v2 echo reply 
ip -n H2 route add 10.0.30.0/24 via 10.0.20.43 dev v3	# v4 and v5,v6
ip -n H2 route add 10.0.40.0/24 via 10.0.20.43 dev v3	# v4 and v7,v8
ip -n H2 route add 10.0.50.0/24 via 10.0.20.43 dev v3	# v4 and v9,v10
ip -n H2 route add 10.0.60.0/24 via 10.0.20.43 dev v3	# v4 and v11,v12

# Adding Routes for H3
ip -n H3 route add 10.0.10.0/24 via 10.0.50.42 dev v10 	# v9 and v1,v2
ip -n H3 route add 10.0.20.0/24 via 10.0.50.42 dev v10	# v9 and v3,v4
ip -n H3 route add 10.0.30.0/24 via 10.0.50.42 dev v10	# v9 and v5,v6
ip -n H3 route add 10.0.40.0/24 via 10.0.50.42 dev v10 	# v9 and v7,v8
ip -n H3 route add 10.0.60.0/24 via 10.0.50.42 dev v10	# v9 and v11,v12

# Adding Routes for H4
ip -n H4 route add 10.0.10.0/24 via 10.0.60.42 dev v12	# v11 and v1,v2
ip -n H4 route add 10.0.20.0/24 via 10.0.60.42 dev v12	# v11 and v3,v4
ip -n H4 route add 10.0.30.0/24 via 10.0.60.42 dev v12	# v11 and v5,v6
ip -n H4 route add 10.0.40.0/24 via 10.0.60.42 dev v12	# v11 and v7,v8
ip -n H4 route add 10.0.50.0/24 via 10.0.60.42 dev v12	# v11 and v9,v10

# Adding Routes for R1
ip -n R1 route add 10.0.40.0/24 via 10.0.30.43 dev v5	# v6 and v7,v8
ip -n R1 route add 10.0.50.0/24 via 10.0.30.43 dev v5 	# v6 and v9,v10
ip -n R1 route add 10.0.60.0/24 via 10.0.30.43 dev v5	# v6 and v11,v12

# Adding Routes for R2
ip -n R2 route add 10.0.10.0/24 via 10.0.30.42 dev v6 	# v5 and v1,v2 echo reply
ip -n R2 route add 10.0.20.0/24 via 10.0.30.42 dev v6	# v5 and v3,v4
ip -n R2 route add 10.0.50.0/24 via 10.0.40.43 dev v7	# v5 and v9,v10
ip -n R2 route add 10.0.60.0/24 via 10.0.40.43 dev v7	# v5 and v11,v12

# Adding Routes for R3
ip -n R3 route add 10.0.10.0/24 via 10.0.40.42 dev v8 	# v7 and v1,v2 echo reply
ip -n R3 route add 10.0.20.0/24 via 10.0.40.42 dev v8	# v7 and v3,v4
ip -n R3 route add 10.0.30.0/24 via 10.0.40.42 dev v8 	# v7 and v5,v6


# Enable IP forward to all the namespace
ip netns exec H1 sysctl -w net.ipv4.ip_forward=1
ip netns exec H2 sysctl -w net.ipv4.ip_forward=1
ip netns exec H3 sysctl -w net.ipv4.ip_forward=1
ip netns exec H4 sysctl -w net.ipv4.ip_forward=1
ip netns exec R1 sysctl -w net.ipv4.ip_forward=1
ip netns exec R2 sysctl -w net.ipv4.ip_forward=1
ip netns exec R3 sysctl -w net.ipv4.ip_forward=1


# ping commands
x=1
while [ $x -le 6 ]
do
	y=$((x*10))
	ip netns exec H1 ping -c3 10.0."$y".42 
	ip netns exec H2 ping -c3 10.0."$y".42 
	ip netns exec H3 ping -c3 10.0."$y".42 
	ip netns exec H4 ping -c3 10.0."$y".42 
	ip netns exec R1 ping -c3 10.0."$y".42 
	ip netns exec R2 ping -c3 10.0."$y".42 
	ip netns exec R3 ping -c3 10.0."$y".42 
	ip netns exec H1 ping -c3 10.0."$y".43 
	ip netns exec H2 ping -c3 10.0."$y".43 
	ip netns exec H3 ping -c3 10.0."$y".43 
	ip netns exec H4 ping -c3 10.0."$y".43 
	ip netns exec R1 ping -c3 10.0."$y".43 
	ip netns exec R2 ping -c3 10.0."$y".43 
	ip netns exec R3 ping -c3 10.0."$y".43 
	x=$((x+1))
done

# Add the trace route commands
# H1 to H4
ip netns exec H1 traceroute 10.0.60.43
sleep 3
# H3 to H4
ip netns exec H3 traceroute 10.0.60.43
sleep 3
# H4 to H2
ip netns exec H4 traceroute 10.0.20.42
sleep 3
