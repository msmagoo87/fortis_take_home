#!/bin/bash
# This script requires you to have the AWS CLI installed and configured and have your environment set up
# as assumed in to the `example-bastion-access` role.
key_name=bastion_key
key_path=$HOME/.ssh/bastion_key
if ! [ -f $key_path ]; then
  ssh-keygen -t rsa -b 4096 -f $key_path -N ""
fi

# Get data about the instance
BASTION_INSTANCE=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=example-bastion" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)
DEPLOY_AZ=$(aws ec2 describe-instances --instance-ids $BASTION_INSTANCE --query "Reservations[*].Instances[*].Placement.AvailabilityZone" --output text)
BASTION_DNS_NAME=$(aws ec2 describe-instances --instance-ids $BASTION_INSTANCE --query "Reservations[*].Instances[*].PublicDnsName" --output text)

aws ec2-instance-connect send-ssh-public-key --instance-id $BASTION_INSTANCE --availability-zone $DEPLOY_AZ --instance-os-user ec2-user --ssh-public-key file://$key_path.pub


ssh -i $key_path ec2-user@$BASTION_DNS_NAME