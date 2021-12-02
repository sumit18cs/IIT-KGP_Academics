#!/bin/bash

# check whether user is in sudo or not
if [[ $EUID -ne 0 ]]; then										
	echo "Please execute the code in 'sudo su' "		
	exit 1														
fi

ip netns add namespace0		# add network namespace with name as namespace0
ip netns add namespace1     # add network namespace with name as namespace1

ip link add veth0 type veth peer name veth1    # add veth peer between veth0 and veth1 

ip link set veth0 netns namespace0			   # link the veth0 with network namespace0
ip link set veth1 netns namespace1             # link the veth1 with network namespace1

ip -n namespace0 addr add 10.1.1.0/24 dev veth0		# in namespace namespace0 set the ip of veth0 as 10.1.1.0/24
ip -n namespace1 addr add 10.1.2.0/24 dev veth1		# in namespace namespace1 set the ip of veth1 as 10.1.2.0/24

ip -n namespace0 link set veth0 up					# in namespace namespace0 setting up veth0
ip -n namespace1 link set veth1 up					# in namespace namespace1 setting up veth1
ip -n namespace0 route add 10.1.2.0/24 dev veth0	# in the routing table of namespace0 we add IP 10.1.2.0/24 
ip -n namespace1 route add 10.1.1.0/24 dev veth1	# in the routing table of namespace1 we add IP 10.1.1.0/24

# to run in terminal first delete all the namespace using command : ip -all netns delete