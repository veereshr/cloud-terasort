#!/bin/bash
while read line; do 
	echo "Sending file to $line"
	scp -i $1 ./hosts ubuntu@$line:/home/ubuntu/
	scp -i $1 ./slaves ubuntu@$line:/home/ubuntu/
	scp -i $1 ./masters ubuntu@$line:/home/ubuntu/
	scp -i $1 ./xmls/core-site.xml ubuntu@$line:/home/ubuntu/
	scp -i $1 ./xmls/hdfs-site.xml ubuntu@$line:/home/ubuntu/
	scp -i $1 ./xmls/mapred-site.xml ubuntu@$line:/home/ubuntu/
	scp -i $1 ./xmls/yarn-site.xml ubuntu@$line:/home/ubuntu/
	scp -i $1 ./change-hostfiles.sh ubuntu@$line:/home/ubuntu/
	scp -i $1 ./generate-data-and-put-in-hdfs.sh ubuntu@$line:/home/ubuntu/
	scp -i $1 ./gensort ubuntu@$line:/home/ubuntu/
	echo "Updating host files for hadoop multinode setup"
#	ssh -i $1 -n ubuntu@$line sudo su hduser

done < dns

while read line; do 
	ssh -i $1 -n ubuntu@$line "/home/ubuntu/change-hostfiles.sh"
done < dns

while read line; do 
scp -i $1 ./hadoop-core-1.2.1.jar ubuntu@$line:/home/ubuntu/
scp -i $1 ./Sorte.java ubuntu@$line:/home/ubuntu/
ssh -i $1 -n ubuntu@$line "/home/ubuntu/generate-data-and-put-in-hdfs.sh"

break
done < dns
