#!/bin/bash
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
