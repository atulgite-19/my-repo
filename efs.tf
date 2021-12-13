####### Provider block #######
provider "aws" {
	
	region 		= "${var.region}"
	access_key 	= "${var.access_key"}
	secret_key 	= "${var.secret_key"}
}

####### EFS token #######
resource "random_id" "creation_token" {	
	byte_length = 8
	prefix      = "${var.name}-"
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
resource "aws_kms_key" "mykeyefs" {

	description             = "This key is used to encrypt bucket objects"
	deletion_window_in_days = "${var.deletion_window}"
}

####### SG for EFS #######
resource "aws_security_group" "mount_target_client" {
	name        = "${var.name}-mount-target-client"
	description = "Allow traffic out to NFS for ${var.name}-mnt."
	vpc_id      = aws_vpc.my_vpc.id

	depends_on = [aws_efs_mount_target.this]
}

resource "aws_security_group" "mount_target" {
	name        = "${var.name}-mount-target"
	description = "Allow traffic from instances using ${var.name}-ec2."
	vpc_id      = aws_vpc.my_vpc.id
}

####### SG Rules for EFS #######
resource "aws_security_group_rule" "nfs_ingress" {
	description              = "Allow NFS traffic into mount target from EC2"
	type                     = "ingress"
	from_port                = 2049
	to_port                  = 2049
	protocol                 = "tcp"
	security_group_id        = aws_security_group.mount_target.id
	source_security_group_id = aws_security_group.mount_target_client.id
}

resource "aws_security_group_rule" "nfs_egress" {
	description              = "Allow NFS traffic out from EC2 to mount target"
	type                     = "egress"
	from_port                = 2049
	to_port                  = 2049
	protocol                 = "tcp"
	security_group_id        = aws_security_group.mount_target_client.id
	source_security_group_id = aws_security_group.mount_target.id
}

resource "aws_efs_file_system" "this" {
	creation_token = random_id.creation_token.hex

	encrypted  = var.encrypted
	kms_key_id = aws_kms_key.mykeyefs.id
}

####### EFS target #######
resource "aws_efs_mount_target" "this" {
	count = length(aws_subnet.my_subnet)

	file_system_id  = aws_efs_file_system.this.id
	subnet_id       = element(aws_subnet.my_subnet, count.index)
	security_groups = [aws_security_group.mount_target.id]
}