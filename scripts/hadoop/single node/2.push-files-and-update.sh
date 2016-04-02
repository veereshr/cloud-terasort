#!/bin/bash
while read line; do 
	echo "Sending file to $line"
	scp -i $1 ./raid0-single-node.sh ubuntu@$line:/home/ubuntu/
	scp -i $1 ./gensort ubuntu@$line:/home/ubuntu/
	scp -i $1 ./generate-data-and-put-in-hdfs.sh ubuntu@$line:/home/ubuntu/
	scp -i $1 ./mapper-reducer-update.sh ubuntu@$line:/home/ubuntu/
	scp -i $1 ./hadoop-core-1.2.1.jar ubuntu@$line:/home/ubuntu/
	scp -i $1 ./hadoop-examples-1.1.1.jar ubuntu@$line:/home/ubuntu/
	scp -i $1 ./mapper-reducer-update.sh ubuntu@$line:/home/ubuntu/
	scp -i $1 ./Sorte.java ubuntu@$line:/home/ubuntu/
	echo "Updating host files for hadoop multinode setup"
#	ssh -i $1 -n ubuntu@$line sudo su hduser
	ssh -i $1 -n ubuntu@$line "sudo /home/ubuntu/mapper-reducer-update.sh 1428571428"
	ssh -i $1 -n ubuntu@$line "/home/ubuntu/raid0-single-node.sh"
	ssh -i $1 -n ubuntu@$line "/home/ubuntu/generate-data-and-put-in-hdfs.sh"
	
done < dns
