# eks-canary

Testing **Kubernetes Canary Deployment** on **EKS**.

![architecture.svg](architecture.svg)

Updated version without [terraform-aws-modules/terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module.

Using just [eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) and [eks_node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group).