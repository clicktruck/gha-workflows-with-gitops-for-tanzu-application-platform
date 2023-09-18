#@ load("@ytt:yaml", "yaml")
---
#@ def config():
tap:
  credentials:
    tanzuNet:
      username: {{ .tanzu_network_username }}
      password: {{ .tanzu_network_password }}
    registry:
      email: {{ .email_address }}
      host: {{ .container_image_registry_url }}
      username: {{ .container_image_registry_username }}
      password: {{ .container_image_registry_password }}
    git:
      host: {{ .git_host }}
      username: {{ .git_username }}
      token: {{ .git_personal_access_token }}
    oidc:
      client_id: {{ or .oidc_auth_client_id "" }}
      client_secret: {{ or .oidc_auth_client_secret "" }}
      provider: {{ or .oidc_auth_provider "github" }}
#! observed-clusters
#@ end
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ .app_name }}
  namespace: tap-install-gitops
  annotations:
    kapp.k14s.io/change-rule: "delete after deleting tap-install-gitops/app"
stringData:
  tap-secrets.yml: #@ yaml.encode(config())