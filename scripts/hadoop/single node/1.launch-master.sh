#!/bin/bash
touch ip-and-hostname
touch dns
touch masters
>ip-and-hostname
>dns
>masters
#instance_id=$(aws ec2 run-instances --key-name MyKeyPair --region us-west-2 --security-groups hadoop --instance-type c3.4xlarge --image-id ami-093ad169 --output text --query 'Instances[*].InstanceId')
instance_req_id=$(aws ec2 request-spot-instances --spot-price $1 --instance-count 1 --type "one-time" --launch-specification file://specification.json --output text --query 'SpotInstanceRequests[*].SpotInstanceRequestId')
echo $instance_req_id
status=$(aws ec2 describe-spot-instance-requests --spot-instance-request-ids $instance_req_id --output text --query 'SpotInstanceRequests[*].Status.Code')
echo $status
while [ "$status" != "fulfilled" ]
do
status=$(aws ec2 describe-spot-instance-requests --spot-instance-request-ids $instance_req_id --output text --query 'SpotInstanceRequests[*].Status.Code')
echo "Pending evaulation from AWS"
sleep 5
done

instance_id=$(aws ec2 describe-spot-instance-requests --spot-instance-request-ids $instance_req_id --output text --query 'SpotInstanceRequests[*].InstanceId')
echo $instance_id
sleep 3
master_ip=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].PrivateIpAddress')
pub_master_ip=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
dns=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].PublicDnsName')
private_dns=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].NetworkInterfaces[*].PrivateDnsName')
IFS='.' read -ra private_hostname <<< "$private_dns"
echo $private_hostname
echo $master_ip
echo $dns
ed ip-and-hostname<<TEXT
i
$master_ip $private_hostname
.
w
q
TEXT
ed dns<<TEXT
i
$dns
.
w
q
TEXT
ed masters<<TEXT
i
$private_hostname
.
w
q
TEXT
#status=$(aws ec2 describe-instance-status --instance-id $instance_id --output text --query 'InstanceStatuses[*].InstanceState[*].Name')
#echo $status
#while [ "$status" != "running" ]
#do
#status=$(aws ec2 describe-instance-status --instance-id $instance_id --output text --query 'InstanceStatuses[*].InstanceState[*].Name')
#echo "Instance is getting ready"
#sleep 5
#done
echo "success"
