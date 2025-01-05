module "instances" {
  source = "./ec2-asg"

  minimum_count = 3
  desired_count = 3
  maximum_count = 10
  instance_type = "t3.medium"
}
