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
  name: git-https-for-carvel
  namespace: tanzu-user-managed-packages
type: kubernetes.io/basic-auth
stringData:
  username: {{ .git_username }}
  password: {{ .git_personal_access_token }}
---
apiVersion: v1
kind: Secret
metadata:
  name: tanzu-ingress
  namespace: tanzu-user-managed-packages
stringData:
  tanzu-ingress-secrets.yml: #@ yaml.encode(config())