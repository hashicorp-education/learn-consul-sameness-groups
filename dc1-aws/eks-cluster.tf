data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [ module.eks.cluster_name ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
  depends_on = [ module.eks.cluster_name ]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.10.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.27"

  enable_cluster_creator_admin_permissions = true
  
  cluster_addons = {
    aws-ebs-csi-driver = { most_recent = true }
  }

  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

    # Needed by the aws-ebs-csi-driver
    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }

    # Disabling and using externally provided security groups
    create_security_group                 = false
    attach_cluster_primary_security_group = true
  }

  node_security_group_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = null
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 3

      vpc_security_group_ids = [
        aws_security_group.node_group_one.id
      ]
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_cluster_all = {
      description                   = "Cluster to node all ports/protocols"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  depends_on = [ module.vpc ]
}
