#@ load("@ytt:yaml", "yaml")
---
#@ def config():
tds:
  version: {{ .tds_version }}
#@ end
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: tanzu-data-services
  namespace: tanzu-package-repo-data-services
data:
  tds-config.yml: #@ yaml.encode(config())