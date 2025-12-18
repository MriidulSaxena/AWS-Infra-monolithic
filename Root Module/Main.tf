module "s3_bucket" {
  source      = "../Child_Module/s3_bucket"
  bucket_name = "monolithic-app-bucket-12345"
}


module "vpc" {
  source               = "../Child_Module/vpc"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidr   = "10.0.1.0/24"
  vpc_name             = "monolithic-vpc"
  az                   = "ap-south-1a"
}

module "security-group" {
  source   = "../Child_Module/security-group"
  vpc_id  = module.vpc.vpc_id
  ssh_cidr = ["10.0.0.0/32"]
}

module "ec2" {
  source         = "../Child_Module/ec2"
  ami            = "ami-0f5ee92e2d63afc18"
  instance_type  = "t2.micro"
  subnet_id      = module.vpc.public_subnet_id
  sg_id          = module.security-group.sg_id
  name           = "monolithic-ec2"

  user_data = <<-EOF
    #!/bin/bash
    yum install -y httpd
    systemctl start httpd
    echo "Monolithic App via Modules" > /var/www/html/index.html
  EOF
}
