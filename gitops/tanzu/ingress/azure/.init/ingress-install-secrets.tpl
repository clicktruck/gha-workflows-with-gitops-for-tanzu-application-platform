#@ load("@ytt:yaml", "yaml")
---
#@ def config():
azure:
  credentials:
    tenantId: {{ .azure_ad_tenant_id }}
    subscription: {{ .azure_subscription_id }}
    clientId: {{ .azure_ad_client_id }}
    clientSecret: {{ .azure_ad_client_secret }}
  resourceGroup: {{ .azure_resource_group_name }}
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