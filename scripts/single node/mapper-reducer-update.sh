#!/bin/bash
#mapred-site.xml

linenum=20
sudo cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template ./mapred-site.xml
size=$1
sudo ed ./mapred-site.xml <<TEXT
$linenum
a
		<property>
			<name>mapreduce.framework.name</name>
			<value>yarn</value>
		</property>
		<property>
			<name>mapreduce.job.reduces</name>
			<value>7</value>
			<final>true</final>
		</property>
		<!--property>
			<name>mapreduce.job.maps</name>
			<value>7</value>
			<final>true</final>
		</property>-->
		<property>
			<name>mapred.min.split.size</name>
			<value>$size</value>
		</property>

		<!--<property>
			<name>mapred.max.split.size</name>
			<value>$size</value>
		</property>-->

.
w
q
TEXT
cat ./mapred-site.xml
sudo cp ./mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
