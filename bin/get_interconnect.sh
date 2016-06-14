#!/bin/bash
[ "$USER" != "oracle" ] && echo "Error: $0 should be executed with userid oracle." && exit 1
[ "${ORACLE_SID:0:4}" != "+ASM" ] && echo "Error: grid home should be set." && exit 1

for int in `oifcfg getif -type cluster_interconnect | awk '{ print $1 }'`; 
	
		do 
		
		#ip addr show $int | grep inet\  | awk '{print $2}';
		printf "%-5s %-30s" $int `ip addr show ib0 | grep inet\  | awk '{print $2}';`; echo;
		 
done


#/sbin/ifconfig $(oifcfg getif -type cluster_interconnect | awk '{ print $1 }') | grep inet\ addr | sed 's/^\ *inet\ addr:\([0-9\.]*\).*$/\1/'
