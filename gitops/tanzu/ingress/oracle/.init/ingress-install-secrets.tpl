#@ load("@ytt:yaml", "yaml")
---
#@ def config():
oracle:
  compartment: {{ .oracle_compartment_id }}
  region: {{ .oracle_region }}
  credentials:
    tenancy: {{ .oracle_tenancy_id }}
    user: {{ .oracle_user_id }}
    key: {{ .oracle_key_file_contents }}
    fingerprint: {{ .oracle_fingerprint }}
#@ end
---
apiVersion: v1
kind: Secret
metadata:
  name: git-ssh-for-carvel
  namespace: tanzu-user-managed-packages
type: kubernetes.io/ssh-auth
data:
  ssh-privatekey: {{ .git_ssh_private_key }}
  ssh-knownhosts: {{ .git_ssh_known_hosts }}
---
apiVersion: v1
kind: Secret
metadata:
  name: tanzu-ingress
  namespace: tanzu-user-managed-packages
stringData:
  tanzu-ingress-secrets.yml: #@ yaml.encode(config())