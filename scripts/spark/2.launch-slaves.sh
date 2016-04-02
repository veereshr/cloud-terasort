#!/bin/bash
touch slaves
>slaves
#for count in `seq 1 1`;
#do
	#instance_id=$(aws ec2 run-instances --key-name MyKeyPair --region us-west-2 --security-groups hadoop --instance-type t2.micro --image-id ami-093ad169 --output text --query 'Instances[*].InstanceId')


	instance_req_id=$(aws ec2 request-spot-instances --spot-price $1 --instance-count 1 --type "one-time" --launch-specification file://slave-specification.json --output text --query 'SpotInstanceRequests[*].SpotInstanceRequestId')
echo $instance_req_id
status=($(echo $(aws ec2 describe-spot-instance-requests --spot-instance-request-ids $instance_req_id --output json --query 'SpotInstanceRequests[*].Status.Code') | tr '"' '\n' | grep -))
echo $status

	while [ "$status" != "" ]
	do
status=($(echo $(aws ec2 describe-spot-instance-requests --spot-instance-request-ids $instance_req_id --output json --query 'SpotInstanceRequests[*].Status.Code') | tr '"' '\n' | grep -))
	echo "Pending evaulation from AWS"
	sleep 5
	done
instance_ids=$(aws ec2 describe-spot-instance-requests --spot-instance-request-ids $instance_req_id --output text --query 'SpotInstanceRequests[*].InstanceId')
echo $instance_ids
sleep 3

	
	slave_ips=$(aws ec2 describe-instances --instance-ids $instance_ids --output text --query 'Reservations[*].Instances[*].PrivateIpAddress')
	private_dns=$(aws ec2 describe-instances --instance-ids $instance_ids --output text --query 'Reservations[*].Instances[*].NetworkInterfaces[*].PrivateDnsName')
	dns=$(aws ec2 describe-instances --instance-ids $instance_ids --output text --query 'Reservations[*].Instances[*].PublicDnsName')
	
for aprivate_dns in ${private_dns[@]}
do
IFS='.' read -ra private_hostname <<< "${aprivate_dns}"
#IFS='.' read -ra private_hostname <<< "${aprivate_dns[$k]}"
echo $private_hostname
slave_ip=$(echo $private_hostname | sed -r 's/[-]+/./g' | sed -r 's/[ip]+//g' | cut -c 2-)

ed ip-and-hostname<<TEXT
a
$slave_ip $private_hostname
.
w
q
TEXT
ed slaves<<TEXT
a
$private_hostname
.
w
q
TEXT

done
ed dns<<TEXT
a
$dns
.
w
q
TEXT
touch slaves-spark
>slaves-spark
ed slaves-spark<<TEXT
a
$dns
.
w
q
TEXT
