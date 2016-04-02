#!/bin/bash

sudo mv /home/ubuntu/hosts /etc/hosts
sudo mv /home/ubuntu/slaves /usr/local/hadoop/etc/hadoop
sudo mv /home/ubuntu/masters /usr/local/hadoop/etc/hadoop
sudo mv /home/ubuntu/core-site.xml /usr/local/hadoop/etc/hadoop
sudo mv /home/ubuntu/hdfs-site.xml /usr/local/hadoop/etc/hadoop
sudo mv /home/ubuntu/mapred-site.xml /usr/local/hadoop/etc/hadoop
sudo mv /home/ubuntu/yarn-site.xml /usr/local/hadoop/etc/hadoop
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
#RAID 0
sudo umount /mnt
sudo umount /home/ubuntu/raid0
sudo mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/xvdb /dev/xvdc <<-EOF
y
EOF
sudo mkfs.ext4 /dev/md0
sudo mount /dev/md0 raid0/
#hadoop data folder
#rm -r /home/ubuntu/raid0/hadoop_data
sudo chown -R ubuntu /home/ubuntu/raid0
mkdir -p /home/ubuntu/raid0/hadoop_data/hdfs/datanode
mkdir -p /home/ubuntu/raid0/hadoop_data/hdfs/namenode
sudo chown -R ubuntu /home/ubuntu/raid0/hadoop_data
yes | hdfs namenode -format
hdfs datanode -format
ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R 0.0.0.0
sudo chown -R ubuntu .ssh
