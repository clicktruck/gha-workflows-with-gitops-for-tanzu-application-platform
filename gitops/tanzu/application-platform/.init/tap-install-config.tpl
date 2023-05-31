#@ load("@ytt:yaml", "yaml")
---
#@ def config():
tap:
  devNamespace: {{ .dev_namespace }}
  catalogs:
  - {{ .backstage_catalog }}

  registry:
    repositories:
      aws:
        iam_role_arn: {{ .build_service_repo_aws_iam_role_arn }}
      base: {{ .target_repo }}
      buildService: {{ .build_service_repo }}
      ootbSupplyChain: {{ .ootb_supply_chain_repo }}

  domains:
    main: {{ .domain }}
    tapGui: tap-gui.{{ .domain }}
    learningCenter: {{ .domain }}
    knative: {{ .domain }}

  ingress:
    contour_tls_secret: tls
    contour_tls_namespace: contour-tls

  cluster:
    issuerRef:
      group: cert-manager.io
      kind: ClusterIssuer
      name: letsencrypt-contour-cluster-issuer
    provider: {{ .cluster_provider }}

  supply_chain:
    aws:
      iam_role_arn: {{ .workload_repo_aws_iam_role_arn }}
    gitops:
      provider: {{ or .gitops_provider "github.com" }}
      repository:
        name: {{ or .gitops_repo_name "tap-gitops-depot" }}
        owner: {{ .gitops_username }}
        branch: {{ or .gitops_repo_branch "main" }}
#@ end
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .app_name }}
  namespace: tap-install-gitops
data:
  tap-config.yml: #@ yaml.encode(config())