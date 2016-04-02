#!/bin/bash
while read line; do 
	echo "Sending file to $line"
	scp -i $1 ./raid0-single-node.sh ubuntu@$line:/home/ubuntu/
	scp -i $1 ./gensort ubuntu@$line:/home/ubuntu/
	echo "Updating host files for hadoop multinode setup"
#	ssh -i $1 -n ubuntu@$line sudo su hduser
	ssh -i $1 -n ubuntu@$line "/home/ubuntu/raid0-single-node.sh"
	ssh -i $1 -n ubuntu@$line "/home/ubuntu/gensort -a 10000000 /home/ubuntu/raid0/1gb"
	ssh -i $1 -n ubuntu@$line "/home/ubuntu/gensort -a 100000000 /home/ubuntu/raid0/10gb"
	scp -i $1 ./SharedMemorySort.java ubuntu@$line:/home/ubuntu/raid0/
	ssh -i $1 -n ubuntu@$line "javac /home/ubuntu/raid0/SharedMemorySort.java"
done < dns
while read line; do 
	ssh -i $1 -n ubuntu@$line "cd /home/ubuntu/raid0/ && java SharedMemorySort 1gb 8"
	ssh -i $1 -n ubuntu@$line "head /home/ubuntu/raid0/sortedFile"
	ssh -i $1 -n ubuntu@$line "tail /home/ubuntu/raid0/sortedFile"
done < dns
while read line; do 
	ssh -i $1 -n ubuntu@$line "cd /home/ubuntu/raid0/ && java SharedMemorySort 1gb 4"
	ssh -i $1 -n ubuntu@$line "head /home/ubuntu/raid0/sortedFile"
	ssh -i $1 -n ubuntu@$line "tail /home/ubuntu/raid0/sortedFile"
done < dns
while read line; do 
	ssh -i $1 -n ubuntu@$line "cd /home/ubuntu/raid0/ && java SharedMemorySort 1gb 2"
	ssh -i $1 -n ubuntu@$line "head /home/ubuntu/raid0/sortedFile"
	ssh -i $1 -n ubuntu@$line "tail /home/ubuntu/raid0/sortedFile"
done < dns
while read line; do 
	ssh -i $1 -n ubuntu@$line "cd /home/ubuntu/raid0/ && java SharedMemorySort 1gb 1"
	ssh -i $1 -n ubuntu@$line "head /home/ubuntu/raid0/sortedFile"
	ssh -i $1 -n ubuntu@$line "tail /home/ubuntu/raid0/sortedFile"
done < dns
while read line; do 
	ssh -i $1 -n ubuntu@$line "cd /home/ubuntu/raid0/ && java SharedMemorySort 10gb 8"
	ssh -i $1 -n ubuntu@$line "head /home/ubuntu/raid0/sortedFile"
	ssh -i $1 -n ubuntu@$line "tail /home/ubuntu/raid0/sortedFile"
done < dns
while read line; do 
	ssh -i $1 -n ubuntu@$line "cd /home/ubuntu/raid0/ && java SharedMemorySort 10gb 4"
	ssh -i $1 -n ubuntu@$line "head /home/ubuntu/raid0/sortedFile"
	ssh -i $1 -n ubuntu@$line "tail /home/ubuntu/raid0/sortedFile"
done < dns
while read line; do 
	ssh -i $1 -n ubuntu@$line "cd /home/ubuntu/raid0/ && java SharedMemorySort 10gb 2"
	ssh -i $1 -n ubuntu@$line "head /home/ubuntu/raid0/sortedFile"
	ssh -i $1 -n ubuntu@$line "tail /home/ubuntu/raid0/sortedFile"
done < dns
while read line; do 
	ssh -i $1 -n ubuntu@$line "cd /home/ubuntu/raid0/ && java SharedMemorySort 10gb 1"
	ssh -i $1 -n ubuntu@$line "head /home/ubuntu/raid0/sortedFile"
	ssh -i $1 -n ubuntu@$line "tail /home/ubuntu/raid0/sortedFile"
done < dns



	

