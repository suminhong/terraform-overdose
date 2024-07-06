module "instances_a" {
  source = "github.com/example-user/terraform-module-ec2-asg"

  minimum_count = 3
  desired_count = 3
  maximum_count = 10
  instance_type = "t3.medium"
}

module "instances_b" {
  source = "github.com/example-user/terraform-module-ec2-asg"

  minimum_count = 1
  desired_count = 1
  maximum_count = 3
  instance_type = "t3.xlarge"
}
