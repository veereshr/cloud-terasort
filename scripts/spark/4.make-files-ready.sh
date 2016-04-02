#!/bin/bash
input="./ip-and-hostname"

#core-site.xml

linenum=22
cp ./copy/core-site.xml.template ./xmls/core-site.xml
while IFS= read -r var
do
values=($var)
	ed ./xmls/core-site.xml <<TEXT
$linenum
d
i
		  <value>hdfs://$values:9000</value>
.
w
q
TEXT
ed ./xmls/core-site.xml <<TEXT
23
a

		<property>
			<name>hadoop.tmp.dir</name>
			<value>/home/ubuntu/raid0/hadoop_data</value>
		</property>
.
w
q
TEXT
break
done < "$input"
cat ./xmls/core-site.xml



#mapred-site.xml

linenum=23
size=14285714285
cp ./copy/mapred-site.xml.template ./xmls/mapred-site.xml
while IFS= read -r var
do
values=($var)
	ed ./xmls/mapred-site.xml <<TEXT
$linenum
a
		<property>
			<name>mapred.job.tracker</name>
			<value>$values:54311</value>
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
break
done < "$input"
cat ./xmls/mapred-site.xml


#yarn-site.xml

linenum=25
cp ./copy/yarn-site.xml.template ./xmls/yarn-site.xml
while IFS= read -r var
do
values=($var)
	ed ./xmls/yarn-site.xml <<TEXT
$linenum
a
<property>
 <name>yarn.resourcemanager.resource-tracker.address</name>
 <value>$values:8025</value>
</property>
<property>
 <name>yarn.resourcemanager.scheduler.address</name>
 <value>$values:8035</value>
</property>
<property>
 <name>yarn.resourcemanager.address</name>
 <value>$values:8050</value>
</property>
.
w
q
TEXT
break
done < "$input"
cat ./xmls/yarn-site.xml
