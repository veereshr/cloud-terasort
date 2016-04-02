There are totally 12 experiments in this.

Shared Memory Sort
1) 8 thread 1 GB
2) 4 thread 1 GB
3) 2 thread 1 GB
4) 1 thread 1 GB

5) 8 thread 10 GB
6) 4 thread 10 GB
7) 2 thread 10 GB
8) 1 thread 10 GB

Hadoop Sort
9) 10 GB on single node
10) 100 GB on 16 datanodes and 1 namenode

Spark Sort
11) 10 GB in single node
12) 100 GB on 16 slave nodes and 1 master node

For all these experiments, the type of AWS EC2 instance used is c3.4xlarge for all single node conditions; for master:slave conditions,
c3.8xlarge is used as master and c3.4xlarge are used as slaves.

So in order to run to run all these experiments, I have made scripts, which will perform the following operations

1) Create a security group with the parameters needed for this experiment and fetch the created security group ID
2) Create a key to access the instances
3) Place spot-instance request with the following properties:
	Instance Type (say c3.4xlarge)
	AMI for the instance (say ami-948d67f4)
	Key Name (say c3-large-fresh)
	Security Group ID (say sg-b22947d5)
	Availability Zone (say us-west-b)
	Bid value (say $0.04)
	Number of instances (say 16)
	
	This request will return a list of values, among which the SpotInstanceRequests[*].Status.Code will return the 
	approval or denial of the request with the instances id(s) of the instance(s).
	
4) With the instance ID, that is fetch, we can fetch the following details
	public IP address
	public DNS
	private IP address
	private DNS
	
5) The above details can be used for 
	updating the hosts file, 
	masters and slaves of hadoop, 
	config files for hadoop,
	slaves of spark,
	config files for hadoop, etc

6) With all the updated files, we then distribute and update the files to all the nodes accordingly.

7) And then some actions to be performed on each node(such as RAID0, ssh-keygen, generating data and 
   storing it in HDFS, etc) can be done as well.
   
8) Finally, when all the nodes are updated with required files, we are able to start required services such as
   start-dfs.sh, start-yarn.sh, $SPARK_HOME/sbin/start-all.sh, etc through the script written.
  
9) And then we can execute the programs through the scripts as well.


Requirements:

1) An account in AWS and the following details

	AWS Access Key ID
	AWS Secret Access Key
	Default region name
	
2) Install AWS Command Line Interface:
	$apt-get install aws-cli
	
3) Configure AWS CLI
	$aws configure

Before running all other scripts, make sure you have generated a valid security group, key, etc. using the following scripts

	1) 0.generatekey.sh
		Create a key in AWS EC2 account
		Save the key with the key named "c3-large-fresh" <If needed, we can modify the name in the script>
	2) 0.create-security-group.sh
		All the protocols are defined in this file
		Creates a security group and return the name of the security group
		
Make sure to update the above details in the master-specification, slave-specificaion, specificaion files.

SHARED MEMORY SINGLE NODE:
	1) open the folder: \shared-mem\
	2) run in the following order
		1. launch-master.sh <bid value>
		2. push-files-and-update.sh <key name>


HADOOP SINGLE NODE:
	1) open the folder: \hadoop\single node
	2) run in the following order
		1.launch-master.sh <bid value>
			Wait for the success message
		2.push-files-and-update.sh <key name>
			This script internally executes few scripts such as
				Perform RAID0
				Generates the data needed
				It compiles and run the java program with varying input
				Saves the output with successful message of time taken

HADOOP MULTI NODE:

	1) open the folder: \hadoop\multi node
	2) run in the following order
		1.launch-master.sh <bid value>
			Wait for the success message
		2.launch-slaves.sh <bid value>
			Wait for the success message
		3.update-hosts.sh
			Updates the /etc/hosts file accross all the nodes
		4.make-files-ready.sh
			Creates all the XML config files needed for hadoop
			Make sure to edit the reducer count in the script according to the availability
			Also update the number of input splits which defines the mapper count
		5.push-files-to-hosts-and-update-them.sh <keyname of the instance>
			This script internally executes few scripts such as
				change-hostfiles.sh
					update /etc/hosts of all the nodes
				generate-data-and-put-in-hdfs.sh
					generates data, put in HDFS, run the experiment and print the output


Apart from the above mentioned scripts, there are internal scripts for performing, RAID0 and updating number of mapper, reducer

mapper-reducer-update.sh
					Updates the number of mappers (defined by number of input splits) and reducers needed for the experiment
raid0-single-node.sh
	Performs RAID0 and create a folder raid0 and mount the RAID0 on this folder
					

SPARK CLSUTER:
	1) open the folder: \spark\
	2) run in the follwing order
		1.launch-master.sh <bid value>
			Wait for the success message
		2.launch-slaves.sh <bid value>
			Wait for the success message
		3.update-hosts.sh
		4.make-files-ready.sh
		5.push-files-to-hosts-and-update-them.sh <keyname of the instance>
			This script internally executes few scripts such as
				change-hostfiles.sh
					update /etc/hosts of all the nodes
				generate-data-and-put-in-hdfs.sh
					generates data, put in HDFS, run the experiment and print the output
		Make sure to update the following field according to the cores we have, in this script
		export SPARK_WORKER_CORES=32
	
	Once this is done, we can open the SPARK Master node and run our programs with the following command:
	
	spark-submit --class com.github.ehiggs.spark.terasort.TeraSort <path>/target/veeresh-spark-terasort-dep.jar 
hdfs://172.31.14.63:9000/input_dir/input hdfs://172.31.14.63:9000/output_dir/output

	Edit the IP address and port number which you have defined in the hadoop/conf/core-site.xml
		name fs.default.name