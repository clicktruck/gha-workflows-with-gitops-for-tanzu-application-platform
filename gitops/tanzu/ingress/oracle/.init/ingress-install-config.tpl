#@ load("@ytt:yaml", "yaml")
---
#@ def config():
ingress:
  domain: {{ .domain }}
#@ end
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: tanzu-ingress
  namespace: tanzu-user-managed-packages
data:
  tanzu-ingress-config.yml: #@ yaml.encode(config())