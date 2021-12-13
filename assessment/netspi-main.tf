terraform {}

####### Provider block #######
provider "aws" {
	
	region 		= "${var.region}"
	access_key 	= "${var.access_key"}
	secret_key 	= "${var.secret_key"}
}

####### IAM Policy document creation #######
data "aws_iam_policy_document" "instance_assume_role_policy" {
	statement {
		actions = ["sts:AssumeRole"]

		principals {
			type        = "Service"
			identifiers = ["ec2.amazonaws.com"]
		}
	}
}

####### IAM Role creation #######
resource "aws_iam_role" "iamrole_ec2" {
	name                = "iam_role"
	assume_role_policy  = data.aws_iam_policy_document.instance_assume_role_policy.json # (not shown)
	managed_policy_arns = [aws_iam_policy.policy_one.arn, aws_iam_policy.policy_two.arn]
}

####### IAM Policy 1 #######
resource "aws_iam_policy" "policy_one" {
	name = "policy-618033"

	policy = jsonencode({
		Version = "2012-10-17"
		Statement = [{
			Action   = ["ec2:*"]
			Effect   = "Allow"
			Resource = "*"
		},]
    })
}

####### IAM Policy 2 #######
resource "aws_iam_policy" "policy_two" {
	name = "policy-381966"

	policy = jsonencode({
		Version = "2012-10-17"
		Statement = [{
			Action   = ["s3:ListAllMyBuckets", "s3:ListBucket", "s3:GetObject", "s3:PutObject", "s3:PutObjectAcl", "s3:DeleteObject"]
			Effect   = "Allow"
			Resource = "arn:aws:s3:::testbucket"
		},]
	})
}

####### IAM Instance profile creation #######
resource "aws_iam_instance_profile" "instanceprofile" {
    name = "ec2-role"
    role = "${aws_iam_role.iamrole_ec2.name}"
}

####### Key pair provisioning for EC2 SSH access #######
resource "aws_key_pair" "mykeypair" {

	key_name   = "${var.keyname}"
	public_key = "${file("${var.path_to_public_key}")}"
}

####### VPC provisioning #######
resource "aws_vpc" "my_vpc" {

	cidr_block = "${var.cidr_vpc}"

	tags = {
		Name 	= "My VPC"
		Project	= "NetSPI_VPC"
	}
}

####### Subnet provisioning #######
resource "aws_subnet" "my_subnet" {

	vpc_id            = aws_vpc.my_vpc.id
	cidr_block        = "${var.cidr_subnet}"
	availability_zone = "${var.az1}"

	tags = {
		Name 	= "My Subnet"
		Project	= "NetSPI_SUBNET"
	}
}

####### KMS Key provisioning for S3 bucket #######
resource "aws_kms_key" "mykey" {

	description             = "This key is used to encrypt bucket objects"
	deletion_window_in_days = "${var.deletion_window}"
}

####### S3 bucket provisioning #######
resource "aws_s3_bucket" "testbucket" {
	
	bucket = "${var.bucket_name}"
	acl    = "${var.acl}"

	tags = {
		Name        = "My S3 Bucket"
		Project		= "NetSPI_S3"
	}
	
	server_side_encryption_configuration {
		rule {
			apply_server_side_encryption_by_default {
				kms_master_key_id = aws_kms_key.mykey.arn
				sse_algorithm     = "aws:kms"
			}
		}
	}
}

####### Fetch latest AMI value #######
data "aws_ami" "recent" {

	most_recent = true
	owners		= "${var.owner}"
	
	filter {
		name   = "name"
		values = ["${var.default_ami[var.ami]["name"]}"]
	}
	
	filter {
		name   = "image-id"
		values = ["${var.default_ami[var.ami]["ami_id"]}"]
	}
}

####### Security group for EC2 #######
resource "aws_security_group" "mysecgroup" {

	name        = "mysecuritygroup"
	description = "Allow traffic to/from EC2 instance"
	vpc_id      = aws_vpc.my_vpc.id

	ingress {
		description      = "Inbound connections over 443 port"
		from_port        = "${var.port_ingress}"
		to_port          = "${var.port_ingress}"
		protocol         = "${var.protocol_ingress}"
		cidr_blocks      = [aws_vpc.my_vpc.cidr_block]
	}

	egress {
		from_port        = "${var.port_egress}"
		to_port          = "${var.port_egress}"
		protocol         = "${var.protocol_egress}"
		cidr_blocks      = "${var.cidr_egress}"
	}

	tags = {
		Name 	= "My Security Group"
		Project	= "NetSPI_SG"
	}
}

####### EFS Mount #######
module "efs_mount" {
	source 		= "../"
	name    	= "my-efs-mount"
	subnet_id 	= aws_subnet.my_subnet.id
	vpc_id      = aws_vpc.my_vpc.id
}

####### EC2 instance provisioning #######
resource "aws_instance" "netspi_app" {
	ami           			= data.aws_ami.recent.id
	instance_type 			= "${var.instance_type}"
	key_name 				= aws_key_pair.mykeypair.key_name
	subnet_id 				= aws_subnet.my_subnet.id
	vpc_security_group_ids 	= [aws_security_group.mysecgroup.id, module.efs_mount.ec2_security_group_id]
	public_ip				= "${var.eip}"
	iam_instance_profile 	= "${aws_iam_instance_profile.instanceprofile.name}"
	
	connection {
		type		= "${var.connection_type}"
		user 		= "${var.instance_username}"
		private_key = "${file("${var.path_to_private_key}")}"
		host		= self.public_ip
	}

	provisioner "remote-exec" {
		inline = [
			"sudo mkdir -p /data/test",

			"sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${module.efs_mount.file_system_dns_name}:/ /data/test",

			"sudo su -c \"echo '${module.efs_mount.file_system_dns_name}:/ /data/test nfs4 rw,defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab\"" #create fstab entry to ensure automount on reboots
		]
	}

	tags = {
		Name 	= "NetSPI Application"
		Project = "NetSPI_EC2"
	}
}