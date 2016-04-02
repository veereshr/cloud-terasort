#!/bin/bash
while read line; do 
	ssh -i $1 -n ubuntu@$line "/home/ubuntu/change-hostfiles.sh"
	
done < dns
