#! /bin/bash

# check whether user is in sudo or not
if [[ $EUID -ne 0 ]]; then										
	echo "Please execute the code in 'sudo su' "		
	exit 1														
fi

ip link add veth1 type veth peer name veth2		# add veth peer between veth1 and veth2 
ip link add veth3 type veth peer name veth6		# add veth peer between veth3 and veth6 
ip link add veth4 type veth peer name veth5		# add veth peer between veth4 and veth5

ip netns add H1				# add network namespace with name as H1
ip netns add H2				# add network namespace with name as H2
ip netns add H3				# add network namespace with name as H3

ip link set veth1 netns H1				# link the veth1 with network namespace H1
ip link set veth5 netns H3				# link the veth5 with network namespace H3
ip link set veth6 netns H2				# link the veth6 with network namespace H2

ip -n H1 addr add 10.0.10.42/24 dev veth1		# in namespace H1 set the ip of veth1 as 10.0.10.42/24
ip -n H2 addr add 10.0.20.42/24 dev veth6		# in namespace H2 set the ip of veth6 as 10.0.20.42/24
ip -n H3 addr add 10.0.30.42/24 dev veth5		# in namespace H3 set the ip of veth5 as 10.0.30.42/24

ip -n H1 link set veth1 up 				# in namespace H1 setting up veth1	
ip -n H2 link set veth6 up 				# in namespace H2 setting up veth6
ip -n H3 link set veth5 up 				# in namespace H3 setting up veth5

#in the route tables
ip -n H1 route add default via 10.0.10.42    # assign 10.0.10.42 as default in H1
ip -n H2 route add default via 10.0.20.42    # assign 10.0.20.42 as default in H2
ip -n H3 route add default via 10.0.30.42    # assign 10.0.30.42 as default in H3


# create networkspace for router
ip netns add R 							# add network namespace with name as R
ip link set veth2 netns R 				# link the veth2 with network namespace R 
ip link set veth3 netns R 	 			# link the veth3 with network namespace R
ip link set veth4 netns R 				# link the veth4 with network namespace R

#bring up the interfaces
ip -n R link set veth2 up   			# in namespace R setting up veth2
ip -n R link set veth3 up  				# in namespace R setting up veth3
ip -n R link set veth4 up  				# in namespace R setting up veth4

#assign ip adresses to veth 2,3,4
ip -n R addr add 10.0.10.1/24 dev veth2       # set the ip for veth2 as 10.0.10.1/24
ip -n R addr add 10.0.20.1/24 dev veth3       # set the ip for veth3 as 10.0.20.1/24
ip -n R addr add 10.0.30.1/24 dev veth4       # set the ip for veth4 as 10.0.30.1/24

# iske uper wale peace ho gya
ip netns exec R brctl addbr brg            # add bridge name brg using brctl command in namespace R
ip netns exec R brctl addif brg veth2      
ip netns exec R brctl addif brg veth3
ip netns exec R brctl addif brg veth4

ip -n R link set brg up   				# setting up bridge 
sysctl -w net.ipv4.ip_forward=1    		# setting the ip_forward true using sysctl command in the bridge

# to run in terminal first delete all the namespace using command : ip -all netns delete