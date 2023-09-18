#@ load("@ytt:yaml", "yaml")
---
#@ def config():
google:
  credentials:
    project_id: {{ .google_project_id }}
    service_account_key: {{ .google_service_account_key }}
  dns:
    zone_name: {{ .google_cloud_dns_zone_name }}
acme:
  email: {{ .email_address }}
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