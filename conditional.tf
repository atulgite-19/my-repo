<<<<<<< HEAD
/*provider "aws" {

  region = "ap-south-1"
  access_key = "XXXX"
  secret_key = "XXXX"
}

variable istest {}

resource "aws_instance" "dev1" {

    ami = "ami-abcd"
    instance_type ="t2.micro"

    count = var.istest == true ? 3 : 0 #if var.istest value is true, then 3 instances will be created
}

resource "aws_instance" "prod1" {

   ami = "ami-abcs"
   instance_type = "t2.nano"

   count = var.istest == false ? 1 : 0 #if var.istest value is false, then 1 instance will be created

}
*/
=======
/*provider "aws" {

  region = "ap-south-1"
  access_key = "XXXX"
  secret_key = "XXXX"
}

variable istest {}

resource "aws_instance" "dev1" {

    ami = "ami-XXXX"
    instance_type ="t2.micro"

    count = var.istest == true ? 3 : 0 #if var.istest value is true, then 3 instances will be created
}

resource "aws_instance" "prod1" {

   ami = "ami-XXXX"
   instance_type = "t2.nano"

   count = var.istest == false ? 1 : 0 #if var.istest value is false, then 1 instance will be created

}
*/
>>>>>>> 
