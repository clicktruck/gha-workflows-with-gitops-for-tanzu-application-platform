#@ load("@ytt:yaml", "yaml")
---
#@ def config():
tkg:
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
  namespace: tanzu-package-repo-global
type: kubernetes.io/basic-auth
stringData:
  username: {{ .git_username }}
  password: {{ .git_personal_access_token }}
---
apiVersion: v1
kind: Secret
metadata:
  name: tanzu-standard
  namespace: tanzu-package-repo-global
stringData:
  tkg-secrets.yml: #@ yaml.encode(config())