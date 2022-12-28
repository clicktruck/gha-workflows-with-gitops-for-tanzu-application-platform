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
  name: git-ssh-for-carvel
  namespace: tanzu-package-repo-global
type: kubernetes.io/ssh-auth
data:
  ssh-privatekey: {{ .git_ssh_private_key }}
  ssh-knownhosts: {{ .git_ssh_known_hosts }}
---
apiVersion: v1
kind: Secret
metadata:
  name: tanzu-standard
  namespace: tanzu-package-repo-global
stringData:
  tkg-secrets.yml: #@ yaml.encode(config())