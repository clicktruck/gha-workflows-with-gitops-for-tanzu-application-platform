#@ load("@ytt:yaml", "yaml")
---
#@ def config():
scg:
  version: {{ .scg_version }}
tanzuNet:
  username: {{ .tanzu_network_username }}
  password: {{ .tanzu_network_password }}
#@ end
---
apiVersion: v1
kind: Secret
metadata:
  name: spring-cloud-gateway-values
  namespace: spring-cloud-gateway
  annotations:
    kapp.k14s.io/change-rule: "delete after deleting scg-install-gitops/app"
stringData:
  scg-secrets.yml: #@ yaml.encode(config())
