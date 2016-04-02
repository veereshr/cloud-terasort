#!/bin/bash
ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R ip-172-31-43-156

export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
export HADOOP_HOME=/usr/local/hadoop
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"
start-dfs.sh
start-yarn.sh
/home/ubuntu/gensort -a 1000000000 /home/ubuntu/raid0/input
head /home/ubuntu/raid0/input
tail /home/ubuntu/raid0/input
hadoop fs -mkdir /input_dir
hadoop fs -put /home/ubuntu/raid0/input /input_dir
hadoop fs -ls /input_dir
mkdir HadoopSort
javac -classpath /home/ubuntu/hadoop-core-1.2.1.jar -d HadoopSort Sorte.java && jar -cvf sorte.jar -C HadoopSort/ .
hadoop jar sorte.jar Sorte /input_dir/input output_dir
hadoop fs -get output_dir /home/ubuntu/raid0
cd /home/ubuntu/raid0/output_dir
head part*
tail part*
