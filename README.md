# eks-canary

Testing **Kubernetes Canary Deployment** on **EKS**.

- `master` branch : original version using [terraform-aws-modules/terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module **version 16**.
- `v18` branch : updated version using [terraform-aws-modules/terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module **version 18**.
- `no-module` branch : updated version without [terraform-aws-modules/terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module. Using just [eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) and [eks_node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group).

![architecture.svg](architecture.svg)
