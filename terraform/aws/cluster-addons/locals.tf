locals {
  tags = {
    GithubRepo             = "https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons"
    ContributingGithubRepo = "https://github.com/pacphi/gha-workflows-with-gitops-for-tanzu-application-platform"
  }

  crossplane_aws_provider = {
    enable                   = true
    provider_aws_version     = "v0.36.0"
    additional_irsa_policies = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  }

}