#@ load("@ytt:yaml", "yaml")
---
#@ def config():
tas_adapter:
  credentials:
    cf:
      admin:
        username: {{ or .cf_admin_username "" }}
    tanzuNet:
      username: {{ .tanzu_network_username }}
      password: {{ .tanzu_network_password }}
  registry:
    repositories:
      aws:
        iam_role_arn: {{ or .aws_iam_role_arn_for_ecr "" }}
#@ end
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ .app_name }}
  namespace: tas-adapter-install-gitops
  annotations:
    kapp.k14s.io/change-rule: "delete after deleting tas-adapter-install-gitops/app"
stringData:
  tap-secrets.yml: #@ yaml.encode(config())