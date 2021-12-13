output "instance_id" {
	value = "${aws_instance.netspi_app.id}"
}

output "s3_bucket_id" {
	description = "The name of the bucket."
	value       = "${aws_s3_bucket.testbucket.id}"
}

output "securitygroup_id" {
	description = "ID of security group"
	value       = "${aws_security_group.mysecgroup.id}"
}

output "subnet_id" {
	description = "ID of subnet"
	value       = "${aws_subnet.my_subnet.id}"
}