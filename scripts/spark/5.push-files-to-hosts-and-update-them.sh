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
#	ssh -i $1 -n ubuntu@$line sudo su hduser
done < dns

echo "Updating host files for spark multinode setup"

while read line; do 
	ssh -i $1 -n ubuntu@$line "/home/ubuntu/change-hostfiles.sh"
done < dns



while read line; do 


> ./environ.sh

ed ./environ.sh <<TEXT
a
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
export SPARK_PUBLIC_DNS=$line
export SPARK_WORKER_CORES=32
.
w
q
TEXT
cat ./environ.sh
scp -i $1 "environ.sh" ubuntu@$line:/home/ubuntu/
scp -i $1 ./"update-spark-slave.sh" ubuntu@$line:/home/ubuntu/

ssh -i $1 -n ubuntu@$line "sudo /home/ubuntu/update-spark-slave.sh"


done < dns



while read line; do 
scp -i $1 ./slaves-spark ubuntu@$line:/home/ubuntu/
scp -i $1 ./"update-for-spark-master.sh" ubuntu@$line:/home/ubuntu/
ssh -i $1 -n ubuntu@$line "/home/ubuntu/generate-data-and-put-in-hdfs.sh"
ssh -i $1 -n ubuntu@$line "sudo /home/ubuntu/update-for-spark-master.sh"
break
done < dns
