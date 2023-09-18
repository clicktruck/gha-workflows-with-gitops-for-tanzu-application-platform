#@ load("@ytt:yaml", "yaml")
---
#@ def config():
aws:
  credentials:
    accessKey: {{ .aws_access_key_id }}
    secretKey: {{ .aws_secret_access_key }}
  region: {{ .aws_region }}
  route53:
    hosted_zone_id: {{ .aws_route53_hosted_zone_id }}
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