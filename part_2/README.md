# Part 2

The second part of this challenge involves using infrastructure as code to create a VPC with public and private subnets, a bastion host in the public subnet space, a web server and a database in the private space, and a load balancer to front the web server. The web server should only be ssh accessible from the bastion host. The LB should be accessible from port 443 and forward traffic to the web server.

Within this folder you will find Terraform code to accomplish the above. The following are some notes to indicate special instructions or details to be known:

* This Terraform is set up to run in the aws account and region configured in the environment. This means there is no explicit provider file, so you must ensure you have your environment set up prior to running it. I personally use [aws-vault](https://github.com/99designs/aws-vault) for this.
* This project uses Terraform version `1.5.7` and AWS provider version `5.43.0`, as specified in the [versions.tf](./versions.tf) file.
* The bastion host is set up to use ssm and [ec2 instance connect](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connect-linux-inst-eic.html) to gain access to it. This requires assuming a role that is created within this Terraform (with the name `example-bastion-access`). Simply assume the role from within the account and use the [connect_to_bastion.sh](./connect_to_bastion.sh) script to get an ssh key created on your local machine that will be pushed to the instance via SSM and then open an ssh tunnel to the instance for you. 
* In order to ssh to the web server from the bastion host, you simply need to pull the private key for the key pair of the web server from secrets manager from the bastion host with the command: `aws --region ca-central-1 secretsmanager get-secret-value --secret-id web_key --query SecretString --output text > ~/.ssh/web_key && chmod 400 ~/.ssh/web_key`; which will create the key and set the correct permissions on it, then you can run the ssh command: `ssh -i ~/.ssh/web_key ec2-user@<web-server-private-ip>`.
* In order to have the ALB Target Group healthcheck work, I set up a basic Apache server with a basic index.html file via the user data on the web ec2 instance. 
* The connectivity between the web EC2 instance and the RDS instance is wired up and works, but isn't actually used by anything.

## Required Variables

There are only a few required variables to provide to this TF and they are as follows.

* `bastion_access_cidr` - The CIDR of the IP space to allow ssh access to the CIDR. For my local development I set this to my personal public IP.
* `zone_id` - A valid Route53 Zone ID. This is used for cert validation, so the domain needs to be valid and live.
* `domain_name` - The domain name to use for the ALB. This should be a valid domain name and match the domain name on the route53 zone specified as it will result in a new alias record on the zone for the ALB.