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