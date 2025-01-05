###################################################
# Additional Cluster SG & Node SG 생성
###################################################
locals {
  private_access_cidrs = local.network_info.private_access_cidrs

  sg_set = {
    cluster_additional = [
      for k in local.private_access_cidrs : {
        from_port = 443
        to_port   = 443
        protocol  = "tcp"
        source    = k
      }
    ]
    worker_node = [
      { # Worker Node's Self Allow
        from_port = 0
        to_port   = 0
        protocol  = "all"
        source    = "self"
      }
    ]
  }
}

module "sg" {
  source = "../chapter12_security_group"

  vpc_name = local.vpc_name
  vpc_id   = local.vpc_id

  sg_set = local.sg_set

  tags = local.module_tags
}

locals {
  node_sg               = module.sg.sg_id["worker_node"]
  additional_cluster_sg = module.sg.sg_id["cluster_additional"]
}

###################################################
# EKS 생성 이후 진행
# Cluster <-> Node 통신 허용 (all)
###################################################
locals {
  cluster_sg = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

## Cluster (Master Plane) -HTTPS-> Node (Worker)
resource "aws_security_group_rule" "cluster_to_node" {
  security_group_id = local.node_sg

  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  source_security_group_id = local.cluster_sg
  description              = "tf/${local.cluster_name}-ClusterSG"
}

## Cluster (Master Plane) -HTTPS <- Node (Worker)
resource "aws_security_group_rule" "node_to_cluster" {
  security_group_id = local.cluster_sg

  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  source_security_group_id = local.node_sg
  description              = "tf/${local.cluster_name}-NodeSG"
}
