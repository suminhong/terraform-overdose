locals {
  vpc_list = [
    {
      vpc1 = "1234"
      vpc2 = "5678"
    },
    {
      vpc3 = "9876"
    },
  ]
}

module "merge_vpc_list" {
  source = "../modules/chapter9_utility/3_merge_map_in_list"
  input  = local.vpc_list
}

locals {
  merged_vpc_list = module.merge_vpc_list.output
}
