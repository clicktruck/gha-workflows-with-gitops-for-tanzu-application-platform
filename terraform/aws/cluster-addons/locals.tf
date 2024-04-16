locals {
  tags = {
    GithubRepo             = "https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons"
    ContributingGithubRepo = "https://github.com/clicktruck/gha-workflows-with-gitops-for-tanzu-application-platform"
  }

  crossplane_aws_provider = {
    enable                   = true
    provider_aws_version     = "v0.43.1"
    additional_irsa_policies = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  }

  crossplane_helm_config = {
    values = [templatefile("${path.module}/helm-values/crossplane-values.yaml", {
      args = "--enable-external-secret-stores"
    })]
  }
}