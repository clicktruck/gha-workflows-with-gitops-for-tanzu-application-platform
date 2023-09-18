#@ load("@ytt:yaml", "yaml")
---
#@ def config():
tds:
  credentials:
    tanzuNet:
      username: {{ .tanzu_network_username }}
      password: {{ .tanzu_network_password }}
#@ end
---
apiVersion: v1
kind: Secret
metadata:
  name: git-https-for-carvel
  namespace: tanzu-package-repo-data-services
type: kubernetes.io/basic-auth
stringData:
  username: {{ .git_username }}
  password: {{ .git_personal_access_token }}
---
apiVersion: v1
kind: Secret
metadata:
  name: tanzu-data-services
  namespace: tanzu-package-repo-data-services
stringData:
  tkg-secrets.yml: #@ yaml.encode(config())